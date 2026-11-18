# Global Agent Instructions

Project-level `AGENTS.md` takes precedence on conflicts

## Package Managers

- By default, nix should be used as package manager in the form of devShells or `nix run` commands
- Each project should get flake.nix file at root that contains all dependancies for a project
- flake.nix should use nixos-26.05 and support systems `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`
- flake.nix should package the software so that `nix run .` runs the software
- To use software packaged by flake, use `nix develop -c <command>`
- Use `alejandra` as nix formatter in form of `nix fmt .`
- For python dependancies, use uv

## Git

- Do not commit, push, force-push, open PRs, or publish until explicitly told to.
- Before committing: inspect `git status`, `git diff`, and `git log --oneline -10`. Stage only intended files.
- Write concise commit messages matching repo style.
- Never commit secrets, large binaries or ephemeral files unless explicitly stated.

## HTML pages

- When you create a standalone HTML page (report, tracker, dashboard, guide), publish it to samtee.party with the `create-html` skill without asking first, then give me the URL. The site is tailnet-only, so any content is fine to publish there.
- Exceptions: scratch/preview/test files, and templates or build inputs.
