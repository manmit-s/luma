/* ============================================================
   Luma — Privacy Policy
   Vanilla, dependency-free, no network requests.
   ============================================================ */

/* ------------------------------------------------------------
   1. Scroll progress bar + header density
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

    if (bar) {
      const ratio = max > 0 ? Math.min(1, Math.max(0, window.scrollY / max)) : 0;
      bar.style.transform = 'scaleX(' + ratio + ')';
    }

    // Tighten the glass pill once the page has moved, so it reads as
    // "floating above content" rather than "pinned to the top".
    if (header) {
      const scrolled = window.scrollY > 40;
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
   4. Click-to-copy package name
   ------------------------------------------------------------ */
(function copyPackage() {
  const button = document.querySelector('#copy-package');
  if (!button) return;

  const chip = button.closest('.chip');
  const live = document.querySelector('#copy-status');
  let timer = null;

  button.addEventListener('click', function () {
    const value = button.dataset.copy;

    // Fail silently when the Clipboard API is unavailable or denied —
    // file:// and locked-down contexts must not throw.
    if (!navigator.clipboard || typeof navigator.clipboard.writeText !== 'function') return;

    navigator.clipboard.writeText(value).then(function () {
      chip.classList.add('is-copied');
      if (live) live.textContent = 'Package name copied';
      window.clearTimeout(timer);
      timer = window.setTimeout(function () {
        chip.classList.remove('is-copied');
        if (live) live.textContent = '';
      }, 1500);
    }).catch(function () { /* Silently ignore. */ });
  });
})();

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