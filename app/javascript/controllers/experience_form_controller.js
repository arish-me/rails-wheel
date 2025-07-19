import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="experience-form"
export default class extends Controller {
  static targets = ["endDateField", "currentJobCheckbox", "companyName", "description", "companyNameCount", "descriptionCount"]

  connect() {
    this.toggleEndDate()
    this.updateCharCount()
    if (this.hasCurrentJobCheckboxTarget) {
      this.currentJobCheckboxTarget.addEventListener('change', () => this.toggleEndDate())
    }
    if (this.hasCompanyNameTarget) {
      this.companyNameTarget.addEventListener('input', () => this.updateCharCount())
    }
    if (this.hasDescriptionTarget) {
      this.descriptionTarget.addEventListener('input', () => this.updateCharCount())
    }
  }

  toggleEndDate() {
    if (this.hasCurrentJobCheckboxTarget && this.hasEndDateFieldTarget) {
      if (this.currentJobCheckboxTarget.checked) {
        this.endDateFieldTarget.style.display = 'none';
        const input = this.endDateFieldTarget.querySelector('input');
        if (input) input.value = '';
      } else {
        this.endDateFieldTarget.style.display = 'block';
      }
    }
  }

  updateCharCount() {
    if (this.hasCompanyNameTarget && this.hasCompanyNameCountTarget) {
      this.companyNameCountTarget.textContent = `${this.companyNameTarget.value.length}/100`;
    }
    if (this.hasDescriptionTarget && this.hasDescriptionCountTarget) {
      this.descriptionCountTarget.textContent = `${this.descriptionTarget.value.length}/500`;
    }
  }
} 