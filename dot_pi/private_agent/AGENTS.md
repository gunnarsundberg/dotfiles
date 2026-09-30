# Pi Global Context

## Code search

- Use `rg` for exact text or symbols and `fd` for file discovery.
- This Pi profile no longer has MCP or semantic-search adapter tools; do not assume those tools are available.

## Version control

- Prefer **jj** over git whenever a repo has a `.jj/` directory (colocated jj+git). Use `jj` commands (`jj new`, `jj commit`, `jj git push`, etc.) directly — fall back to `git` only in repos without `.jj/`.


## Code review

- **Work profiles only → Fastly `code-review`**: final multi-dimension check before opening a PR (consistency, idiomatic Go, data correctness, security); strongest for Go/Fastly code.
