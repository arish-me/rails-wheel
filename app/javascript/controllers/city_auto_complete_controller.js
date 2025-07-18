// app/javascript/controllers/city_autocomplete_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  connect() {
    this.inputTarget.addEventListener("input", this.fetchSuggestions.bind(this))
  }

  fetchSuggestions() {
    const query = this.inputTarget.value
    if (query.length < 2) return

    fetch(`/locations/city_suggestions?q=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        // Render suggestions in a dropdown (implement as needed)
        this.showSuggestions(data)
      })
  }

  showSuggestions(cities) {
    // Render dropdown below input, handle click to select, etc.
    // You can use a library for a better UX!
  }
}