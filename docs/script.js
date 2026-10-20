/* ============================================================
   Luma — Privacy Policy
  Vanilla, dependency-free.
   ============================================================ */

/* ------------------------------------------------------------
   1. Scroll progress bar + header density (the pill always stays put)
   ------------------------------------------------------------ */
(function scrollEffects() {
  const bar = document.querySelector('#progress-bar');
  const header = document.querySelector('#site-header');
  if (!bar && !header) return;

  let ticking = false;
  let lastScrolled = null;

  function paint() {
    const doc = document.documentElement;
    const max = doc.scrollHeight - window.innerHeight;
    const y = window.scrollY;

    if (bar) {
      const ratio = max > 0 ? Math.min(1, Math.max(0, y / max)) : 0;
      bar.style.transform = 'scaleX(' + ratio + ')';
    }

    // Tighten the glass pill once the page has moved, so it reads as
    // "floating above content" rather than "pinned to the top".
    if (header) {
      const scrolled = y > 40;
      if (scrolled !== lastScrolled) {
        header.classList.toggle('is-scrolled', scrolled);
        lastScrolled = scrolled;
      }
    }

    ticking = false;
  }

  // Throttle through rAF: scroll events fire far faster than paint.
  function request() {
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(paint);
  }

  window.addEventListener('scroll', request, { passive: true });
  window.addEventListener('resize', request, { passive: true });
  paint();
})();

/* ------------------------------------------------------------
   2. Active section tracking (side rail + top nav)
   ------------------------------------------------------------ */
(function activeSection() {
  const links = Array.prototype.slice.call(document.querySelectorAll('[data-toc]'));
  if (!links.length || !('IntersectionObserver' in window)) return;

  const targets = links
    .map(function (link) { return document.getElementById(link.dataset.toc); })
    .filter(Boolean);

  if (!targets.length) return;

  const visible = new Map();

  function setActive(id) {
    links.forEach(function (link) {
      if (link.dataset.toc === id) link.setAttribute('aria-current', 'true');
      else link.removeAttribute('aria-current');
    });
  }

  const observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) visible.set(entry.target.id, entry.boundingClientRect.top);
        else visible.delete(entry.target.id);
      });

      // The section whose top sits highest inside the activation band wins.
      let best = null;
      let bestTop = Infinity;
      visible.forEach(function (top, id) {
        if (top < bestTop) { bestTop = top; best = id; }
      });
      if (best) setActive(best);
    },
    // A thin band just above the vertical middle of the viewport.
    { rootMargin: '-40% 0px -55% 0px', threshold: 0 }
  );

  targets.forEach(function (target) { observer.observe(target); });
})();

/* ------------------------------------------------------------
   3. Reveal sections on first entry
   ------------------------------------------------------------ */
(function revealOnScroll() {
  const items = Array.prototype.slice.call(document.querySelectorAll('.reveal'));
  if (!items.length) return;

  // No observer support: show everything rather than hiding content forever.
  if (!('IntersectionObserver' in window)) {
    items.forEach(function (el) { el.classList.add('is-visible'); });
    return;
  }

  const observer = new IntersectionObserver(
    function (entries) {
      const arriving = entries.filter(function (entry) { return entry.isIntersecting; });

      arriving.forEach(function (entry, index) {
        // Stagger elements that arrive in the same frame so the page rises
        // as a group rather than snapping in all at once.
        window.setTimeout(function () {
          entry.target.classList.add('is-visible');
        }, index * 70);
        observer.unobserve(entry.target);
      });
    },
    { rootMargin: '0px 0px -10% 0px', threshold: 0.08 }
  );

  items.forEach(function (el) { observer.observe(el); });
})();

/* ------------------------------------------------------------
   4. Latest APK download
   ------------------------------------------------------------ */
document.addEventListener('DOMContentLoaded', async function () {
  const downloadButton = document.querySelector('#download-btn');
  if (!downloadButton) return;

  try {
    const response = await fetch('https://api.github.com/repos/manmit-s/luma/releases/latest');
    if (!response.ok) return;

    const release = await response.json();
    const apkAsset = Array.isArray(release.assets)
      ? release.assets.find(function (asset) {
        return typeof asset.name === 'string' && asset.name.toLowerCase().endsWith('.apk');
      })
      : null;

    if (!apkAsset || !apkAsset.browser_download_url) return;

    downloadButton.href = apkAsset.browser_download_url;
    const label = downloadButton.querySelector('span');
    if (label && release.tag_name) label.textContent = 'Download APK (' + release.tag_name + ')';
  } catch (error) {
    // Keep the fallback release page when GitHub is unavailable or rate limited.
  }
});

/* ------------------------------------------------------------
   5. Reset simulator
   ------------------------------------------------------------ */
(function resetSimulator() {
  const first = document.querySelector('#step-one');
  const second = document.querySelector('#step-two');
  const input = document.querySelector('#confirmation');
  const confirmButton = document.querySelector('#confirm-reset');
  const status = document.querySelector('#sim-status');
  const startButton = document.querySelector('#start-reset');
  const resetEverything = document.querySelector('#reset-everything');

  if (!first || !second || !input || !confirmButton || !status) return;

  const FOCUSABLE = [
    'a[href]',
    'button:not([disabled])',
    'input:not([disabled])',
    'select:not([disabled])',
    'textarea:not([disabled])',
    '[tabindex]:not([tabindex="-1"])'
  ].join(',');

  // Tracks which modal owns the keyboard while it is open.
  let openDialog = null;
  let lastFocused = null;

  function restoreFocus() {
    if (lastFocused && document.contains(lastFocused)) lastFocused.focus();
    lastFocused = null;
  }

  function open(modal, focusTarget) {
    lastFocused = document.activeElement;
    modal.classList.remove('hidden');
    openDialog = modal;
    const target = focusTarget || modal.querySelector('.dialog') || modal;
    if (target && typeof target.focus === 'function') target.focus();
  }

  function closeAll() {
    first.classList.add('hidden');
    second.classList.add('hidden');
    openDialog = null;
    restoreFocus();
  }

  /* --- step one --- */
  if (startButton) {
    startButton.addEventListener('click', function () {
      status.textContent = '';
      open(first, first.querySelector('.dialog'));
    });
  }

  /* --- step one → step two --- */
  if (resetEverything) {
    resetEverything.addEventListener('click', function () {
      first.classList.add('hidden');
      input.value = '';
      confirmButton.disabled = true;
      second.classList.remove('hidden');
      openDialog = second;
      // Land the caret in the field so the confirmation can be typed straight away.
      input.focus();
    });
  }

  /* --- enable the confirm button only on an exact match --- */
  input.addEventListener('input', function () {
    confirmButton.disabled = input.value.trim().toLowerCase() !== 'confirm';
  });

  // Enter inside the field should submit once the value is valid.
  input.addEventListener('keydown', function (event) {
    if (event.key === 'Enter' && !confirmButton.disabled) {
      event.preventDefault();
      confirmButton.click();
    }
  });

  /* --- cancel --- */
  Array.prototype.forEach.call(document.querySelectorAll('[data-cancel]'), function (button) {
    button.addEventListener('click', closeAll);
  });

  /* --- confirm --- */
  confirmButton.addEventListener('click', function () {
    second.classList.add('hidden');
    openDialog = null;
    status.textContent = 'Preview complete. No data was deleted.';
    restoreFocus();
  });

  /* --- backdrop click closes --- */
  [first, second].forEach(function (modal) {
    modal.addEventListener('click', function (event) {
      if (event.target === modal) {
        modal.classList.add('hidden');
        openDialog = null;
        restoreFocus();
      }
    });
  });

  /* --- Escape closes --- */
  document.addEventListener('keydown', function (event) {
    if (event.key !== 'Escape') return;
    if (first.classList.contains('hidden') && second.classList.contains('hidden')) return;
    closeAll();
  });

  /* --- focus trap --- */
  document.addEventListener('keydown', function (event) {
    if (event.key !== 'Tab' || !openDialog) return;

    const items = Array.prototype.slice.call(openDialog.querySelectorAll(FOCUSABLE));
    if (!items.length) return;

    const firstItem = items[0];
    const lastItem = items[items.length - 1];
    const current = document.activeElement;

    // Focus escaped to the dialog shell (or somewhere else entirely): pull it back.
    if (items.indexOf(current) === -1) {
      event.preventDefault();
      (event.shiftKey ? lastItem : firstItem).focus();
      return;
    }

    if (event.shiftKey && current === firstItem) {
      event.preventDefault();
      lastItem.focus();
    } else if (!event.shiftKey && current === lastItem) {
      event.preventDefault();
      firstItem.focus();
    }
  });
})();

/* ------------------------------------------------------------
   6. Mobile menu (glass dropdown panel)
   ------------------------------------------------------------ */
(function mobileMenu() {
  const header = document.querySelector('#site-header');
  const toggle = document.querySelector('#nav-toggle');
  const panel = document.querySelector('#nav-panel');
  if (!header || !toggle || !panel) return;

  function setOpen(open) {
    header.classList.toggle('is-menu-open', open);
    toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    toggle.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
  }

  toggle.addEventListener('click', function () {
    setOpen(!header.classList.contains('is-menu-open'));
  });

  // Choosing a destination dismisses the panel.
  panel.addEventListener('click', function (event) {
    if (event.target.closest('a')) setOpen(false);
  });

  // Escape dismisses the panel (dialogs handle their own Escape first).
  document.addEventListener('keydown', function (event) {
    if (event.key !== 'Escape') return;
    if (!header.classList.contains('is-menu-open')) return;
    if (document.querySelector('.modal:not(.hidden)')) return;
    setOpen(false);
    toggle.focus();
  });

  // Tapping outside the header dismisses the panel.
  document.addEventListener('click', function (event) {
    if (!header.classList.contains('is-menu-open')) return;
    if (!header.contains(event.target)) setOpen(false);
  });

  // A wider viewport has no use for the panel.
  window.addEventListener('resize', function () {
    if (window.innerWidth > 760) setOpen(false);
  });
})();

/* ------------------------------------------------------------
   7. Sliding active pill in the desktop nav
   ------------------------------------------------------------ */
(function navIndicator() {
  const nav = document.querySelector('#primary-nav');
  if (!nav) return;
  const pill = nav.querySelector('.nav__indicator');
  const links = Array.prototype.slice.call(nav.querySelectorAll('a[data-toc]'));
  if (!pill || !links.length) return;

  function current() {
    return links.filter(function (link) {
      return link.getAttribute('aria-current') === 'true';
    })[0] || null;
  }

  function move() {
    const active = current();
    // The pill only makes sense when the desktop nav is actually visible.
    if (!active || nav.offsetParent === null || nav.offsetWidth === 0) {
      pill.classList.remove('is-on');
      return;
    }
    pill.style.width = active.offsetWidth + 'px';
    pill.style.transform = 'translateX(' + active.offsetLeft + 'px)';
    pill.classList.add('is-on');
  }

  // `aria-current` is managed by the active-section tracker — follow it.
  if ('MutationObserver' in window) {
    const observer = new MutationObserver(move);
    links.forEach(function (link) {
      observer.observe(link, { attributes: true, attributeFilter: ['aria-current'] });
    });
  }

  window.addEventListener('resize', move, { passive: true });
  if (document.fonts && typeof document.fonts.ready.then === 'function') {
    document.fonts.ready.then(move).catch(function () { /* ignore */ });
  }
  window.addEventListener('load', move);
  move();
})();