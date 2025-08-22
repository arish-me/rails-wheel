import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading"]

  connect() {
    // Show loading indicator when page loads with search/filter parameters
    const urlParams = new URLSearchParams(window.location.search)
    const hasFilters = urlParams.has('search') ||
                      urlParams.has('role_type') ||
                      urlParams.has('role_level') ||
                      urlParams.has('remote_policy') ||
                      urlParams.has('location') ||
                      urlParams.has('company_id') ||
                      urlParams.has('featured') ||
                      urlParams.has('sort')

    if (hasFilters) {
      // Hide loading after a short delay to show smooth transition
      setTimeout(() => {
        this.loadingTarget.style.display = 'none'
      }, 500)
    } else {
      this.loadingTarget.style.display = 'none'
    }
  }
}
