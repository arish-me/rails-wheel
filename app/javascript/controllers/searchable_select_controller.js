import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]
  
  connect() {
    this.initializeSearchableSelects()
  }
  
  initializeSearchableSelects() {
    this.selectTargets.forEach(select => {
      // Check if the select already has Tom Select initialized
      if (select.tomSelect) return
      
      // Get the current selected value
      const selectedValue = select.value
      
      // Configuration options
      const options = {
        plugins: ['clear_button'],
        allowEmptyOption: true,
        create: false,
        // Maximum items that can be selected
        maxItems: 1,
        // Set a higher dropdown_content z-index to ensure it appears above other elements
        dropdownParent: 'body',
        // Set smaller load throttle for better performance
        loadThrottle: 100,
        // Highlight the option on hover for better UX
        render: {
          option: function(data, escape) {
            // Add a selected class if this option is currently selected
            const isSelected = data.value === selectedValue
            return `<div class="option-item${isSelected ? ' is-selected' : ''}">${data.text}</div>`
          },
          item: function(data, escape) {
            return `<div class="selected-item">${data.text}</div>`
          }
        },
        // Custom placeholder from data attribute or default
        placeholder: select.dataset.placeholder || 'Select an option...',
        // Highlight the selected option with a different color
        onInitialize: function() {
          // Add a custom class to the wrapper
          this.wrapper.classList.add('ts-custom-wrapper')
        },
        onItemAdd: function() {
          // Force a refresh of the dropdown to ensure proper highlighting
          if (this.dropdown_content) {
            this.refreshOptions(false)
          }
        },
        // Make sure the option is marked as selected in the dropdown
        onDropdownOpen: function(dropdown) {
          const selected = this.items[0] // Get the currently selected value
          if (selected) {
            // Find and mark the selected option
            const options = dropdown.querySelectorAll('.option')
            options.forEach(option => {
              const value = option.dataset.value
              if (value === selected) {
                option.classList.add('selected')
              }
            })
          }
        }
      }
      
      // Create Tom Select instance
      const tomSelect = new TomSelect(select, options)
      
      // Manually highlight the selected option if there's a value
      if (selectedValue) {
        // Wait for the dropdown to be fully initialized
        setTimeout(() => {
          // Force refresh to properly highlight the selected item
          tomSelect.refreshOptions(false)
        }, 100)
      }
    })
  }
  
  disconnect() {
    // Clean up Tom Select instances when the controller disconnects
    this.selectTargets.forEach(select => {
      if (select.tomSelect) {
        select.tomSelect.destroy()
      }
    })
  }
} 