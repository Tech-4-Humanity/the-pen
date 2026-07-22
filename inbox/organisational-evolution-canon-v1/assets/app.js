(() => {
  document.documentElement.classList.add('js');
  const cards = document.querySelectorAll('.stages article');
  cards.forEach((card) => {
    card.addEventListener('keydown', (event) => {
      if (event.key !== 'ArrowRight' && event.key !== 'ArrowLeft') return;
      event.preventDefault();
      const list = [...cards];
      const current = list.indexOf(card);
      const delta = event.key === 'ArrowRight' ? 1 : -1;
      list[(current + delta + list.length) % list.length].focus();
    });
  });
})();
