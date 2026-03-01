const SERVICE_NAME = "phira-archivist-auto";
const handledMessages = new Set();

function normalizeCommandName(name) {
  return String(name || "").replace(/^\//, "").trim().toLowerCase();
}

function shouldSkipAutoArchive(args) {
  return /\b(noarchive|archive-off|skip-archive)\b/i.test(String(args || ""));
}

function textParts(parts) {
  if (!Array.isArray(parts)) {
    return "";
  }

  return parts
    .filter((part) => part && part.type === "text" && typeof part.text === "string")
    .map((part) => part.text)
    .join("\n\n");
}

function shouldTriggerArchivist({ commandArgs, assistantText }) {
  const content = `${commandArgs || ""}\n${assistantText || ""}`;

  if (/scaffold_cleanup\s*:\s*false/i.test(content)) {
    return false;
  }

  if (/scaffold_cleanup\s*:\s*true/i.test(content)) {
    return true;
  }

  const pseudocodeContext = /(implement from pseudocode|phira_pseudocode|_phira_pseudo_|placeholder)/i.test(content);
  const cleanupMention = /(deleted|removed)[^\n]{0,180}(placeholder|pseudo-call|phira_pseudocode|_phira_pseudo_)/i.test(content);

  return pseudocodeContext && cleanupMention;
}

async function readAssistantText(client, sessionID, messageID) {
  if (!sessionID || !messageID) {
    return "";
  }

  try {
    const result = await client.session.message({
      path: {
        id: sessionID,
        messageID,
      },
    });

    if (!result || result.error || !result.data) {
      return "";
    }

    return textParts(result.data.parts);
  } catch {
    return "";
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

function buildArchivistArguments({ sourceMessageID }) {
  return [
    "Mode: draft.",
    "Auto-trigger source: /i completion after scaffold cleanup detection.",
    `Source message: ${sourceMessageID || "unknown"}.`,
    "Do not write files.",
    "Draft the archive record(s) and then ask the user for approval before applying.",
  ].join(" ");
}

export const ArchivistAutoTriggerPlugin = async ({ client }) => {
  return {
    event: async ({ event }) => {
      if (!event || event.type !== "command.executed") {
        return;
      }

      const name = normalizeCommandName(event.properties?.name);
      if (name !== "i") {
        return;
      }

      const sessionID = event.properties?.sessionID;
      const messageID = event.properties?.messageID;
      const commandArgs = event.properties?.arguments || "";

      if (!sessionID) {
        return;
      }

      if (shouldSkipAutoArchive(commandArgs)) {
        await log(client, "debug", "Skipped auto archive due to explicit flag", {
          sessionID,
          messageID,
          commandArgs,
        });
        return;
      }

      const dedupeKey = `${sessionID}:${messageID || commandArgs}`;
      if (handledMessages.has(dedupeKey)) {
        return;
      }

      handledMessages.add(dedupeKey);

      const assistantText = await readAssistantText(client, sessionID, messageID);

      if (!shouldTriggerArchivist({ commandArgs, assistantText })) {
        return;
      }

      const argumentsForArchivist = buildArchivistArguments({
        sourceMessageID: messageID,
      });

      try {
        await client.session.command({
          path: {
            id: sessionID,
          },
          body: {
            command: "a",
            arguments: argumentsForArchivist,
          },
        });

        await log(client, "info", "Triggered archivist command after /i", {
          sessionID,
          sourceMessageID: messageID,
        });
      } catch (error) {
        await log(client, "warn", "Failed to trigger archivist command", {
          sessionID,
          sourceMessageID: messageID,
          error: String(error),
        });
      }
    },
  };
};
