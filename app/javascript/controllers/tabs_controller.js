import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    // Set initial active tab based on aria-selected attribute
    this.activeIndex = parseInt(this.tabTargets.findIndex(tab => tab.getAttribute("aria-selected") === "true"))
    if (this.activeIndex < 0) this.activeIndex = 0
    
    // Apply initial styling based on the active index
    this.applyActiveTabStyling()
  }

  switchTab(event) {
    const clickedTab = event.currentTarget
    const clickedIndex = parseInt(clickedTab.dataset.index)
    this.setActiveTab(clickedIndex)
  }

  setActiveTab(index) {
    // Don't do anything if index is out of bounds
    if (index < 0 || index >= this.tabTargets.length) return

    // Update the active index
    this.activeIndex = index

    // Update aria-selected for all tabs
    this.tabTargets.forEach((tab, i) => {
      const isActive = i === this.activeIndex
      tab.setAttribute("aria-selected", isActive)
      
      // Add/remove active classes
      if (isActive) {
        tab.classList.add("border-b-2", "border-blue-500", "text-blue-600", "dark:text-blue-400", "dark:border-blue-400")
        tab.classList.remove("text-gray-500", "hover:text-gray-700", "hover:border-gray-300", "dark:text-gray-400", "dark:hover:text-gray-300")
      } else {
        tab.classList.remove("border-b-2", "border-blue-500", "text-blue-600", "dark:text-blue-400", "dark:border-blue-400")
        tab.classList.add("text-gray-500", "hover:text-gray-700", "hover:border-gray-300", "dark:text-gray-400", "dark:hover:text-gray-300")
      }
    })

    // Show active panel and hide others
    this.panelTargets.forEach((panel, i) => {
      if (i === this.activeIndex) {
        panel.classList.remove("hidden")
        panel.classList.add("block")
      } else {
        panel.classList.add("hidden")
        panel.classList.remove("block")
      }
    })
  }

  // Apply appropriate styling to tabs based on the active index
  applyActiveTabStyling() {
    this.tabTargets.forEach((tab, i) => {
      const isActive = i === this.activeIndex
      
      // Make sure links within tabs work normally (don't intercept clicks)
      const link = tab.querySelector('a')
      if (link) {
        link.addEventListener('click', (e) => e.stopPropagation())
      }
    })
    
    // Show the active panel and hide others
    if (this.hasPanelTarget) {
      this.panelTargets.forEach((panel, i) => {
        if (i === this.activeIndex) {
          panel.classList.remove("hidden")
          panel.classList.add("block")
        } else {
          panel.classList.add("hidden")
          panel.classList.remove("block")
        }
      })
    }
  }
} 