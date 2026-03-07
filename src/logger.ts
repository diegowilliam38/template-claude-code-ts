import { Logger } from "./types";

const BLUE = "\u001b[34m";
const GREEN = "\u001b[32m";
const YELLOW = "\u001b[33m";
const RED = "\u001b[31m";
const RESET = "\u001b[0m";

function line(color: string, label: string, message: string): void {
  process.stdout.write(`${color}[${label}]${RESET} ${message}\n`);
}

export function createLogger(): Logger {
  return {
    info: (message) => line(BLUE, "INFO", message),
    ok: (message) => line(GREEN, " OK ", message),
    warn: (message) => line(YELLOW, "WARN", message),
    error: (message) => {
      process.stderr.write(`${RED}[ERRO]${RESET} ${message}\n`);
      process.exit(1);
    },
  };
}
