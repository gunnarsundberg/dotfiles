---
name: herdr
description: "Run or watch long-running/user-visible work in a herdr pane — dev servers, test suites, builds, parallel visible workers — or manage herdr panes/tabs/workspaces directly. Use when the user wants to watch or attach to something alongside the conversation, wants parallel work visible in herdr's agents panel, or explicitly asks about herdr panes/workspaces/agents. Do not use merely because HERDR_ENV=1 is set — that's true in nearly every session and is not itself a trigger. Not for short-lived advisory subagent work — use subagent() for that."
---

# Herdr Skill

## When to use this skill

- The user wants to watch, attach to, or interact with a running process (dev server, test run, build) alongside the conversation.
- The user wants parallel work visible in herdr's agents panel, or wants to spawn a named agent they can check on or attach to directly.
- The user explicitly asks about herdr panes, tabs, workspaces, or agent status.
- **Not** for short-lived advisory delegation (scout/reviewer/researcher-style work) — use `subagent()` for that; it's faster and better coordinated, and this skill's own rules say not to substitute herdr panes for it.

## Prerequisite check

Before doing anything herdr-related, verify the environment:

```bash
echo "HERDR_ENV=${HERDR_ENV:-unset}"
```

If `HERDR_ENV` is not `1`, stop and tell the user this session is not running inside a herdr-managed pane. Do not try to control herdr from outside it.

## Concepts

- **Workspace** — a project context (sidebar entry). Contains one or more tabs.
- **Tab** — a subcontext inside a workspace. Contains one or more panes.
- **Pane** — a terminal split. Runs one process: shell, agent, server, etc.
- **Agent status** — `idle`, `working`, `blocked`, `done`, `unknown`. Detected automatically by herdr.

IDs: workspaces = `1`, `2`; tabs = `1:1`, `1:2`; panes = `1-1`, `1-2`. **IDs compact when things close — always re-read them instead of caching.**

Pi has the herdr lifecycle integration installed, so this session reports `idle`/`working`/`blocked` accurately to herdr's agents panel.

## Discover the current context

```bash
herdr pane list          # see all panes; the focused one is yours
herdr workspace list     # see all workspaces
herdr tab list --workspace 1
```

## In-process subagents vs visible herdr-pane subagents

Pi's `subagent()` tool spawns **in-process** child agents — fast and well-coordinated, but **invisible to herdr's agents panel**.

Use in-process subagents (`subagent()`) when:
- The work is short-lived or primarily advisory (scout, reviewer, researcher)
- You don't need herdr panel visibility
- Tight coordination via intercom/supervisor is needed

Use herdr-pane subagents when:
- You want the work visible in herdr's agents panel
- The subagent will run for a long time
- The user wants to watch or attach to the agent directly
- You're spawning multiple parallel workers and want herdr's state rollup

## Spawning a visible pi subagent in a herdr pane

```bash
# Split right, start pi, wait for it to be ready, then send a task
NEW_PANE=$(herdr pane split 1-2 --direction right --no-focus | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
herdr pane run "$NEW_PANE" "cd $PWD && pi"
herdr wait output "$NEW_PANE" --match ">" --timeout 15000
herdr pane run "$NEW_PANE" "Your task here"
```

This manual `intercom ask`/status-polling pattern applies only to raw herdr-pane `pi` sessions like this one — they have no native result delivery. Never use it on children launched via `subagent()`; those auto-deliver their result and polling them via intercom produces duplicate delivery.

Then coordinate via intercom — the new pi session should `/name` itself so it's easy to target:

```bash
herdr pane run "$NEW_PANE" "/name worker-1"
```

From the parent session:
```typescript
intercom({ action: "ask", to: "worker-1", message: "What's your status?" })
```

Alternatively, use `herdr agent start` for a named agent target:

```bash
herdr agent start worker-1 --cwd "$PWD" -- pi
```

This registers it as a named agent target immediately:

```bash
herdr wait agent-status worker-1 --status done --timeout 300000
```

## Waiting on agents and output

Wait for a pane to print specific text:

```bash
herdr wait output 1-3 --match "ready on port 3000" --timeout 30000
herdr wait output 1-3 --match "test result.*ok" --regex --timeout 60000
```

Wait for an agent to reach a status:

```bash
herdr wait agent-status 1-1 --status done --timeout 120000
herdr wait agent-status worker-1 --status idle --timeout 60000
```

Exit code `1` on timeout.

## Reading pane output

```bash
herdr pane read 1-1 --source recent --lines 80
herdr pane read 1-1 --source visible            # current viewport
herdr pane read 1-1 --source recent-unwrapped   # soft-wraps joined (matches what wait output sees)
```

Use `recent-unwrapped` when checking the same content that a `wait output` matched against.

## Running commands in panes

```bash
herdr pane run 1-3 "cargo test"         # sends text + Enter
herdr pane send-text 1-1 "hello"        # text only, no Enter
herdr pane send-keys 1-1 Enter          # keypress only
```

## Tab and workspace management

```bash
# Tabs
herdr tab create --workspace 1 --label "tests"
herdr tab focus 1:2
herdr tab rename 1:2 "logs"
herdr tab close 1:2

# Workspaces
herdr workspace create --cwd /path/to/project --label "api server" --no-focus
herdr workspace focus 2
herdr workspace rename 1 "api server"
herdr workspace close 2
```

## Pane management

```bash
herdr pane split 1-2 --direction right --no-focus
herdr pane split 1-2 --direction down --no-focus
herdr pane close 1-3
```

Always use `--no-focus` on splits unless the user explicitly wants focus to move.

## Recipes

### Run a server and wait until ready

```bash
NEW_PANE=$(herdr pane split 1-2 --direction right --no-focus | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
herdr pane run "$NEW_PANE" "npm run dev"
herdr wait output "$NEW_PANE" --match "ready" --timeout 30000
herdr pane read "$NEW_PANE" --source recent --lines 20
```

### Run tests and inspect results

```bash
NEW_PANE=$(herdr pane split 1-2 --direction down --no-focus | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["pane"]["pane_id"])')
herdr pane run "$NEW_PANE" "go test ./..."
herdr wait output "$NEW_PANE" --match "PASS\|FAIL\|ok" --regex --timeout 120000
herdr pane read "$NEW_PANE" --source recent --lines 50
```

### Check what another agent is doing

```bash
herdr pane list
herdr pane read 1-1 --source recent --lines 80
```

### Coordinate two pi sessions via herdr + intercom

```bash
# Spawn a named worker pane
herdr agent start reviewer --cwd "$PWD" -- pi
herdr wait output reviewer --match ">" --timeout 15000
```

Then from this pi session:
```typescript
intercom({ action: "send", to: "reviewer", message: "Review src/api/ for null-check gaps. Report findings via intercom when done." })
// ... later ...
herdr wait agent-status reviewer --status done --timeout 300000
```

## Rules

- Always check `HERDR_ENV=1` before using any herdr CLI command.
- Always use `--no-focus` on splits and workspace/tab creates unless focus change is explicitly requested.
- Re-read pane/tab/workspace IDs after any close operation — they compact.
- Parse new IDs from JSON responses (`result.pane.pane_id`, `result.tab`, `result.root_pane`).
- Prefer `herdr agent start` over manual `pane split + pane run pi` when you want a named, panel-tracked agent target.
- Use `pane read --source recent-unwrapped` when verifying what a `wait output` matched.
- Coordinate between pi sessions via intercom; use herdr only for pane/state management.
- Do not use herdr pane commands to substitute for `subagent()` for short-lived advisory work — in-process subagents are faster and better coordinated for that.
