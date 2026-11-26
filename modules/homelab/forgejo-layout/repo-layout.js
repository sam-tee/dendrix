// Repo pages: GitHub-style keyboard shortcuts, vim-style file list navigation, README tab detection,
// a code toolbar that never wraps, and the sidebar releases/contributors sections.
(() => {
  const repoTitle = document.querySelector('.repo-header .flex-item-title a:last-of-type');
  if (!repoTitle) return;

  const repoPath = repoTitle.pathname;
  const SEARCH_HASH = '#code-search';
  const HOTKEYS_OFF = 'repo-hotkeys-off';
  const SELECTED = 'repo-row-selected';

  const storage = {
    get(key) {
      try {
        return localStorage.getItem(key);
      } catch {
        return null;
      }
    },
    set(key, value) {
      try {
        if (value === null) localStorage.removeItem(key);
        else localStorage.setItem(key, value);
      } catch {}
    },
  };

  const searchInput = document.querySelector('.repository .code-search input[name="q"]');
  const readmeView = document.querySelector('.repo-readme-view');
  const readmeLink = document.querySelector('a[data-repo-readme-link]');
  const codeLink = document.querySelector('a[data-repo-code-link]');
  const overflowMenu = document.querySelector('.secondary-nav overflow-menu');
  const fileTable = document.querySelector('#repo-files-table');
  const canSearch = Boolean(searchInput && !searchInput.disabled);

  const isTyping = (target) =>
    target instanceof Element &&
    (target.isContentEditable || target.closest('input, textarea, select, [contenteditable], .monaco-editor, .cm-editor'));

  // README tab: outside a root listing the server can't tell, so the answer is cached per repo and ref.
  // Root listings record the server's answer; other pages check again once the entry is stale.
  // The key and format are shared with the inline script in repo/header.tmpl.
  const README_CACHE = 'repo-readme:';
  const README_TTL = 24 * 60 * 60 * 1000;
  const README_CACHE_MAX = 100;

  const readReadmeCache = (key) => {
    try {
      const entry = JSON.parse(storage.get(README_CACHE + key));
      return typeof entry?.found === 'boolean' && typeof entry.at === 'number' ? entry : null;
    } catch {
      return null;
    }
  };

  const writeReadmeCache = (key, found) => {
    storage.set(README_CACHE + key, JSON.stringify({found, at: Date.now()}));
    try {
      const keys = Object.keys(localStorage).filter((k) => k.startsWith(README_CACHE));
      if (keys.length <= README_CACHE_MAX) return;
      const age = (k) => readReadmeCache(k.slice(README_CACHE.length))?.at ?? 0;
      for (const k of keys.sort((a, b) => age(a) - age(b)).slice(0, keys.length - README_CACHE_MAX)) {
        localStorage.removeItem(k);
      }
    } catch {}
  };

  if (codeLink?.dataset.readmeCache) {
    writeReadmeCache(codeLink.dataset.readmeCache, codeLink.dataset.readmeFound === '1');
  }

  // Probes the common README.md first; otherwise looks where Forgejo does (the root, then docs/, .forgejo/
  // and .gitea/) in the full file list. The API ignores the web session, so both use web routes.
  const hasReadme = async (treeListUrl) => {
    const treeListPrefix = `${repoPath}/tree-list/`;
    if (!treeListUrl.startsWith(treeListPrefix)) return null;
    const ref = treeListUrl.slice(treeListPrefix.length);
    const probe = await fetch(`${repoPath}/raw/${ref}/README.md`, {method: 'HEAD', credentials: 'same-origin'});
    if (probe.ok) return true;

    const response = await fetch(treeListUrl, {credentials: 'same-origin', headers: {Accept: 'application/json'}});
    if (!response.ok) return null;
    const paths = await response.json();
    if (!Array.isArray(paths)) return null;
    const readmeDirs = new Set(['', 'docs', '.forgejo', '.gitea']);
    return paths.some((path) => {
      const slash = path.lastIndexOf('/');
      return readmeDirs.has(path.slice(0, Math.max(slash, 0)).toLowerCase()) && /^readme(\.|$)/i.test(path.slice(slash + 1));
    });
  };

  if (readmeLink?.dataset.readmeCheck) {
    const key = readmeLink.dataset.readmeCheck;
    const showReadmeTab = (found) => {
      if (readmeLink.hidden !== found) return;
      readmeLink.hidden = !found;
      overflowMenu?.updateItems?.();
    };
    const cached = readReadmeCache(key);
    // A commit's tree never changes, so its entry never goes stale.
    const isFresh = cached && (key.includes('/tree-list/commit/') || Date.now() - cached.at < README_TTL);
    if (cached) showReadmeTab(cached.found);
    if (!isFresh) {
      (async () => {
        const found = await hasReadme(key);
        if (found === null) return;
        writeReadmeCache(key, found);
        showReadmeTab(found);
      })().catch(() => {});
    }
  }

  if (canSearch) {
    const hint = document.createElement('kbd');
    hint.className = 'repo-search-kbd';
    hint.setAttribute('aria-hidden', 'true');
    hint.textContent = '/';
    searchInput.after(hint);
    searchInput.setAttribute('aria-keyshortcuts', '/');
    if (window.location.hash === SEARCH_HASH) {
      history.replaceState(null, '', window.location.pathname + window.location.search);
      searchInput.focus();
    }
  }

  // Tabs can sit in the overflow menu's popup, which is not in the document until opened.
  const findTab = (suffix) => {
    const scopes = [document.querySelector('.secondary-nav'), overflowMenu?.tippyContent].filter(Boolean);
    for (const scope of scopes) {
      const tab = [...scope.querySelectorAll('a[href]')].find((a) => a.pathname === repoPath + suffix);
      if (tab) return tab;
    }
    return null;
  };

  const visit = (link) => {
    if (link && !link.hidden) window.location.assign(link.href);
  };

  // File list (vim-style): j/k move, l/Enter open, h up a folder, gg/G first/last, Esc clears.
  const fileRows = () =>
    fileTable ? [...fileTable.querySelectorAll('tbody tr:not(.commit-list)')].filter((tr) => tr.querySelector('a[href]')) : [];
  const rowLink = (tr) => tr.querySelector('td.name a[href], a[href]');
  const selectedIndex = (rows) => rows.findIndex((tr) => tr.classList.contains(SELECTED));

  const selectRow = (rows, index) => {
    if (!rows.length) return;
    const target = rows[Math.max(0, Math.min(rows.length - 1, index))];
    for (const tr of rows) tr.classList.toggle(SELECTED, tr === target);
    rowLink(target).focus({preventScroll: true});
    target.scrollIntoView({block: 'nearest'});
  };

  const clearSelection = () => {
    for (const tr of fileRows()) tr.classList.remove(SELECTED);
  };

  document.addEventListener('focusin', (event) => {
    if (!(event.target instanceof Element) || !event.target.closest(`tr.${SELECTED}`)) clearSelection();
  });

  const moveSelection = (step) => {
    const rows = fileRows();
    const current = selectedIndex(rows);
    selectRow(rows, current === -1 ? (step > 0 ? 0 : rows.length - 1) : current + step);
  };

  const openSelected = () => {
    const rows = fileRows();
    const current = selectedIndex(rows);
    if (current !== -1) rowLink(rows[current]).click();
  };

  // From a directory listing use its ".." row; from a file (or its blame) go to the folder that holds it.
  const goUp = () => {
    const parentRow = fileTable?.querySelector('tr.has-parent a[href]');
    if (parentRow) {
      parentRow.click();
      return;
    }
    if (fileTable || readmeView) return;
    const {pathname} = window.location;
    const prefix = ['src', 'blame'].map((kind) => `${repoPath}/${kind}/`).find((p) => pathname.startsWith(p));
    if (!prefix) return;
    const rest = pathname.slice(prefix.length);
    const slash = rest.lastIndexOf('/');
    if (slash > 0) window.location.assign(`${repoPath}/src/${rest.slice(0, slash)}`);
  };

  const openBranchPicker = () => {
    const button = document.querySelector('.js-branch-tag-selector .branch-dropdown-button');
    if (!button) return;
    button.click();
    requestAnimationFrame(() => button.closest('.js-branch-tag-selector')?.querySelector('input')?.focus());
  };

  const goToFile = () => {
    if (codeLink?.pathname.startsWith(`${repoPath}/src/`)) {
      window.location.assign(codeLink.pathname.replace(`${repoPath}/src/`, `${repoPath}/find/`));
    }
  };

  const goTargets = {
    c: () => visit(codeLink),
    r: () => visit(readmeLink),
    i: () => visit(findTab('/issues')),
    p: () => visit(findTab('/pulls')),
    a: () => visit(findTab('/actions')),
    w: () => visit(findTab('/wiki')),
    b: () => visit(findTab('/projects')),
    g: () => selectRow(fileRows(), 0),
  };

  const shortcuts = [
    ['Site', [['/', 'Focus code search'], ['t', 'Go to file'], ['w', 'Switch branch or tag'], ['?', 'Show this help']]],
    [
      'Go to',
      [
        ['g c', 'Code'],
        ['g r', 'README'],
        ['g i', 'Issues'],
        ['g p', 'Pull requests'],
        ['g a', 'Actions'],
        ['g w', 'Wiki'],
        ['g b', 'Projects'],
      ],
    ],
    [
      'File list',
      [
        ['j / k', 'Next / previous entry'],
        ['l / Enter', 'Open entry'],
        ['h', 'Up one folder (or back to the folder from a file)'],
        ['g g / G', 'First / last entry'],
        ['Esc', 'Clear selection'],
      ],
    ],
  ];

  let helpDialog = null;
  const showHelp = () => {
    if (!helpDialog) {
      helpDialog = document.createElement('dialog');
      helpDialog.className = 'repo-hotkeys';
      helpDialog.setAttribute('aria-labelledby', 'repo-hotkeys-title');
      const title = document.createElement('h2');
      title.id = 'repo-hotkeys-title';
      title.textContent = 'Keyboard shortcuts';
      helpDialog.append(title);
      for (const [heading, rows] of shortcuts) {
        const section = document.createElement('section');
        const h3 = document.createElement('h3');
        h3.textContent = heading;
        const dl = document.createElement('dl');
        for (const [keys, label] of rows) {
          const dt = document.createElement('dt');
          for (const [i, key] of keys.split(' ').entries()) {
            if (key === '/' && i > 0) {
              dt.append(' / ');
              continue;
            }
            const kbd = document.createElement('kbd');
            kbd.textContent = key;
            dt.append(kbd);
          }
          const dd = document.createElement('dd');
          dd.textContent = label;
          dl.append(dt, dd);
        }
        section.append(h3, dl);
        helpDialog.append(section);
      }
      const toggle = document.createElement('label');
      toggle.className = 'repo-hotkeys-toggle';
      const checkbox = document.createElement('input');
      checkbox.type = 'checkbox';
      checkbox.checked = storage.get(HOTKEYS_OFF) === '1';
      checkbox.addEventListener('change', () => storage.set(HOTKEYS_OFF, checkbox.checked ? '1' : null));
      toggle.append(checkbox, ' Turn off single-key shortcuts (? still opens this list)');
      const close = document.createElement('button');
      close.type = 'button';
      close.className = 'ui small button';
      close.textContent = 'Close';
      close.addEventListener('click', () => helpDialog.close());
      const footer = document.createElement('div');
      footer.className = 'repo-hotkeys-footer';
      footer.append(toggle, close);
      helpDialog.append(footer);
      helpDialog.addEventListener('click', (event) => {
        if (event.target === helpDialog) helpDialog.close();
      });
      document.body.append(helpDialog);
    }
    helpDialog.showModal();
  };

  let pendingG = 0;
  document.addEventListener('keydown', (event) => {
    if (event.defaultPrevented || event.isComposing || event.ctrlKey || event.metaKey || event.altKey) return;
    if (isTyping(event.target) || document.querySelector('dialog[open], details.dropdown[open]')) return;

    const {key} = event;
    if (key === '?') {
      event.preventDefault();
      showHelp();
      return;
    }
    if (storage.get(HOTKEYS_OFF) === '1') return;

    if (pendingG && Date.now() - pendingG < 1000) {
      pendingG = 0;
      const action = goTargets[key];
      if (action) {
        event.preventDefault();
        action();
      }
      return;
    }
    pendingG = 0;

    const actions = {
      '/': canSearch
        ? () => {
            searchInput.focus();
            searchInput.select();
          }
        : readmeView && codeLink
          ? () => window.location.assign(codeLink.href + SEARCH_HASH)
          : null,
      t: goToFile,
      w: openBranchPicker,
      g: () => {
        pendingG = Date.now();
      },
      G: fileTable ? () => selectRow(fileRows(), Infinity) : null,
      j: fileTable ? () => moveSelection(1) : null,
      k: fileTable ? () => moveSelection(-1) : null,
      l: fileTable ? openSelected : null,
      h: goUp,
      Escape: fileTable ? () => {
        clearSelection();
        document.activeElement?.blur();
      } : null,
    };
    const action = actions[key];
    if (!action) return;
    if (key !== 'Escape' && key !== 'g') event.preventDefault();
    action();
  });

  // Hides whole toolbar items, least useful first, until the row fits on one line.
  const toolbar = document.querySelector('.repo-button-row:has(.repo-code-dropdown)');
  const sequence = toolbar?.firstElementChild;
  if (toolbar && sequence) {
    const DROPPED = 'repo-toolbar-dropped';
    const dropOrder = [
      ':scope > .repo-count[href$="/tags"]',
      ':scope > .repo-count[href$="/branches"]',
      ':scope > #new-pull-request',
      ':scope > .repo-count[href*="/commits/"]',
      ':scope > .ui.dropdown.button',
    ];
    const listed = dropOrder.map((selector) => sequence.querySelector(selector)).filter(Boolean);
    const rest = [...sequence.children]
      .filter((el) => el.tagName !== 'SCRIPT' && !el.matches('.js-branch-tag-selector') && !listed.includes(el))
      .reverse();
    const candidates = [...listed, ...rest];

    const fit = () => {
      for (const el of candidates) el.classList.remove(DROPPED);
      for (const el of candidates) {
        if (toolbar.scrollWidth <= toolbar.clientWidth) break;
        el.classList.add(DROPPED);
      }
    };
    toolbar.classList.add('repo-toolbar-fit');
    fit();
    new ResizeObserver(fit).observe(toolbar);
  }

  // One release card: the latest stable release, or the newest release when there is no stable one
  // (only pre-releases or drafts), where /releases/latest answers 404. The section stays hidden until filled.
  const releases = document.querySelector('.repo-releases[data-releases-url]');
  if (releases) {
    const firstRelease = async (url) => {
      const response = await fetch(url, {credentials: 'same-origin'});
      if (!response.ok) return null;
      const page = new DOMParser().parseFromString(await response.text(), 'text/html');
      const entry = page.querySelector('#release-list > li');
      const link = entry?.querySelector('h4 a[href]');
      return link ? {entry, link, base: response.url} : null;
    };
    (async () => {
      const base = releases.dataset.releasesUrl;
      const latest = await firstRelease(`${base}/latest`);
      const release = latest ?? (await firstRelease(`${base}?limit=1`));
      if (!release) return;
      const {entry, link} = release;
      const tagName = decodeURIComponent(link.getAttribute('href').split('/releases/tag/')[1] ?? '');
      const title = link.textContent.trim() || tagName;
      if (!title) return;
      const card = releases.querySelector('.repo-release-latest');
      card.setAttribute('href', new URL(link.getAttribute('href'), release.base).pathname);
      card.querySelector('.repo-release-name').textContent = title;
      const badge = card.querySelector('.repo-release-badge');
      if (!latest) {
        const label = entry.querySelector('h4 .ui.label')?.textContent.trim();
        if (label) {
          badge.textContent = label;
          badge.classList.add('repo-release-badge-pre');
        } else {
          badge.remove();
        }
      }
      const published = entry.querySelector('relative-time[datetime]')?.getAttribute('datetime');
      if (published) {
        const time = document.createElement('relative-time');
        time.setAttribute('datetime', published);
        time.setAttribute('prefix', '');
        time.setAttribute('tense', 'past');
        time.textContent = new Date(published).toLocaleDateString();
        card.querySelector('.repo-release-date').append(time);
      }
      releases.hidden = false;
    })().catch(() => {});
  }

  const contributors = document.querySelector('.repo-contributors[data-url]');
  if (!contributors) return;

  const MAX_SHOWN = 14;
  const MAX_ATTEMPTS = 4;

  const render = (data) => {
    const people = Object.entries(data)
      .filter(([key]) => key !== 'total')
      .map(([, person]) => person)
      .sort((a, b) => b.total_commits - a.total_commits);
    if (!people.length) return;

    contributors.querySelector('.repo-contributors-count').textContent = String(people.length);
    const list = contributors.querySelector('.repo-contributors-list');
    for (const person of people.slice(0, MAX_SHOWN)) {
      const item = document.createElement('li');
      const holder = document.createElement(person.home_link ? 'a' : 'span');
      if (person.home_link) holder.setAttribute('href', person.home_link);
      const label = `${person.name || person.login} (${person.total_commits})`;
      holder.setAttribute('data-tooltip-content', label);
      holder.setAttribute('aria-label', label);
      const avatar = document.createElement('img');
      avatar.setAttribute('src', person.avatar_link);
      avatar.setAttribute('alt', '');
      avatar.setAttribute('width', '32');
      avatar.setAttribute('height', '32');
      avatar.setAttribute('loading', 'lazy');
      avatar.className = 'ui avatar';
      holder.append(avatar);
      item.append(holder);
      list.append(item);
    }
    if (people.length > MAX_SHOWN) {
      const more = document.createElement('a');
      more.className = 'repo-contributors-more muted';
      more.setAttribute('href', contributors.querySelector('.repo-sidebar-heading a').getAttribute('href'));
      more.textContent = `+ ${people.length - MAX_SHOWN} more`;
      contributors.append(more);
    }
    contributors.hidden = false;
  };

  // The stats endpoint answers 202 while it computes them in the background.
  const load = async (attempt) => {
    const response = await fetch(contributors.dataset.url, {credentials: 'same-origin'});
    if (response.status === 202 && attempt < MAX_ATTEMPTS) {
      await new Promise((resolve) => setTimeout(resolve, 1500 * attempt));
      return load(attempt + 1);
    }
    if (response.ok && response.status !== 202) render(await response.json());
  };
  load(1).catch(() => {});
})();
