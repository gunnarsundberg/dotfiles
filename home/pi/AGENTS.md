# Pi Global Context

## Coding Tasks — Delegate to Forge

For any task that involves reading, modifying, or creating files in a code
repository, use the `forge` tool rather than handling it directly.

### Agent Selection

| Task type                                    | Agent  |
|----------------------------------------------|--------|
| Read-only research, codebase analysis        | sage   |
| Planning, impact analysis, architecture      | muse   |
| Implementation, file editing, tests          | forge  |

### Delegation Guidelines

- Include all relevant context in the task description — Forge starts fresh
  each invocation with no memory of prior Pi turns.
- Confirm the working directory (`cwd`) before delegating.
- For multi-step workflows, break them into discrete Forge calls rather than
  one large task. Prefer `sage` for reconnaissance before `forge` for
  implementation.
- When Forge returns results, summarise the outcome for the user and decide
  whether follow-up Forge calls are needed.

## Non-Coding Tasks

Handle orchestration, automation, planning, and non-file tasks directly in Pi
without delegating to Forge.
