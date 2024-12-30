import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["themeToggleButton"];

  connect() {
    // Load saved theme or default to light
    const savedTheme = localStorage.getItem("theme") || "light";
    this.setTheme(savedTheme);
  }

  toggleTheme() {
    const isDarkMode = document.documentElement.classList.contains("dark");
    if (isDarkMode) {
      this.setTheme("light");
    } else {
      this.setTheme("dark");
    }
  }

  setTheme(theme) {
    const lightIcon = document.getElementById("light-icon");
    const darkIcon = document.getElementById("dark-icon");
    const themeLabel = document.getElementById("theme-label");

    if (theme === "dark") {
      document.documentElement.classList.add("dark");
      localStorage.setItem("theme", "dark");
      darkIcon.classList.remove("hidden");
      lightIcon.classList.add("hidden");
    } else {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("theme", "light");
      lightIcon.classList.remove("hidden");
      darkIcon.classList.add("hidden");
    }
  }
}
