import type { UserConfig } from "vitest/config";
import { defineConfig } from "vitest/config";

export interface DevkitVitestOptions {
  environment?: "node" | "jsdom" | "happy-dom";
  setupFiles?: string[];
  coverage?: boolean;
}

export function defineDevkitConfig(options: DevkitVitestOptions = {}) {
  const isCI = !!process.env.CI;

  const baseConfig: UserConfig = {
    test: {
      coverage: options.coverage ? { provider: "v8" } : undefined,
      environment: options.environment ?? "node",
      globals: true,
      reporters: isCI ? ["basic"] : ["verbose"],
      retry: isCI ? 2 : 0,
      setupFiles: options.setupFiles,
      testTimeout: isCI ? 30_000 : 10_000,
    },
  };

  return defineConfig(baseConfig);
}

// Re-export for merging with existing vite configs
export { mergeConfig } from "vitest/config";
