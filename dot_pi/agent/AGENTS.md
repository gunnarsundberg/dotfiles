# Pi Global Context

## Searching code (`search-tools` skill)

- `rg` — exact text/symbols; `fd` — files. Prefer these over bash `grep`/`find`.
- grepai MCP (`grepai_search`, `grepai_trace_*`) — semantic search + call
  tracing, but **only in a repo with a `.grepai` index**. If unindexed or
  unavailable, fall back to `rg`/`fd` — don't block on it.

## Browser automation

- **cmux in use → `cmux-browser` skill**: drive cmux browser surfaces (open,
  interact, wait, extract).
- **Otherwise → chrome-devtools MCP**: interactive browser sessions when cmux
  isn't running.

## Web research (`pi-web-access`)

- `code_search` — API usage, library examples, debugging a specific error.
- `web_search` — everything else; use `queries: [...]` with varied angles for
  research breadth.
- `fetch_content` — extract a known URL / YouTube / repo (pass the user's
  question in `prompt` for video).
- `get_search_content` — only to re-read full content from a prior search/fetch.

## Subagent orchestration (`pi-subagents` skill)

- `pi-subagents` + `subagent()` is authoritative: async-by-default, named roles
  (`scout`/`planner`/`worker`/`reviewer`/`oracle`), keep builtin model defaults,
  `reviewer`/`/review-loop` for review fanout.
- Superpowers `subagent-driven-development` / `dispatching-parallel-agents` are
  conceptual only (fresh context per task, review loops, one writer thread);
  their Task-tool/template/script assumptions don't fit pi. On any conflict
  (async vs sync, model overrides, agent naming, review machinery),
  **`pi-subagents` governs.**
- Delegating to `worker`: attach `test-driven-development` +
  `verification-before-completion` (children don't inherit skills).
- Superpowers process skills still govern *how work is done*: `brainstorming`,
  `test-driven-development`, `systematic-debugging`, `writing-plans`,
  `verification-before-completion`.

## Code review — pick by audience/timing (they compose)

- **Human sign-off → `crit`**: inline comments a human reads/resolves on a diff,
  plan, running page, or local HTML. (`crit-cli` is the same tool's
  programmatic interface for agents authoring/replying to comments.)
- **Continuous agent review → Superpowers `requesting`/`receiving-code-review`
  (`reviewer` subagent)**: after each task, after a feature, before merge. The
  default mid-development gate.
- **Pre-PR sweep → fastly `code-review`**: final multi-dimension check before
  opening a PR (consistency, idiomatic Go, data correctness, security);
  strongest for Go/Fastly code.
