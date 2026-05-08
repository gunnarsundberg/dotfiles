---
name: search-tools
description: "Replaces ALL built-in search tools. You MUST invoke this skill BEFORE any search — semantic, text, or file. NEVER use built-in Grep, Glob, or Find tools. Use grepai for semantic/intent search, rg for text search, and fd for file discovery."
---

## CRITICAL: Tool Override for All Searches

This skill **REPLACES** all built-in search tools for every type of search.

**WRONG**:
- Using built-in `Grep` to find text or code patterns
- Using built-in `Glob` to find files by extension or pattern
- Using `find` to discover files
- Using built-in `Grep` to search by intent ("where is authentication handled?")

**CORRECT**:
- `grepai search` for semantic/intent-based code search
- `grepai trace` for call graph and function relationship search
- `rg` for exact text/pattern matching
- `fd` for file discovery

---

## Search Type Decision Guide

| What you need | Tool to use |
|---|---|
| Find code by what it *does* | `grepai search` |
| Understand function relationships | `grepai trace` |
| Find exact text, symbol, or pattern | `rg` |
| Find files by name, extension, or pattern | `fd` |

---

## Semantic Search — `grepai`

Use `grepai` when searching by **intent, concept, or functionality**.

### When to use grepai

- Finding code by what it does: "where is authentication handled?"
- Understanding how something works: "how does the indexer work?"
- Exploring functionality: "find error handling logic"
- Understanding code relationships: "what calls this function?"
- Implementation details: "how are vectors stored?"

### Semantic Search

```bash
# Natural language queries (always use English for best results)
grepai search "user authentication flow"
grepai search "error handling middleware"
grepai search "database connection pooling"
grepai search "API request validation"

# JSON output for structured results (--compact saves ~80% tokens)
grepai search "authentication flow" --json --compact

# Limit number of results
grepai search "error handling" -n 5
```

### Call Graph Tracing

```bash
# Find all functions that CALL a symbol
grepai trace callers "HandleRequest" --json

# Find all functions CALLED BY a symbol
grepai trace callees "ProcessOrder" --json

# Build complete call graph (both directions)
grepai trace graph "ValidateToken" --depth 3 --json
```

### grepai Best Practices

**Do:**
```bash
grepai search "How are file chunks created and stored?"
grepai search "Vector embedding generation process"
grepai search "Configuration loading and validation"
grepai trace callers "Search" --json
```

**Don't:**
```bash
grepai search "func"            # Too vague
grepai search "error"           # Too generic
grepai search "HandleRequest"   # Use rg for exact symbol matches
```

### grepai Fallback

If grepai fails (index not built, embedder unavailable), fall back to `rg` with descriptive patterns.
- Index not built: run `grepai watch` to build/update the index
- Embedder not available: check Ollama is running or OpenAI API key is set

---

## Text Search — `rg` (ripgrep)

Use `rg` for **exact text, symbol, or pattern matching**. Always prefer `rg` over `grep`.

### Common Usage

```bash
# Exact symbol or text match
rg "func NewIndexer"
rg "configPath"

# Search specific file types
rg "import.*cobra" -t go
rg "useState" -t ts

# Case-insensitive
rg -i "handlerequest"

# Show context lines
rg "TODO" -C 3

# Search only filenames matching a glob
rg "authenticate" --glob "*.go"

# JSON output for structured results
rg "HandleRequest" --json

# List files containing a match (no line content)
rg -l "database"

# Search hidden files/dirs too
rg --hidden "secret"

# Multiline match
rg -U "func.*\n.*error"
```

### rg Best Practices

- Use `-t <lang>` to scope to a file type (e.g., `-t go`, `-t py`, `-t ts`, `-t rs`)
- Use `--glob` for path-based scoping (e.g., `--glob "internal/**"`)
- Use `-l` when you only need file names, not match content
- Use `--json` when processing results programmatically
- Prefer `rg` over `grep` always — it's faster, respects `.gitignore`, and handles binary files

---

## File Discovery — `fd`

Use `fd` for **finding files by name, extension, or pattern**. Always prefer `fd` over `find`.

### Common Usage

```bash
# Find files by name (substring match, case-insensitive by default)
fd auth
fd config

# Find by exact extension
fd -e go
fd -e ts
fd -e json

# Find by file type (f=file, d=directory, l=symlink)
fd -t f "*.test.go"
fd -t d "migrations"

# Include hidden files
fd --hidden .env

# Search in a specific directory
fd -e go src/

# Exclude directories
fd -e go --exclude vendor

# Execute a command on results
fd -e go -x wc -l

# Combine with rg: find all Go files then search within them
fd -e go | xargs rg "HandleRequest"
```

### fd Best Practices

- Use `-e <ext>` for extension filtering — cleaner than glob patterns
- Use `-t f` to restrict to files only (avoids matching directory names)
- Use `--hidden` when you need to include dotfiles/dotdirs
- Use `-x` to execute commands on matched files

---

## Recommended Workflow

1. **Start with `grepai search`** for semantic exploration ("how does X work?")
2. **Use `grepai trace`** to map function relationships
3. **Use `fd`** to locate relevant files by name or extension
4. **Use `rg`** for exact text/symbol searches within known files
5. **Use `read`** to examine specific files surfaced by the above

---

## Quick Reference

```bash
# Semantic
grepai search "authentication flow" --json --compact
grepai trace callers "MyFunc" --json

# Text
rg "exact symbol" -t go
rg -l "pattern"                     # files only
rg "pattern" --glob "src/**"

# Files
fd -e go
fd config -t f
fd --hidden .env
```

## Keywords

search, grep, find, rg, ripgrep, fd, fzf, grepai, semantic search, code search,
natural language search, file discovery, text search, pattern matching, exact match,
call graph, callers, callees, function relationships, code exploration, codebase research,
intent search, grep replacement, find replacement
