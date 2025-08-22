import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener('scroll', this.handleScroll)
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll)
  }

  handleScroll() {
    if (window.scrollY > 300) {
      this.buttonTarget.style.opacity = '1'
      this.buttonTarget.style.pointerEvents = 'auto'
    } else {
      this.buttonTarget.style.opacity = '0'
      this.buttonTarget.style.pointerEvents = 'none'
    }
  }

  scrollToTop() {
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    })
  }
}
