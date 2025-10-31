(function () {
  document.addEventListener('DOMContentLoaded', function () {
    const container = document.getElementById('team');
    if (!container) {
      return;
    }

    const tabs = Array.from(container.querySelectorAll('.team-tab'));
    const panels = Array.from(container.querySelectorAll('.team-panel'));

    const activateTab = function (tab) {
      tabs.forEach(function (t) {
        const isActive = t === tab;
        t.classList.toggle('is-active', isActive);
        t.setAttribute('aria-selected', isActive ? 'true' : 'false');
      });

      const targetId = tab.getAttribute('aria-controls');
      panels.forEach(function (panel) {
        const isActive = panel.id === targetId;
        panel.classList.toggle('is-active', isActive);
        panel.toggleAttribute('hidden', !isActive);
      });
    };

    tabs.forEach(function (tab) {
      tab.addEventListener('click', function () {
        activateTab(tab);
      });
    });
  });
})();
