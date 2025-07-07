import PlacesAutocomplete from 'stimulus-places-autocomplete'

export default class extends PlacesAutocomplete {
  static targets = ["address", "city", "state", "country"]

  connect() {
    console.log('Places autocomplete controller connecting...')
    this.initializeAutocomplete()
    
    // Listen for form re-render events
    document.addEventListener('turbo:render', this.handleFormRerender.bind(this))
    document.addEventListener('turbo:before-render', this.handleBeforeRender.bind(this))
  }

  disconnect() {
    console.log('Places autocomplete controller disconnecting...')
    this.cleanupAutocomplete()
    document.removeEventListener('turbo:render', this.handleFormRerender.bind(this))
    document.removeEventListener('turbo:before-render', this.handleBeforeRender.bind(this))
  }

  handleBeforeRender() {
    this.cleanupAutocomplete()
  }

  handleFormRerender() {
    // Re-initialize after form re-render
    setTimeout(() => {
      if (this.hasAddressTarget) {
        console.log('Re-initializing autocomplete after form re-render...')
        this.initializeAutocomplete()
      }
    }, 100)
  }

  // Manual re-initialization method for debugging
  reinitialize() {
    console.log('Manual re-initialization requested...')
    this.initializeAutocomplete()
  }

  cleanupAutocomplete() {
    if (this.autocomplete) {
      try {
        google.maps.event.clearInstanceListeners(this.autocomplete)
        this.autocomplete = null
      } catch (error) {
        console.warn('Error cleaning up autocomplete:', error)
      }
    }
  }

  initializeAutocomplete() {
    // Check if we have the required target
    if (!this.hasAddressTarget) {
      console.warn('Address target not found')
      return
    }

    // Check if Google Maps API is loaded
    if (typeof google !== 'undefined' && google.maps && google.maps.places) {
      this.setupAutocomplete()
    } else {
      // Wait for Google Maps API to load
      this.waitForGoogleMaps()
    }
  }

  waitForGoogleMaps() {
    let attempts = 0
    const maxAttempts = 20 // Increased attempts
    
    const checkGoogleMaps = () => {
      attempts++
      
      if (typeof google !== 'undefined' && google.maps && google.maps.places) {
        this.setupAutocomplete()
      } else if (attempts < maxAttempts) {
        setTimeout(checkGoogleMaps, 300) // Faster retry
      } else {
        console.warn('Google Maps API failed to load after multiple attempts')
      }
    }
    
    checkGoogleMaps()
  }

  setupAutocomplete() {
    try {
      // Clean up any existing autocomplete
      this.cleanupAutocomplete()

      // Initialize the autocomplete
      this.autocomplete = new google.maps.places.Autocomplete(this.addressTarget, {
        types: ['(cities)'], // Only show cities, not full addresses
        fields: ['address_components', 'geometry'],
        componentRestrictions: { country: this.countryValue || 'us' }
      })

      // Add event listeners
      this.autocomplete.addListener('place_changed', () => {
        this.placeChanged()
      })

      // Customize the dropdown styling
      this.customizeDropdown()
      
      console.log('Places autocomplete initialized successfully')
    } catch (error) {
      console.error('Error initializing Places autocomplete:', error)
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
    try {
      const place = this.autocomplete.getPlace()
      
      if (!place.geometry) {
        console.warn("No details available for input: '" + place.name + "'")
        return
      }

      // Clear previous values
      this.clearFields()

      // Extract address components
      for (const component of place.address_components) {
        const componentType = component.types[0]

        switch (componentType) {
          case "locality":
            this.cityTarget.value = component.long_name
            break
          case "administrative_area_level_1":
            this.stateTarget.value = component.short_name
            break
          case "country":
            this.countryTarget.value = component.short_name
            break
        }
      }

      // Show the selected location details
      this.showLocationDisplay()
      
      console.log('Place selected:', place.name)
    } catch (error) {
      console.error('Error processing place selection:', error)
    }
  }

  clearFields() {
    if (this.hasCityTarget) this.cityTarget.value = ''
    if (this.hasStateTarget) this.stateTarget.value = ''
    if (this.hasCountryTarget) this.countryTarget.value = ''
  }

  showLocationDisplay() {
    const cityDisplay = document.getElementById('city-display')
    const stateDisplay = document.getElementById('state-display')
    const countryDisplay = document.getElementById('country-display')
    const locationDisplay = document.getElementById('location-display')

    if (cityDisplay && stateDisplay && countryDisplay && locationDisplay) {
      const city = this.hasCityTarget ? this.cityTarget.value : ''
      const state = this.hasStateTarget ? this.stateTarget.value : ''
      const country = this.hasCountryTarget ? this.countryTarget.value : ''

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
}