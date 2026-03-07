import { ToolProvider } from "../types";
import { antigravityProvider } from "./antigravity";
import { claudeProvider } from "./claude";

const providers = new Map<string, ToolProvider>([
  [claudeProvider.name, claudeProvider],
  [antigravityProvider.name, antigravityProvider],
]);

export function getProvider(name: string): ToolProvider | undefined {
  return providers.get(name);
}

export function listProviders(): string[] {
  return Array.from(providers.keys()).sort();
}
