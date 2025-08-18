import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAllText", "modal", "modalTitle", "modalContent", "selectedCount", "noteText", "statusSelect", "addNoteTemplate", "updateStatusTemplate", "exportTemplate"]

  connect() {
    this.selectedIds = new Set()
    this.currentAction = null
  }

  toggleSelection(event) {
    const checkbox = event.target
    const applicationId = checkbox.value

    if (checkbox.checked) {
      this.selectedIds.add(applicationId)
    } else {
      this.selectedIds.delete(applicationId)
    }

    this.updateSelectAllText()
  }

  toggleSelectAll() {
    const allChecked = this.checkboxTargets.every(checkbox => checkbox.checked)
    
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = !allChecked
      const applicationId = checkbox.value
      
      if (!allChecked) {
        this.selectedIds.add(applicationId)
      } else {
        this.selectedIds.delete(applicationId)
      }
    })

    this.updateSelectAllText()
  }

  updateSelectAllText() {
    const allChecked = this.checkboxTargets.every(checkbox => checkbox.checked)
    const someChecked = this.checkboxTargets.some(checkbox => checkbox.checked)
    
    if (allChecked) {
      this.selectAllTextTarget.textContent = "Deselect All"
    } else if (someChecked) {
      this.selectAllTextTarget.textContent = "Select All"
    } else {
      this.selectAllTextTarget.textContent = "Select All"
    }
  }

  addNote() {
    if (this.selectedIds.size === 0) {
      this.showAlert("Please select at least one application.")
      return
    }

    this.currentAction = 'add_note'
    this.showModal("Add Note", this.addNoteTemplateTarget.innerHTML)
  }

  updateStatus() {
    if (this.selectedIds.size === 0) {
      this.showAlert("Please select at least one application.")
      return
    }

    this.currentAction = 'update_status'
    this.showModal("Update Status", this.updateStatusTemplateTarget.innerHTML)
  }

  export() {
    if (this.selectedIds.size === 0) {
      this.showAlert("Please select at least one application.")
      return
    }

    this.currentAction = 'export'
    this.showModal("Export Applications", this.exportTemplateTarget.innerHTML)
  }

  showModal(title, content) {
    this.modalTitleTarget.textContent = title
    this.modalContentTarget.innerHTML = content
    this.selectedCountTarget.textContent = this.selectedIds.size
    this.modalTarget.classList.remove('hidden')
  }

  closeModal() {
    this.modalTarget.classList.add('hidden')
    this.currentAction = null
  }

  executeAction() {
    if (!this.currentAction) return

    const formData = new FormData()
    formData.append('bulk_action', this.currentAction)
    
    this.selectedIds.forEach(id => {
      formData.append('application_ids[]', id)
    })

    switch (this.currentAction) {
      case 'add_note':
        const noteText = this.noteTextTarget.value
        if (!noteText.trim()) {
          this.showAlert("Please enter a note.")
          return
        }
        formData.append('notes', noteText)
        break
        
      case 'update_status':
        const status = this.statusSelectTarget.value
        if (!status) {
          this.showAlert("Please select a status.")
          return
        }
        formData.append('status', status)
        break
        
      case 'export':
        const format = document.querySelector('input[name="export_format"]:checked').value
        formData.append('format', format)
        break
    }

    // Submit the form
    fetch('/company_candidates/bulk_actions', {
      method: 'POST',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.closeModal()
        this.clearSelection()
        window.location.reload()
      } else {
        this.showAlert(data.error || "An error occurred.")
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showAlert("An error occurred while processing your request.")
    })
  }

  clearSelection() {
    this.selectedIds.clear()
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = false
    })
    this.updateSelectAllText()
  }

  showAlert(message) {
    // You can implement a toast notification here
    alert(message)
  }
}
