import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "standardRadio", 
    "quickRadio", 
    "standardFields", 
    "resumeFile", 
    "fileInfo", 
    "fileName", 
    "submitButton"
  ]

  connect() {
    this.toggleStandardFields()
  }

  selectApplicationType(event) {
    const applicationType = event.currentTarget.dataset.applicationType
    
    if (applicationType === "standard") {
      this.standardRadioTarget.checked = true
    } else {
      this.quickRadioTarget.checked = true
    }
    
    this.toggleStandardFields()
  }

  toggleStandardFields() {
    const isQuickApply = this.quickRadioTarget.checked
    
    if (isQuickApply) {
      this.standardFieldsTarget.classList.add('hidden')
    } else {
      this.standardFieldsTarget.classList.remove('hidden')
    }
  }

  updateFileName(event) {
    const file = event.target.files[0]
    
    if (file) {
      this.fileNameTarget.textContent = `${file.name} (${this.formatFileSize(file.size)})`
      this.fileInfoTarget.classList.remove('hidden')
      
      // Validate file type
      if (!this.isValidFileType(file)) {
        this.showFileError('Please select a PDF, DOC, or DOCX file.')
        event.target.value = ''
        this.fileInfoTarget.classList.add('hidden')
        return
      }
      
      // Validate file size (10MB limit)
      if (file.size > 10 * 1024 * 1024) {
        this.showFileError('File size must be less than 10MB.')
        event.target.value = ''
        this.fileInfoTarget.classList.add('hidden')
        return
      }
      
      // Remove any existing error
      this.removeFileError()
    } else {
      this.fileInfoTarget.classList.add('hidden')
    }
  }

  isValidFileType(file) {
    const validTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ]
    return validTypes.includes(file.type)
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  showFileError(message) {
    this.removeFileError()
    
    const errorDiv = document.createElement('div')
    errorDiv.className = 'file-error mt-2 p-3 bg-red-50 border border-red-200 rounded-lg'
    errorDiv.innerHTML = `
      <div class="flex items-center">
        <svg class="w-5 h-5 text-red-500 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
        </svg>
        <span class="text-sm text-red-700">${message}</span>
      </div>
    `
    
    this.resumeFileTarget.parentNode.appendChild(errorDiv)
  }

  removeFileError() {
    const existingError = this.resumeFileTarget.parentNode.querySelector('.file-error')
    if (existingError) {
      existingError.remove()
    }
  }

  validateForm(event) {
    const isQuickApply = this.quickRadioTarget.checked
    
    if (!isQuickApply) {
      // Check if cover letter is provided
      const coverLetterField = this.element.querySelector('[name*="[cover_letter]"]')
      if (coverLetterField && !coverLetterField.value.trim()) {
        event.preventDefault()
        this.showFieldError(coverLetterField, 'Cover letter is required for standard applications.')
        return false
      }
      
      // Check if resume is uploaded
      if (!this.resumeFileTarget.files[0]) {
        event.preventDefault()
        this.showFieldError(this.resumeFileTarget, 'Resume is required for standard applications.')
        return false
      }
    }
    
    // Check if portfolio is required
    const portfolioField = this.element.querySelector('[name*="[portfolio_url]"]')
    if (portfolioField && portfolioField.hasAttribute('required') && !portfolioField.value.trim()) {
      event.preventDefault()
      this.showFieldError(portfolioField, 'Portfolio URL is required.')
      return false
    }
    
    return true
  }

  showFieldError(field, message) {
    // Remove existing error
    this.removeFieldError(field)
    
    // Add error styling
    field.classList.add('border-red-300', 'focus:border-red-500', 'focus:ring-red-500')
    field.classList.remove('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
    
    // Create error message
    const errorDiv = document.createElement('div')
    errorDiv.className = 'field-error mt-2 text-sm text-red-600'
    errorDiv.textContent = message
    
    // Insert after the field
    const fieldContainer = field.closest('.form-field') || field.parentNode
    fieldContainer.appendChild(errorDiv)
    
    // Scroll to error
    field.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }

  removeFieldError(field) {
    const existingError = field.parentNode.querySelector('.field-error')
    if (existingError) {
      existingError.remove()
    }
    
    field.classList.remove('border-red-300', 'focus:border-red-500', 'focus:ring-red-500')
    field.classList.add('border-gray-300', 'focus:border-blue-500', 'focus:ring-blue-500')
  }
}
