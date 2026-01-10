// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "popper";
import "bootstrap";

document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("sidebarToggle");
  const sidebar = document.getElementById("adminSidebar");

  if (toggle && sidebar) {
    toggle.addEventListener("click", () => {
      sidebar.classList.toggle("show");
    });
  }
});
