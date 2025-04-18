import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["themeToggleButton"];
  static values = { userPreference: String }

  connect() {
    // First check for session preference, then user preference, then localStorage, then system preference
    this.loadTheme();
  }
  
  loadTheme() {
    // Priority order:
    // 1. Session (most recent)
    // 2. User preference (from profile)
    // 3. localStorage (previously chosen)
    // 4. System preference
    const sessionTheme = document.body.dataset.sessionTheme;
    const userPreference = this.hasUserPreferenceValue ? this.userPreferenceValue : null;
    const savedTheme = localStorage.getItem("theme");
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    let themeToUse;
    
    if (sessionTheme && ['light', 'dark'].includes(sessionTheme)) {
      themeToUse = sessionTheme;
    } else if (userPreference === 'light' || userPreference === 'dark') {
      themeToUse = userPreference;
    } else if (savedTheme && ['light', 'dark'].includes(savedTheme)) {
      themeToUse = savedTheme;
    } else if (userPreference === 'system' || !userPreference) {
      themeToUse = systemPrefersDark ? 'dark' : 'light';
    } else {
      themeToUse = 'light'; // Default fallback
    }
    
    this.setTheme(themeToUse);
  }

  toggleTheme() {
    const isDarkMode = document.documentElement.classList.contains("dark");
    const newTheme = isDarkMode ? "light" : "dark";
    this.setTheme(newTheme);
    
    // Update user preference if user is signed in
    if (document.querySelector('meta[name="user-signed-in"]')?.content === 'true') {
      this.updateUserThemePreference(newTheme);
    }
  }
  
  updateThemeFromSelect(event) {
    const selectedTheme = event.target.value;
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    // If system preference selected, use system preference
    if (selectedTheme === 'system') {
      this.setTheme(systemPrefersDark ? 'dark' : 'light');
    } else if (['light', 'dark'].includes(selectedTheme)) {
      this.setTheme(selectedTheme);
    }
    
    // Update user preference immediately
    if (document.querySelector('meta[name="user-signed-in"]')?.content === 'true') {
      this.updateUserThemePreference(selectedTheme);
    }
  }

  setTheme(theme) {
    const lightIcon = document.getElementById("light-icon");
    const darkIcon = document.getElementById("dark-icon");
    const themeLabel = document.getElementById("theme-label");

    if (theme === "dark") {
      document.documentElement.classList.add("dark");
      localStorage.setItem("theme", "dark");
      if (darkIcon) darkIcon.classList.remove("hidden");
      if (lightIcon) lightIcon.classList.add("hidden");
    } else {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("theme", "light");
      if (lightIcon) lightIcon.classList.remove("hidden");
      if (darkIcon) darkIcon.classList.add("hidden");
    }
  }
  
  updateUserThemePreference(theme) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    
    fetch('/settings/profile/update_theme', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      },
      body: JSON.stringify({ theme: theme })
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json();
    })
    .then(data => {
      if (data.success) {
        console.log(`Theme preference updated to ${theme}`);
      }
    })
    .catch(error => {
      console.error('Error updating theme preference:', error);
    });
  }
}
