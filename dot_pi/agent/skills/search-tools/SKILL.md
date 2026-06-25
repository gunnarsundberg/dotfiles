---
name: search-tools
description: "Search and explore code with the right tool for the job. Use rg for exact text/symbol matches, fd for file discovery, and the grepai MCP for semantic/intent search and call-graph tracing. Prefer these over bash grep/find."
---

## Pick the right search tool

| What you need | Tool |
|---|---|
| Find code by what it *does* / a concept | grepai MCP — `grepai_search` |
| Map function relationships (callers/callees/graph) | grepai MCP — `grepai_trace_*` |
| Find exact text, symbol, or pattern | `rg` (ripgrep) |
| Find files by name, extension, or path | `fd` |
| Read a specific file you've located | `read` |

Rule of thumb: **`rg`/`fd` for the literal, grepai for the conceptual.** Prefer
`rg` over `grep` and `fd` over `find` — they're faster and respect `.gitignore`.
You don't need grepai for a known symbol or filename; go straight to `rg`/`fd`.

---

## Semantic search & tracing — grepai (via MCP)

grepai indexes the *meaning* of code with embeddings. Use it for intent-based
questions and call-graph exploration. Call it through the MCP gateway, not the CLI.

**Requires an index.** The grepai MCP server only connects in a project that has
a `.grepai` index. If a repo isn't indexed yet:

```bash
grepai init      # initialize in the project root
grepai watch     # build/maintain the index (background daemon)
grepai status    # check index health
```

If grepai is unavailable or the project isn't indexed, **fall back to `rg`/`fd`**
with descriptive patterns — don't block on it.

### Using the grepai MCP tools

Discover and call them through the `mcp` tool:

```
mcp({ server: "grepai" })                       # list available tools
mcp({ describe: "grepai_search" })              # confirm arg schema
mcp({ tool: "grepai_search", args: '{"query": "user authentication flow"}' })
```

Available tools (from `grepai mcp-serve`):

- `grepai_search` — semantic code search from a natural-language query
- `grepai_trace_callers` — functions that call a symbol
- `grepai_trace_callees` — functions called by a symbol
- `grepai_trace_graph` — call graph around a symbol (supports depth)
- `grepai_index_status` — index health/statistics

### Good semantic queries

Describe behavior in plain English; don't pass bare symbols or single words.

- Good: "where is authentication handled?", "how are file chunks stored?",
  "request validation middleware", "config loading and validation"
- Bad: `func`, `error`, `HandleRequest` (use `rg` for exact symbols)

---

## Text search — `rg` (ripgrep)

For exact text, symbols, and patterns.

```bash
rg "func NewIndexer"          # exact symbol/text
rg -i "handlerequest"         # case-insensitive
rg "useState" -t ts           # scope by file type (-t go, -t py, -t rs, ...)
rg "authenticate" --glob "internal/**"   # scope by path
rg "TODO" -C 3                # context lines
rg -l "database"              # filenames only
rg --hidden "secret"          # include hidden files
rg -U "func.*\n.*error"       # multiline
rg "HandleRequest" --json     # structured output
```

---

## File discovery — `fd`

For finding files by name, extension, or path.

```bash
fd auth                       # name substring (case-insensitive)
fd -e go                      # by extension
fd -t f -e ts src/            # files only, in a directory
fd -t d migrations            # directories only
fd --hidden .env              # include dotfiles
fd -e go --exclude vendor     # exclude paths
fd -e go -x wc -l             # run a command on results
fd -e go | xargs rg "HandleRequest"   # combine: scope files, then search
```

---

## Recommended workflow

1. Conceptual question ("how does X work?") → `grepai_search` (if indexed).
2. Need call relationships → `grepai_trace_callers` / `_callees` / `_graph`.
3. Know the name/extension → `fd` to locate files.
4. Know the exact text/symbol → `rg` to find occurrences.
5. `read` the files the above surface.

## Keywords

search, grep, find, rg, ripgrep, fd, grepai, semantic search, code search,
natural language search, file discovery, text search, pattern matching,
call graph, callers, callees, function relationships, code exploration
