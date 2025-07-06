// import { Controller } from "@hotwired/stimulus"

// export default class extends Controller {
//   static targets = ["input", "fileName", "uploadArea", "uploadText"]

//   connect() {
//     if (this.hasInputTarget) {
//       this.inputTarget.addEventListener("change", this.fileSelected.bind(this))
//     }

//     // Find the form element
//     this.form = this.element.closest("form")
//     if (this.form) {
//       this.form.addEventListener("turbo:submit-start", this.formSubmitting.bind(this))
//     }
//   }

//   disconnect() {
//     if (this.hasInputTarget) {
//       this.inputTarget.removeEventListener("change", this.fileSelected.bind(this))
//     }

//     if (this.form) {
//       this.form.removeEventListener("turbo:submit-start", this.formSubmitting.bind(this))
//     }
//   }

//   triggerFileInput() {
//     if (this.hasInputTarget) {
//       this.inputTarget.click()
//     }
//   }

//   fileSelected() {
//     if (this.hasInputTarget && this.inputTarget.files.length > 0) {
//       const fileName = this.inputTarget.files[0].name

//       if (this.hasFileNameTarget) {
//         // Find the paragraph element inside the fileName target
//         const fileNameText = this.fileNameTarget.querySelector('p')
//         if (fileNameText) {
//           fileNameText.textContent = fileName
//         }

//         this.fileNameTarget.classList.remove("hidden")
//       }

//       if (this.hasUploadTextTarget) {
//         this.uploadTextTarget.classList.add("hidden")
//       }


//     }
//   }

//   formSubmitting() {
//     if (this.hasFileNameTarget && this.hasInputTarget && this.inputTarget.files.length > 0) {
//       const fileNameText = this.fileNameTarget.querySelector('p')
//       if (fileNameText) {
//         fileNameText.textContent = `Uploading ${this.inputTarget.files[0].name}...`
//       }

//       // Change the icon to a loader
//       const iconContainer = this.fileNameTarget.querySelector('.lucide-file-text')
//       if (iconContainer) {
//         iconContainer.classList.add('animate-pulse')
//       }
//     }

//     if (this.hasUploadAreaTarget) {
//       this.uploadAreaTarget.classList.add("opacity-70")
//     }
//   }
// }

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["activity", "image", "source", "error"]
  static classes = ["visibility", "loading"]

  select(event) {
    const file = event.currentTarget.files[0]
    const objectUrl = window.URL.createObjectURL(file)

    this.imageTarget.src = objectUrl
    this.imageTarget.srcset = objectUrl
    this.sourceTargets.forEach(source => {
      source.srcset = objectUrl
    })

    this.imageTarget.classList.remove(this.visibilityClass)
    this.errorTarget.classList.add(this.visibilityClass)
  }

  start() {
    this.imageTarget.classList.add(this.loadingClass)
    this.activityTarget.classList.remove(this.visibilityClass)
    this.errorTarget.classList.add(this.visibilityClass)
  }

  error(event) {
    event.preventDefault()

    this.imageTarget.classList.remove(this.loadingClass)
    this.activityTarget.classList.add(this.visibilityClass)
    this.errorTarget.classList.remove(this.visibilityClass)
    console.error(event.detail.error)
  }
}
