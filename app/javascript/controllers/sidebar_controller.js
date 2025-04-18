import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar"]

  connect() {
    // Handle sidebar state in localStorage
    const sidebarState = localStorage.getItem('sidebarState')
    if (sidebarState === 'hidden' && window.innerWidth >= 640) {
      this.hideSidebar()
    }
  }

  toggle() {
    const sidebarElement = document.getElementById('sidebar')
    if (sidebarElement.classList.contains('-translate-x-full')) {
      this.showSidebar()
    } else {
      this.hideSidebar()
    }
  }

  showSidebar() {
    const sidebarElement = document.getElementById('sidebar')
    sidebarElement.classList.remove('-translate-x-full')
    localStorage.setItem('sidebarState', 'visible')
  }

  hideSidebar() {
    const sidebarElement = document.getElementById('sidebar')
    sidebarElement.classList.add('-translate-x-full')
    localStorage.setItem('sidebarState', 'hidden')
  }
} 