---
name: create-html
description: Use when creating and publishing standalone HTML pages.
---

# Create and publish an HTML page

## Target

- Host `oracle` (`ssh oracle`), user `sam` with passwordless sudo. Docroot `/mnt/data/www` is **static files**: homepage `index.html`, shared `style.css` (nav/tiles only), and `docs/` — each document its own directory with `index.html` + assets.
- Caddy serves docroot to domain `https://samtee.party/`
- **Favicon** (`/mnt/data/www/favicon.svg`, purple mug on black): every HTML page MUST include `<link rel="icon" type="image/svg+xml" href="/favicon.svg">` inside `<head>` — absolute path so it resolves at any depth. Never add a second favicon link; back up outside docroot before bulk edits.
- Article pages are standalone raw HTML with inline CSS/JS (each keeps its own look). Nav pages (`/`, `/docs/`, `/docs/<project>/`) share the tile style from `/style.css` — edit their tiles by hand, there is no generator.
- **Standard header** (every article, first thing in `<body>`): breadcrumbs left, theme toggle right, capped at text width — keep the exact pattern, substituting project/page/title (crumb itself unstyled apart from a flex safeguard; links inherit page styles):
  `<header class="doc-head" style="display:flex;align-items:center;justify-content:space-between;gap:12px;max-width:65ch;margin:0 auto 1rem;"><nav class="crumb" aria-label="Breadcrumb" style="min-width:0;"><a href="/">Home</a> / <a href="/docs/">Docs</a> / <a href="/docs/<project>/"><project></a> / <title></nav><button id="theme-toggle" type="button" style="flex:none;padding:10px 14px;border-radius:8px;border:1px solid #888;background:transparent;color:inherit;font:inherit;font-size:.85rem;cursor:pointer;min-height:44px;">Light mode</button></header>`
  Plus the toggle script before `</body>` (flips `document.documentElement.dataset.theme` light/dark, persists `docs-theme` in localStorage, restores on load, updates the label) — and page CSS MUST honor `data-theme="light"` / `"dark"` (explicit overrides, not just `prefers-color-scheme`), or the toggle is dead.
- Never publish loose top-level slugs.

## Layout: project, then page

Every article lives at `docs/<project>/<page>/` (`/docs/<project>/<page>/`). Breadcrumb: Home / Docs / `<project>` / `<page-title>`. `<project>` and `<page>` are short lowercase kebab-case slugs (`[a-z0-9]+(-[a-z0-9]+)*`).

Resolve `<project>` in this order:

1. **Remote git name if available** — canonical Forgejo repo name, not checkout dir. Run `git -C <dir> remote get-url origin`, take the basename, strip `.git`. E.g. checkout `site-temp` with remote `.../site.git` → project `site`; checkout `site2` with remote `.../site-concepts` → project `site-concepts`.
2. **Else dir name** — sanitized checkout basename (e.g. `server`, `openwrt` with no remote).
3. **Else general topic** — shared subject with no repo (e.g. `wifi`, `training`, `stt`), or `misc` for one-offs with no related pages.

Project beats subject grouping: a page about repo `mobile` goes under `docs/mobile/...` even if it is also about a topic. Prefer a fresh `page` over overwrite; preserve version/date suffixes.

## Routing

- Use remote git name for the project, not checkout dir name (see Layout).
- Project beats subject grouping. Here `topic` means subject (e.g. `wifi`, `training`, `stt`) and is only the fallback when steps 1–2 yield nothing.
- Never publish private repo inventory, secrets, or datasets without explicit approval.

## Workflow

1. **Select path.** Check for collisions. Change if destination exists unless user requested an update.
2. **Create HTML.** Stage under `/tmp/oracle-docs/<unique-name>/`. Inline CSS/JS, relative links. Style via `ui-configuration` skill. Include the standard header + toggle script (see Target) and the favicon link (see Target)."
3. **Install.** Validate slugs against `[a-z0-9]+(-[a-z0-9]+)*`, reject traversal, confirm resolved path stays under `/mnt/data/www`. Install as `media:media` (`0755` dirs, `0644` files), e.g.:
  `ssh oracle -- sudo install -o media -g media -m 0644 <staged>/index.html /mnt/data/www/docs/<project>/<page>/index.html`
  For approved updates, back up outside docroot first. Never put credentials in HTML, logs, or served files.
4. **Navigation.** Hand-edit the tile indexes (read before editing, don't erase unrelated entries):
  - New page: append a tile to `docs/<project>/index.html` (same `a.btn` markup: icon span, name, `<small>` subtitle).
  - New project: create `docs/<project>/index.html` in the same tile style and register the project tile in `docs/index.html`.
  - Homepage tile: edit the tiles in `/mnt/data/www/index.html` directly.
5. **Verify + report.** Fetch new page, parent index, and assets over HTTP as `media`-readable. A `200` on HTML alone is insufficient. Confirm the favicon link is present and `/favicon.svg` returns `200 image/svg+xml`. Report `https://<domain>/docs/<project>/<page>/`.
6. **Multi-file exhibits** (self-contained sites, nested subpages, colocated assets): install as directories under the page path — same URLs as single pages, no extra config.
