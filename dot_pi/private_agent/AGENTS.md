# Pi Global Context

## Code search

- Use `rg` for exact text or symbols and `fd` for file discovery.
- This Pi profile no longer has MCP or semantic-search adapter tools; do not assume those tools are available.

## Version control

- Prefer **jj** over git whenever a repo has a `.jj/` directory (colocated jj+git). Use `jj` commands (`jj new`, `jj commit`, `jj git push`, etc.) directly — fall back to `git` only in repos without `.jj/`.


## Code review — pick by audience/timing (they compose)

- **Human sign-off → `crit`**: inline comments a human reads/resolves on a diff,
  plan, running page, or local HTML. (`crit-cli` is the same tool's
  programmatic interface for agents authoring/replying to comments.)
- **Pre-PR sweep → fastly `code-review`**: final multi-dimension check before
  opening a PR (consistency, idiomatic Go, data correctness, security);
  strongest for Go/Fastly code.
