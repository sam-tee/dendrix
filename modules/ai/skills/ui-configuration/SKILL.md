---
name: ui-configuration
description: Use when configuring, styling, or building any UI, HTML/CSS, or themed visual output. Enforces base16 theme.toml palette, WCAG contrast, responsive and accessible defaults. Combine with create-html skill when publishing.
---

# UI Configuration

## 1. Colors - source of truth

- Use ONLY colors from the base16 palette in `theme.toml`. Do not invent hex values.
- Read `theme.toml` in the current project first. If absent, fall back to the bundled `theme.toml` in this skill directory.
- Roles:
  - `base00-03` = backgrounds (default, lighter, selection, comments)
  - `base04-07` = foregrounds (text_alt, text, bright, brightest)
  - `base08-0F` = accents (red, orange, yellow, green, cyan, blue, magenta, violet)
- Use `base0E` as first accent unless semantic: `base08` errors, `base0B` success, `base0A` warnings, `base0D` links/info.
- Expose palette as CSS variables and use variables only:
  ```css
  :root { --base00: /* base00 from theme.toml */; --base05: /* ... */; --base0E: /* ... */; }
  ```

## 2. Contrast and color use

- Aim WCAG AAA (7:1 normal, 4.5:1 large ≥18pt / 14pt bold). AA (4.5:1 normal, 3:1 large) is minimum.
- If a pair only meets AA, warn explicitly: `Warning: base04 on base00 meets AA only, not AAA`.
- Prefer `base05-07` for body text. Avoid `base03-04` for body unless verified.
- Never signal by color alone. Pair status color with icon + text label.
- Ensure links, focus rings, placeholders, disabled states remain distinguishable in both themes.

## 3. Theming mechanics

- Support `prefers-color-scheme`: wire `[dark]` / `[light]` from `theme.toml` via `media` queries or `data-theme`.
- Support `prefers-contrast: more` and `forced-colors: active` - do not break outlines, links, or buttons.
- Test both themes side-by-side before shipping.

## 4. Typography and readability

- Monospace font should be `@monoFont@`, falling back to system monospace when unavailable
- Sans serif and serif font should be `@uiFont@`, falling back to system sans-serif when unavailable
- Body ≥16px, `line-height ≥1.5`.
- Text width: use page container `.wrap { max-width: 60rem; margin: 0 auto; padding: 0 1.25rem; }` with safe-area insets 
  (`padding-left/right: max(1.25rem, env(safe-area-inset-left/right))`), switching to `1.5rem` side padding at `≤640px`. 
  Wide content (tables, code) uses full container width with inner horizontal scroll, never page-level sideways scroll.
- Allow pinch-zoom - never set `maximum-scale=1` or `user-scalable=no`.
- Use real headings hierarchy, lists, tables with `th`/`scope`, sufficient paragraph spacing.

## 5. Layout and interaction

- Mobile-first responsive. No horizontal scroll at 320px. Tap targets ≥44px with visible spacing.
- Semantic HTML (`header/main/nav/footer/button/a/label`). Every input has an associated `label`.
- Visible `:focus-visible` using a high-contrast accent outline. Full keyboard operability - no mouse-only hover menus.
- Honor `prefers-reduced-motion: reduce` - disable smooth scroll, parallax, non-essential animation.
- Images need `alt`, decorative images `alt=""`. Provide empty / loading / error states, not blank screens.

## 6. Verify

- Check: keyboard-only pass, 200% zoom, both color schemes, contrast checker run.

## Default palette

The bundled `theme.toml` is the system theme (akhlus), linked from the
dendrix repo's `theme/theme.toml`. Read it for the current hex values rather
than relying on remembered ones.
