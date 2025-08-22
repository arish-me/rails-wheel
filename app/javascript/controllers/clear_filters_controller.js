import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clear(event) {
    // Store current scroll position
    sessionStorage.setItem('scrollToJobs', 'true')
  }
}
