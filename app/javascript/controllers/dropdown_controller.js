import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.closeMenu = this.closeMenu.bind(this)
    document.addEventListener('click', this.closeMenu)
  }

  disconnect() {
    document.removeEventListener('click', this.closeMenu)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle('hidden')
  }

  closeMenu(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden')
    }
  }
} 