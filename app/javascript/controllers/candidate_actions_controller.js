import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  addNote(event) {
    const candidateId = event.currentTarget.dataset.candidateId
    const note = prompt("Enter a note for this candidate:")
    
    if (note && note.trim()) {
      this.submitAction(`/company_candidates/${candidateId}/add_note`, {
        notes: note.trim()
      })
    }
  }

  updateStatus(event) {
    const candidateId = event.currentTarget.dataset.candidateId
    const status = prompt("Enter new status (active, inactive, shortlisted, rejected):")
    
    if (status && status.trim()) {
      this.submitAction(`/company_candidates/${candidateId}/update_status`, {
        status: status.trim()
      })
    }
  }

  viewApplications(event) {
    const candidateId = event.currentTarget.dataset.candidateId
    window.location.href = `/company_candidates/${candidateId}`
  }

  submitAction(url, data) {
    const formData = new FormData()
    Object.keys(data).forEach(key => {
      formData.append(key, data[key])
    })

    fetch(url, {
      method: 'PATCH',
      body: formData,
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (response.ok) {
        window.location.reload()
      } else {
        alert('An error occurred while processing your request.')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('An error occurred while processing your request.')
    })
  }
}
