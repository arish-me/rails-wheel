import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  submit(event) {
    // Store current scroll position
    sessionStorage.setItem('scrollToJobs', 'true')
  }

  connect() {
    // Check if we should scroll to jobs section after page load
    if (sessionStorage.getItem('scrollToJobs') === 'true') {
      sessionStorage.removeItem('scrollToJobs')

      // Wait for page to load, then scroll smoothly to jobs section
      setTimeout(() => {
        const jobsSection = document.getElementById('jobs-results')
        if (jobsSection) {
          jobsSection.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          })
        }
      }, 100)
    }
  }
}
