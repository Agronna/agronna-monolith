// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "popper";
import "bootstrap";

document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("sidebarToggle");
  const sidebar = document.getElementById("adminSidebar");
  const closeBtn = document.getElementById("sidebarClose");
  const overlay = document.getElementById("sidebarOverlay");

  const openSidebar = () => {
    sidebar?.classList.add("show");
    overlay?.classList.add("show");
    toggle?.setAttribute("aria-expanded", "true");
    document.body.classList.add("sidebar-open");
  };

  const closeSidebar = () => {
    sidebar?.classList.remove("show");
    overlay?.classList.remove("show");
    toggle?.setAttribute("aria-expanded", "false");
    document.body.classList.remove("sidebar-open");
  };

  toggle?.addEventListener("click", () => {
    sidebar?.classList.contains("show") ? closeSidebar() : openSidebar();
  });
  closeBtn?.addEventListener("click", closeSidebar);
  overlay?.addEventListener("click", closeSidebar);
});
