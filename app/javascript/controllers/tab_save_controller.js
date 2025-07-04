import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ ]

  connect() {
    this.element.addEventListener("turbo:frame-load", this.onFrameLoad.bind(this))
  }

  onFrameLoad(event) {
    // Find the next tab id from the loaded frame's id
    const frame = event.target
    const tabOrder = [
      "candidate_form_personal",
      "candidate_form_professional",
      "candidate_form_work"
    ]
    const currentIndex = tabOrder.indexOf(frame.id)
    if (currentIndex !== -1 && currentIndex < tabOrder.length - 1) {
      const nextTabId = tabOrder[currentIndex + 1].replace("candidate_form_", "")
      // Find the tab button and trigger click
      const navBtn = document.querySelector(`[data-id='${nextTabId}']`)
      if (navBtn) navBtn.click()
    }
  }
} 