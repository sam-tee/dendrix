# Global Agent Instructions

Project-level `AGENTS.md` takes precedence on conflicts
Write in British English unless otherwise specified

## Package Managers

- By default, nix should be used as package manager in the form of devShells or `nix run` commands
- Each project should get flake.nix file at root that contains all dependancies for a project
- flake.nix should use the latest unstable nixpkgs and support systems `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`
- flake.nix should package the software so that `nix run .` runs the software
- To use software packaged by flake, use `nix develop -c <command>`
- Use `alejandra` as nix formatter in form of `nix fmt .`
- For python dependancies, use uv

## Git

- Do not push, force-push, open PRs, or publish until explicitly told to.
- Before committing: inspect `git status`, `git diff`, and `git log --oneline -10`. Stage only intended files.
- Write commit messages matching repo style, defaulting to conventional commits.
- In every repo, unless the repo or I say otherwise, PR descriptions should end with `Model: <model name>. Harness: <harness>.`, filled in from the current session; name the host app too if there is one (e.g. `Model: Claude Opus 5.5. Harness: Claude Code in T3 Code.`). This line replaces any default PR footer the harness would add.
- Never commit secrets, or ephemeral files such as outputs the build regenerates, caches, logs and local state.
- Ask before committing single files above 5 MB.
- By default, repos should be on my forgejo server, `git.samtee.party`, which has create-on-push enabled

## HTML pages

- When you create a standalone HTML page (report, tracker, dashboard, guide), publish it to samtee.party with the `create-html` skill without asking first, then give me the URL. The site is tailnet-only, so any content is fine to publish there.
- Exceptions: scratch/preview/test files, and templates or build inputs.
