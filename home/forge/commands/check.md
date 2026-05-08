---
name: check
description: >
  Run the project's lint and test commands. Fix every issue found,
  then re-run to confirm everything passes.
---

Run the project's lint and test commands.

Fix every issue found. After fixing, run the commands again to confirm
everything passes before returning.

If no lint or test commands are discoverable (no Makefile, package.json
scripts, go test, etc.), report that clearly rather than guessing.
