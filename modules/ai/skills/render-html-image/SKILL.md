---
name: render-html-image
description: Use when an HTML page, chart, or diagram must be shown inside a T3 Code thread but `html_render` does not display (OpenCode Code Mode, e.g. the `opencode2` provider), or when the user asks why inline HTML rendering is not working. Renders the page in T3's headless browser at reply width and embeds the PNG in the reply.
---

# Show an HTML page when inline `html_render` does not display

## When this applies

`html_render` returns success (an `attachmentId` and "Shown to the reader above your reply") but no frame appears in the thread.

Cause: T3 turns an `html_render` **tool call** into the inline frame. Under OpenCode **Code Mode** every T3 MCP call is nested inside the harness `execute` tool, so the only tool item T3 ever records is `execute` and there is nothing to render. Verified by reading the thread store: a thread on the classic `opencode` binary records items with `toolName: "t3-code_html_render"` (renders), while an `opencode2` thread records only `execute` / `read` / `skill` (no frame).

Detect it:

- T3 settings → `providerInstances.opencode.config.binaryPath` is `opencode2` (Code Mode), not `opencode`.
- `t3_thread_read` with `view:"activity"` shows no item whose `toolName` starts with `t3-code_`.

The **real fix** is outside this skill: point the OpenCode provider at the `opencode` binary, or have T3 pass `codemode: false` when it registers the `t3-code` MCP server (`client.mcp.add({name:"t3-code", config:{type:"remote", url, headers, oauth:false}})` in `app.asar` — no `codemode` field means opencode 2's default `true`). Until then, use the PNG fallback below.

## Build the page so the fallback looks right

- One self-contained document, inline `<style>`/`<script>`.
- T3 injects theme vars (`--foreground`, `--card`, `--border`, `--chart-1`…) **only** inside the inline frame. In a plain browser tab there are none, so never rely on them alone: give every `var(--x, fallback)` an adaptive fallback, e.g.
  `:root{--t3-fg:#161616;--t3-muted:#5c5c5c}` + `@media (prefers-color-scheme: dark){:root{--t3-fg:#e7e7e7;--t3-muted:#9aa0a6}}`,
  then `color: var(--foreground, var(--t3-fg))`. Without this the page is near-white text on white.
- Fluid width, no background on `html`/`body`, no outer card or banner title, fixed pixel heights for canvases.
- `create-html` and `ui-configuration` skills still apply for palette/contrast/accessibility.

## Render and embed

`file:` URLs are rejected by the preview browser; serve the file over loopback instead.

```sh
cd <dir-with-page> && (python3 -m http.server 8899 --bind 127.0.0.1 >/tmp/http8899.log 2>&1 &)
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8899/<page>.html
```

Then, inside `execute`:

1. `preview_open({ url: "http://127.0.0.1:8899/<page>.html", open: true, show: true })` → keep `tabId`.
2. `preview_set_appearance({ tabId, colorScheme: "dark" })` (or `"light"`) to match the reader's theme.
3. `preview_resize({ tabId, mode: "freeform", width: 728, height: <page height> })` — 728 px is the desktop reply column, ~375 px for phones; freeform height max 3840. Run `html_preview` first if you need the exact `contentHeight`.
4. `preview_snapshot({ tabId, includeImage: false, save: true })` → returns `screenshotPath`.

Embed that absolute path as an image in the reply: `![alt](/abs/path.png)`. Then stop the server (`pkill -f "http.server 8899"`) and `t3_preview_close({ tabId })`.

## Check before replying

- `read` the PNG and confirm it is readable: correct text color, nothing clipped, no horizontal cut-off. Re-shoot after fixing.
- Note in the reply that the image is static; give the file path for the interactive version.
- Do not use `t3_thread_send_attachments` for output: it posts a **user** message and starts a run.
- `browser.preview` / review-pane previews report `visible: false` on this client, so they are not a substitute.
