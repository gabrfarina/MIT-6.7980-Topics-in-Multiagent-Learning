(() => {
  document.addEventListener("click", event => {
    const button = event.target.closest(".solution-toggle");
    if (!button) return;
    const wrapper = button.closest(".solution-wrapper");
    if (!wrapper) return;
    const revealed = wrapper.classList.toggle("solution-revealed");
    button.textContent = revealed ? "Hide solution" : "Show solution";
    button.setAttribute("aria-expanded", String(revealed));
  });
})();
