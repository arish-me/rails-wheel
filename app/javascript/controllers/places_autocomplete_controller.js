import PlacesAutocomplete from 'stimulus-places-autocomplete'

export default class extends PlacesAutocomplete {
  connect() {
    super.connect()
    this.customizeAutocomplete()
  }

  customizeAutocomplete() {
    if (this.autocomplete) {
      // Customize the autocomplete options
      this.autocomplete.setOptions({
        types: ['(cities)'], // Only show cities, not full addresses
        fields: ['address_components', 'geometry'],
        componentRestrictions: { country: this.countryValue }
      })

      // Customize the dropdown styling
      this.customizeDropdown()
    }
  }

  customizeDropdown() {
    // Wait for the dropdown to be created
    setTimeout(() => {
      const pacContainer = document.querySelector('.pac-container')
      if (pacContainer) {
        // Remove Google branding and styling
        pacContainer.style.border = '1px solid #d1d5db'
        pacContainer.style.borderRadius = '0.375rem'
        pacContainer.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
        pacContainer.style.backgroundColor = 'white'
        pacContainer.style.fontFamily = 'inherit'
        pacContainer.style.fontSize = '0.875rem'
        pacContainer.style.zIndex = '9999'

        // Style individual items
        const pacItems = pacContainer.querySelectorAll('.pac-item')
        pacItems.forEach(item => {
          item.style.padding = '0.5rem 0.75rem'
          item.style.borderBottom = '1px solid #f3f4f6'
          item.style.cursor = 'pointer'
          item.style.fontSize = '0.875rem'
          item.style.color = '#374151'
          
          // Remove Google icons
          const icons = item.querySelectorAll('img, .pac-icon')
          icons.forEach(icon => icon.style.display = 'none')
          
          // Hover effect
          item.addEventListener('mouseenter', () => {
            item.style.backgroundColor = '#f9fafb'
          })
          item.addEventListener('mouseleave', () => {
            item.style.backgroundColor = 'white'
          })
        })
      }
    }, 100)
  }

  placeChanged() {
    // Call the parent method first
    super.placeChanged()
    
    // Show the selected location details
    this.showLocationDisplay()
  }

  showLocationDisplay() {
    const cityDisplay = document.getElementById('city-display')
    const stateDisplay = document.getElementById('state-display')
    const countryDisplay = document.getElementById('country-display')
    const locationDisplay = document.getElementById('location-display')

    if (cityDisplay && stateDisplay && countryDisplay && locationDisplay) {
      const city = this.cityTarget.value
      const state = this.stateTarget.value
      const country = this.countryTarget.value

      if (city && state && country) {
        cityDisplay.textContent = `City: ${city}`
        stateDisplay.textContent = `State: ${state}`
        countryDisplay.textContent = `Country: ${country}`
        locationDisplay.classList.remove('hidden')
      } else {
        locationDisplay.classList.add('hidden')
      }
    }
  }

  // Override the autocomplete options to only show cities
  get autocompleteOptions() {
    return {
      types: ['(cities)'], // Only show cities, not full addresses
      fields: ['address_components', 'geometry'],
      componentRestrictions: { country: this.countryValue }
    }
  }
} 