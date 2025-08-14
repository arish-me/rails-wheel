import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["worldwideCheckbox", "locationSection", "locationField"]
  static values = { 
    worldwide: Boolean,
    requireLocation: { type: Boolean, default: true }
  }

  connect() {
    this.toggleLocationSection()
  }

  worldwideChanged() {
    this.toggleLocationSection()
    this.updateValidation()
  }

  toggleLocationSection() {
    const isWorldwide = this.worldwideCheckboxTarget.checked
    
    if (isWorldwide) {
      this.locationSectionTarget.classList.add('opacity-50', 'pointer-events-none')
      this.locationFieldTarget.disabled = true
      this.locationFieldTarget.value = ''
    } else {
      this.locationSectionTarget.classList.remove('opacity-50', 'pointer-events-none')
      this.locationFieldTarget.disabled = false
    }
  }

  updateValidation() {
    const isWorldwide = this.worldwideCheckboxTarget.checked
    
    if (isWorldwide) {
      // Remove required validation when worldwide is true
      this.locationFieldTarget.removeAttribute('required')
      this.locationFieldTarget.classList.remove('border-red-300', 'focus:border-red-500', 'focus:ring-red-500')
      this.locationFieldTarget.classList.add('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
    } else {
      // Add required validation when worldwide is false
      if (this.requireLocationValue) {
        this.locationFieldTarget.setAttribute('required', 'required')
      }
    }
  }

  // Called before form submission to ensure validation
  beforeSubmit(event) {
    const isWorldwide = this.worldwideCheckboxTarget.checked
    
    if (!isWorldwide && this.requireLocationValue) {
      const locationValue = this.locationFieldTarget.value.trim()
      if (!locationValue) {
        event.preventDefault()
        this.locationFieldTarget.classList.add('border-red-300', 'focus:border-red-500', 'focus:ring-red-500')
        this.locationFieldTarget.classList.remove('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
        
        // Show error message
        this.showLocationError()
        return false
      }
    }
    
    return true
  }

  showLocationError() {
    // Remove existing error message if any
    const existingError = this.locationSectionTarget.querySelector('.location-error')
    if (existingError) {
      existingError.remove()
    }

    // Create and show error message
    const errorDiv = document.createElement('div')
    errorDiv.className = 'location-error mt-2 text-sm text-red-600'
    errorDiv.textContent = 'Please enter a job location or select "Worldwide"'
    
    this.locationFieldTarget.parentNode.appendChild(errorDiv)
  }
}
