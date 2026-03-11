# Filesystem Safety Rules

*IT IS CRITICAL* to NEVER use `find` or recursive `ls` commands on large directories like `www/`, `fbcode/`, `fbsource/`, or any top-level repository containing millions of files. These commands will hang for minutes or crash.

## Safe Alternatives

- **Code search**: Use `rg` (ripgrep) with specific paths, or `bgs`/`cbgs` for Meta internal repos
- **File finding**: Use `fd` with specific directories, not recursive from root
- **Code navigation**: Use the `meta:code_search` MCP tool when available
- **Direct access**: If you know the file path, just read it directly

## Rules for All Agents

- Never run `find /` or `find ~/fbsource` or similar
- Always scope searches to specific subdirectories
- Prefer targeted reads over broad searches
- If you need to explore a codebase, start with known entry points (README, BUCK files, __init__.py)
