import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { spawn } from "node:child_process";

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "forge",
    label: "Forge Code Agent",
    description:
      "Delegate a coding or research task to the Forge agent. " +
      "Use agent='sage' for read-only research (no file modifications), " +
      "'muse' for planning and impact analysis, " +
      "'forge' (default) for implementation and file editing.",
    parameters: Type.Object({
      task: Type.String({
        description:
          "Self-contained task description. Include all relevant context " +
          "since Forge starts fresh with no memory of prior Pi turns.",
      }),
      agent: Type.Optional(
        Type.Union(
          [
            Type.Literal("sage"),
            Type.Literal("muse"),
            Type.Literal("forge"),
          ],
          { description: "Forge sub-agent to invoke. Defaults to 'forge'." }
        )
      ),
      cwd: Type.Optional(
        Type.String({
          description:
            "Project directory for Forge to work in. " +
            "Defaults to Pi's current working directory.",
        })
      ),
    }),

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      const agent = params.agent ?? "forge";
      const workDir = params.cwd ?? ctx.cwd;
      const args = ["--agent", agent, "-p", params.task];

      return new Promise((resolve) => {
        const proc = spawn("forge", args, {
          cwd: workDir,
          env: process.env,
        });

        let stdout = "";
        let stderr = "";

        proc.stdout.on("data", (chunk: Buffer) => {
          stdout += chunk.toString();
          onUpdate?.({ content: [{ type: "text", text: stdout }] });
        });

        proc.stderr.on("data", (chunk: Buffer) => {
          stderr += chunk.toString();
        });

        signal?.addEventListener("abort", () => proc.kill("SIGTERM"));

        proc.on("close", (code) => {
          resolve({
            content: [{ type: "text", text: stdout || stderr || "(no output)" }],
            details: { exitCode: code, stderr },
            isError: code !== 0,
          });
        });
      });
    },
  });
}
