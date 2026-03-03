const SERVICE_NAME = "phira-chained-commands";
const CHAINABLE_COMMANDS = new Set(["p", "h", "i", "r", "a"]);
const TOKEN_REGEX = /(^|[\s.,;:!?(){}\[\]])\/([phira])(?=(?:[\s.,;:!?(){}\[\]]|$))/gi;
const MAX_CHAIN_STEPS = 12;
const STALE_MS = 60 * 60 * 1000;

const sessionChains = new Map();

function normalizeCommandName(name) {
  return String(name || "").replace(/^\//, "").trim().toLowerCase();
}

function normalizeArgs(args) {
  return String(args || "").trim().replace(/\s+/g, " ");
}

function now() {
  return Date.now();
}

function chainId() {
  return `chain-${now()}-${Math.random().toString(36).slice(2, 8)}`;
}

function getSessionState(sessionID) {
  if (!sessionChains.has(sessionID)) {
    sessionChains.set(sessionID, {
      active: null,
      queue: [],
      pendingFirst: [],
      internalDispatches: [],
      loopRunning: false,
    });
  }
  return sessionChains.get(sessionID);
}

function cleanupSessionState(sessionID) {
  const state = sessionChains.get(sessionID);
  if (!state) {
    return;
  }

  const hasWork =
    state.active ||
    state.queue.length > 0 ||
    state.pendingFirst.length > 0 ||
    state.internalDispatches.length > 0 ||
    state.loopRunning;

  if (!hasWork) {
    sessionChains.delete(sessionID);
  }
}

function pruneState(state) {
  const cutoff = now() - STALE_MS;
  state.pendingFirst = state.pendingFirst.filter((item) => item.createdAt >= cutoff);
  state.internalDispatches = state.internalDispatches.filter((item) => item.createdAt >= cutoff);
}

function parseChainSteps(rootCommand, rawArguments) {
  const command = normalizeCommandName(rootCommand);
  if (!CHAINABLE_COMMANDS.has(command)) {
    return null;
  }

  const args = String(rawArguments || "");
  const tokens = [];
  for (const match of args.matchAll(TOKEN_REGEX)) {
    const boundary = match[1] || "";
    const subcommand = normalizeCommandName(match[2]);
    if (!CHAINABLE_COMMANDS.has(subcommand)) {
      continue;
    }
    const index = (match.index || 0) + boundary.length;
    tokens.push({ index, command: subcommand });
  }

  if (tokens.length === 0) {
    return null;
  }

  const steps = [];
  const firstChunk = args.slice(0, tokens[0].index).trim();
  steps.push({ command, arguments: firstChunk });

  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];
    const next = tokens[i + 1];
    const chunkStart = token.index + 2;
    const chunkEnd = next ? next.index : args.length;
    const chunk = args.slice(chunkStart, chunkEnd).trim();
    steps.push({ command: token.command, arguments: chunk });
  }

  if (steps.length <= 1) {
    return null;
  }

  if (steps.length > MAX_CHAIN_STEPS) {
    return steps.slice(0, MAX_CHAIN_STEPS);
  }

  return steps;
}

function replaceArgsInText(text, originalArgs, firstArgs) {
  if (typeof text !== "string") {
    return text;
  }

  const original = String(originalArgs || "");
  if (!original) {
    return text;
  }

  if (text.includes(original)) {
    return text.split(original).join(firstArgs);
  }

  const trimmedOriginal = original.trim();
  if (trimmedOriginal && text.includes(trimmedOriginal)) {
    return text.split(trimmedOriginal).join(firstArgs);
  }

  return text;
}

function rewriteToFirstChunk(parts, originalArgs, firstArgs) {
  if (!Array.isArray(parts)) {
    return false;
  }

  let changed = false;
  for (const part of parts) {
    if (!part || typeof part !== "object") {
      continue;
    }

    if (part.type === "text" && typeof part.text === "string") {
      const next = replaceArgsInText(part.text, originalArgs, firstArgs);
      if (next !== part.text) {
        part.text = next;
        changed = true;
      }
      continue;
    }

    if (part.type === "subtask" && typeof part.prompt === "string") {
      const next = replaceArgsInText(part.prompt, originalArgs, firstArgs);
      if (next !== part.prompt) {
        part.prompt = next;
        changed = true;
      }
    }
  }

  return changed;
}

function makeChain(steps, sourceMessageID) {
  return {
    id: chainId(),
    steps,
    nextStepIndex: 1,
    status: "queued",
    cancelRequested: false,
    sourceMessageID,
    createdAt: now(),
  };
}

function isAbortedError(err) {
  return String(err?.name || "").toLowerCase() === "messageabortederror";
}

function extractResponseInfo(response) {
  if (!response) {
    return null;
  }
  const payload = response.data || response;
  return payload?.info || null;
}

async function readAssistantInfo(client, sessionID, messageID) {
  if (!sessionID || !messageID) {
    return null;
  }

  try {
    const response = await client.session.message({
      path: {
        id: sessionID,
        messageID,
      },
    });
    return extractResponseInfo(response);
  } catch {
    return null;
  }
}

async function log(client, level, message, extra) {
  try {
    await client.app.log({
      body: {
        service: SERVICE_NAME,
        level,
        message,
        extra,
      },
    });
  } catch {
    // Ignore logging failures.
  }
}

function popInternalDispatch(state, command, argsNorm) {
  const head = state.internalDispatches[0];
  if (!head) {
    return false;
  }

  if (head.command === command && head.argsNorm === argsNorm) {
    state.internalDispatches.shift();
    return true;
  }

  return false;
}

async function requestCancelActiveChain(client, sessionID, reason) {
  const state = sessionChains.get(sessionID);
  if (!state || !state.active) {
    return;
  }

  if (state.active.cancelRequested) {
    return;
  }

  state.active.cancelRequested = true;
  await log(client, "info", "Marked active chain as cancelled", {
    sessionID,
    chainID: state.active.id,
    reason,
    queueLength: state.queue.length,
  });
}

async function runScheduler(client, sessionID) {
  const state = getSessionState(sessionID);
  if (state.loopRunning) {
    return;
  }

  state.loopRunning = true;
  try {
    while (true) {
      pruneState(state);

      if (!state.active) {
        if (state.queue.length === 0) {
          break;
        }
        state.active = state.queue.shift();
      }

      const chain = state.active;
      if (!chain) {
        continue;
      }

      if (chain.cancelRequested) {
        chain.status = "cancelled";
        await log(client, "info", "Cancelled active chain", {
          sessionID,
          chainID: chain.id,
          queueLength: state.queue.length,
        });
        state.active = null;
        continue;
      }

      if (chain.nextStepIndex >= chain.steps.length) {
        chain.status = "completed";
        await log(client, "info", "Completed command chain", {
          sessionID,
          chainID: chain.id,
          stepCount: chain.steps.length,
        });
        state.active = null;
        continue;
      }

      const step = chain.steps[chain.nextStepIndex];
      chain.status = "running";

      const stepCommand = normalizeCommandName(step.command);
      const stepArgs = String(step.arguments || "");
      const stepArgsNorm = normalizeArgs(stepArgs);

      state.internalDispatches.push({
        command: stepCommand,
        argsNorm: stepArgsNorm,
        chainID: chain.id,
        createdAt: now(),
      });

      let response;
      try {
        response = await client.session.command({
          path: {
            id: sessionID,
          },
          body: {
            command: stepCommand,
            arguments: stepArgs,
          },
        });
      } catch (error) {
        chain.status = "failed";
        state.active = null;
        await log(client, "warn", "Chain step failed with command error", {
          sessionID,
          chainID: chain.id,
          stepIndex: chain.nextStepIndex,
          command: stepCommand,
          error: String(error),
        });
        continue;
      } finally {
        const idx = state.internalDispatches.findIndex(
          (item) => item.chainID === chain.id && item.command === stepCommand && item.argsNorm === stepArgsNorm,
        );
        if (idx >= 0) {
          state.internalDispatches.splice(idx, 1);
        }
      }

      if (chain.cancelRequested) {
        chain.status = "cancelled";
        await log(client, "info", "Cancelled active chain after interrupt", {
          sessionID,
          chainID: chain.id,
          stepIndex: chain.nextStepIndex,
        });
        state.active = null;
        continue;
      }

      const info = extractResponseInfo(response);
      if (!info || info.error) {
        chain.status = "failed";
        state.active = null;
        await log(client, "warn", "Chain step failed with assistant error", {
          sessionID,
          chainID: chain.id,
          stepIndex: chain.nextStepIndex,
          command: stepCommand,
          error: info?.error,
        });
        continue;
      }

      chain.nextStepIndex += 1;
    }
  } finally {
    state.loopRunning = false;
    cleanupSessionState(sessionID);
  }
}

export const ChainedCommandsPlugin = async ({ client }) => {
  return {
    "command.execute.before": async (input, output) => {
      const command = normalizeCommandName(input.command);
      if (!CHAINABLE_COMMANDS.has(command)) {
        return;
      }

      const sessionID = input.sessionID;
      if (!sessionID) {
        return;
      }

      const state = getSessionState(sessionID);
      pruneState(state);

      const argsNorm = normalizeArgs(input.arguments);
      if (popInternalDispatch(state, command, argsNorm)) {
        cleanupSessionState(sessionID);
        return;
      }

      const steps = parseChainSteps(command, input.arguments);
      if (!steps) {
        cleanupSessionState(sessionID);
        return;
      }

      rewriteToFirstChunk(output.parts, input.arguments, steps[0].arguments);

      state.pendingFirst.push({
        chain: makeChain(steps),
        firstCommand: command,
        firstArgsNorm: argsNorm,
        createdAt: now(),
      });

      await log(client, "info", "Detected chained command sequence", {
        sessionID,
        firstCommand: command,
        stepCount: steps.length,
        steps: steps.map((step) => step.command),
      });
    },

    event: async ({ event }) => {
      if (!event || !event.type) {
        return;
      }

      if (event.type === "session.error") {
        const sessionID = event.properties?.sessionID;
        if (sessionID && isAbortedError(event.properties?.error)) {
          await requestCancelActiveChain(client, sessionID, "session.error.message_aborted");
        }
        return;
      }

      if (event.type === "message.updated") {
        const info = event.properties?.info;
        if (info?.role === "assistant" && info?.sessionID && isAbortedError(info.error)) {
          await requestCancelActiveChain(client, info.sessionID, "message.updated.message_aborted");
        }
        return;
      }

      if (event.type !== "command.executed") {
        return;
      }

      const sessionID = event.properties?.sessionID;
      if (!sessionID) {
        return;
      }

      const command = normalizeCommandName(event.properties?.name);
      if (!CHAINABLE_COMMANDS.has(command)) {
        cleanupSessionState(sessionID);
        return;
      }

      const state = getSessionState(sessionID);
      pruneState(state);

      const argsNorm = normalizeArgs(event.properties?.arguments);
      const pendingIdx = state.pendingFirst.findIndex(
        (item) => item.firstCommand === command && item.firstArgsNorm === argsNorm,
      );

      if (pendingIdx < 0) {
        cleanupSessionState(sessionID);
        return;
      }

      const pending = state.pendingFirst.splice(pendingIdx, 1)[0];

      const info = await readAssistantInfo(client, sessionID, event.properties?.messageID);
      if (!info || info.error) {
        await log(client, "warn", "Chain aborted at first step due failure", {
          sessionID,
          firstCommand: command,
          error: info?.error,
        });
        cleanupSessionState(sessionID);
        return;
      }

      if (pending.chain.steps.length <= 1) {
        cleanupSessionState(sessionID);
        return;
      }

      pending.chain.sourceMessageID = event.properties?.messageID;

      if (state.active || state.loopRunning) {
        state.queue.push(pending.chain);
        await log(client, "info", "Queued chain while another chain is active", {
          sessionID,
          chainID: pending.chain.id,
          queueLength: state.queue.length,
        });
      } else {
        state.active = pending.chain;
      }

      await runScheduler(client, sessionID);
    },
  };
};
