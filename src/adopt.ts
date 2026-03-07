#!/usr/bin/env node
import { cpSync, existsSync, mkdtempSync, rmSync, statSync } from "node:fs";
import os from "node:os";
import path from "node:path";
import readline from "node:readline/promises";
import { spawnSync } from "node:child_process";
import { createLogger } from "./logger";
import { getProvider, listProviders } from "./providers";
import { ToolProvider } from "./types";

interface Args {
  tool: string;
  source?: string;
  target: string;
  yes: boolean;
}

function printHelp(): void {
  process.stdout.write(`adopt-cli\n\n`);
  process.stdout.write(`Uso:\n`);
  process.stdout.write(`  adopt --tool <nome> [--source <repo-ou-caminho>] [--target <dir>] [--yes]\n\n`);
  process.stdout.write(`Opcoes:\n`);
  process.stdout.write(`  --tool     Nome do provider (ex.: claude)\n`);
  process.stdout.write(`  --source   Repositorio git (owner/repo, URL) ou caminho local\n`);
  process.stdout.write(`  --target   Diretorio de destino (padrao: diretorio atual)\n`);
  process.stdout.write(`  --yes      Nao perguntar confirmacoes\n`);
  process.stdout.write(`  --help     Exibe ajuda\n\n`);
  process.stdout.write(`Providers disponiveis: ${listProviders().join(", ")}\n`);
}

function parseArgs(argv: string[]): Args {
  const args: Args = {
    tool: "claude",
    target: process.cwd(),
    yes: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const current = argv[i];

    if (current === "--help" || current === "-h") {
      printHelp();
      process.exit(0);
    }

    if (current === "--yes") {
      args.yes = true;
      continue;
    }

    if (current === "--tool") {
      const nextValue = argv[i + 1];
      if (!nextValue) {
        throw new Error(`Valor ausente para ${current}`);
      }
      args.tool = nextValue;
      i += 1;
      continue;
    }

    if (current === "--source") {
      const nextValue = argv[i + 1];
      if (!nextValue) {
        throw new Error(`Valor ausente para ${current}`);
      }
      args.source = nextValue;
      i += 1;
      continue;
    }

    if (current === "--target") {
      const nextValue = argv[i + 1];
      if (!nextValue) {
        throw new Error(`Valor ausente para ${current}`);
      }
      args.target = path.resolve(nextValue);
      i += 1;
      continue;
    }

    throw new Error(`Argumento desconhecido: ${current}`);
  }

  return args;
}

function ensureGitRepo(targetDir: string): void {
  const gitDir = path.join(targetDir, ".git");
  if (!existsSync(gitDir)) {
    throw new Error("Execute este comando na raiz de um repositorio git (ou use --target). ");
  }

  const gitMeta = statSync(gitDir);
  if (!gitMeta.isDirectory() && !gitMeta.isFile()) {
    throw new Error("Execute este comando na raiz de um repositorio git (ou use --target). ");
  }
}

function expandHome(input: string): string {
  if (input === "~") {
    return os.homedir();
  }
  if (input.startsWith("~/")) {
    return path.join(os.homedir(), input.slice(2));
  }
  return input;
}

function isLocalPath(source: string): boolean {
  const expanded = expandHome(source);
  if (expanded.startsWith(".") || expanded.startsWith("/") || /^[a-zA-Z]:\\/.test(expanded) || expanded.startsWith("\\\\")) {
    return true;
  }
  return existsSync(path.resolve(expanded));
}

function normalizeRepoSource(source: string): string {
  if (source.startsWith("https://") || source.startsWith("git@") || source.startsWith("ssh://")) {
    return source;
  }

  if (source.includes("/")) {
    return `https://github.com/${source}.git`;
  }

  return source;
}

function fetchSource(source: string, logger: ReturnType<typeof createLogger>): { dir: string; cleanup: () => void } {
  if (isLocalPath(source)) {
    const fullPath = path.resolve(expandHome(source));
    if (!existsSync(fullPath)) {
      throw new Error(`Template local nao encontrado: ${fullPath}`);
    }

    return { dir: fullPath, cleanup: () => {} };
  }

  const tempDir = mkdtempSync(path.join(os.tmpdir(), "adopt-cli-"));
  const repo = normalizeRepoSource(source);

  const gitAvailable = spawnSync("git", ["--version"], { stdio: "ignore" }).status === 0;
  if (!gitAvailable) {
    rmSync(tempDir, { recursive: true, force: true });
    throw new Error("Git nao encontrado. Instale o git para clonar templates remotos.");
  }

  logger.info(`Clonando template: ${repo}`);
  const result = spawnSync("git", ["clone", repo, tempDir, "--depth=1", "--quiet"], {
    stdio: "inherit",
  });

  if (result.status !== 0) {
    rmSync(tempDir, { recursive: true, force: true });
    throw new Error(`Falha ao clonar template: ${repo}`);
  }

  return {
    dir: tempDir,
    cleanup: () => rmSync(tempDir, { recursive: true, force: true }),
  };
}

async function shouldOverwrite(target: string, yes: boolean): Promise<boolean> {
  if (yes) {
    return true;
  }

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const answer = await rl.question(`\`${target}\` ja existe. Deseja sobrescrever? [s/N] `);
  rl.close();
  return answer.trim().toLowerCase() === "s";
}

async function applyProvider(provider: ToolProvider, sourceDir: string, targetDir: string, yes: boolean): Promise<void> {
  const logger = createLogger();

  logger.info(`Provider: ${provider.name}`);
  logger.info(`Template: ${sourceDir}`);
  logger.info(`Destino: ${targetDir}`);

  for (const rule of provider.copyRules) {
    const sourcePath = path.join(sourceDir, rule.source);
    const targetPath = path.join(targetDir, rule.destination);

    if (!existsSync(sourcePath)) {
      if (rule.required) {
        logger.error(`Arquivo/diretorio obrigatorio nao encontrado no template: ${rule.source}`);
      }
      continue;
    }

    const targetExists = existsSync(targetPath);

    if (rule.overwrite === "never" && targetExists) {
      logger.warn(`${rule.destination} ja existe. Mantendo arquivo existente.`);
      continue;
    }

    if (rule.overwrite === "always" && targetExists) {
      rmSync(targetPath, { recursive: true, force: true });
    }

    if (rule.overwrite === "prompt" && targetExists) {
      const allowed = await shouldOverwrite(rule.destination, yes);
      if (!allowed) {
        logger.warn(`Copia de ${rule.destination} cancelada.`);
        continue;
      }
      rmSync(targetPath, { recursive: true, force: true });
    }

    cpSync(sourcePath, targetPath, { recursive: true });
    logger.ok(`${rule.destination} copiado`);
  }

  await provider.afterCopy?.({
    sourceDir,
    targetDir,
    yes,
    logger,
  });

  process.stdout.write("\n");
  logger.ok(`Estrutura ${provider.name} adicionada ao projeto.`);

  if (provider.nextSteps && provider.nextSteps.length > 0) {
    process.stdout.write("\nProximos passos:\n");
    provider.nextSteps.forEach((step, index) => {
      process.stdout.write(`${index + 1}. ${step}\n`);
    });
  }
}

async function main(): Promise<void> {
  const logger = createLogger();

  try {
    const args = parseArgs(process.argv.slice(2));
    const provider = getProvider(args.tool);

    if (!provider) {
      throw new Error(`Provider desconhecido: ${args.tool}. Disponiveis: ${listProviders().join(", ")}`);
    }

    ensureGitRepo(args.target);

    const source = args.source ?? provider.defaultSource;
    if (!source) {
      throw new Error(`Provider ${provider.name} nao definiu fonte padrao. Use --source.`);
    }

    const fetched = fetchSource(source, logger);
    try {
      await applyProvider(provider, fetched.dir, args.target, args.yes);
    } finally {
      fetched.cleanup();
    }
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    logger.error(message);
  }
}

void main();
