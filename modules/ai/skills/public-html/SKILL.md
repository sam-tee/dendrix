---
name: public-html
description: Use only when user uses keyword "public" when creating page
---

# Publish a public HTML page

## Target

- Host `oracle` (`ssh oracle`), user `sam` with passwordless sudo. Docroot `/mnt/data/share` is **static files only**: each page is its own directory `<uuid>/` with `index.html` + colocated assets. No indexes, no nav tiles, no root `index.html`.
- Caddy serves docroot at `https://share.samtee.party/` via `file_server` (no directory browsing). Root `/` must stay empty and return `404`.
- **Favicon**: every HTML page MUST include `<link rel="icon" type="image/svg+xml" href="https://samtee.party/favicon.svg">` inside `<head>` — absolute URL to the main domain so no favicon file is needed under `/mnt/data/share`. Never add a second favicon link.
- Pages are standalone raw HTML with inline CSS/JS (each keeps its own look). No docs breadcrumbs, no tile-index edits — unlike `create-html`, there is nothing to register.
- Never publish secrets, credentials, private repo inventory, or datasets without explicit approval.

## Layout: uuid, then page

Every page lives at `<uuid>/` (`https://share.samtee.party/<uuid>/`). `<uuid>` is a random lowercase UUIDv4, e.g. `3f9d5c2a-1b4e-4f6a-9c2d-8e7a6b5c4d3e`.

- Generate with `uuidgen | tr '[:upper:]' '[:lower:]'`.
- Validate against `^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`, reject traversal, confirm resolved path stays under `/mnt/data/share`.

## Workflow

1. **Mint path.** Generate a UUID, check for collisions (`ssh oracle -- sudo -u media test -e /mnt/data/share/<uuid> && echo EXISTS`). Regenerate if it exists unless user requested an update to an existing UUID.
2. **Create HTML.** Stage under `/tmp/oracle-share/<uuid>/`. Single `index.html` with inline CSS/JS, relative asset links. Style via `ui-configuration` skill. Include the favicon link (see Target). No header/nav required; add a theme toggle only if the page needs one (if added, page CSS MUST honor `data-theme="light"` / `"dark"`).
3. **Install.** Create dest dir and install as `media:media` (`0755` dirs, `0644` files), e.g.:
   `ssh oracle -- sudo install -d -o media -g media -m 0755 /mnt/data/share/<uuid>`
   `ssh oracle -- sudo install -o media -g media -m 0644 <staged>/index.html /mnt/data/share/<uuid>/index.html`
   For multi-file pages, install each asset the same way (relative paths preserved). For approved updates, back up outside docroot first. Never put credentials in HTML, logs, or served files. Never write `/mnt/data/share/index.html`.
4. **Verify + report.** Fetch new page and assets over HTTPS. A `200` on HTML alone is insufficient — confirm assets load and the favicon link is present. Confirm `/` still returns `404`. Report `https://share.samtee.party/<uuid>/` (trailing slash; bare `<uuid>` redirects there).
