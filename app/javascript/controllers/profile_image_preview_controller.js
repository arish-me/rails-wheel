import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = [
    "attachedImage",
    "previewImage",
    "placeholderImage",
    "deleteProfileImage",
    "input",
    "clearBtn",
    "fileNameDisplay",
    "dropZone",
    "progressBar",
    "progressContainer",
    "uploadStatus"
  ];

  connect() {
    // Setup drag and drop handlers
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.addEventListener("dragover", this.handleDragOver.bind(this));
      this.dropZoneTarget.addEventListener("dragleave", this.handleDragLeave.bind(this));
      this.dropZoneTarget.addEventListener("drop", this.handleDrop.bind(this));
    }
  }

  disconnect() {
    // Clean up event listeners
    if (this.hasDropZoneTarget) {
      this.dropZoneTarget.removeEventListener("dragover", this.handleDragOver.bind(this));
      this.dropZoneTarget.removeEventListener("dragleave", this.handleDragLeave.bind(this));
      this.dropZoneTarget.removeEventListener("drop", this.handleDrop.bind(this));
    }
  }

  clearFileInput() {
    this.inputTarget.value = null;
    this.clearBtnTarget.classList.add("hidden");
    this.placeholderImageTarget.classList.remove("hidden");
    this.attachedImageTarget.classList.add("hidden");
    this.previewImageTarget.classList.add("hidden");
    this.deleteProfileImageTarget.value = "1";
    
    if (this.hasFileNameDisplayTarget) {
      this.fileNameDisplayTarget.textContent = "";
      this.fileNameDisplayTarget.classList.add("hidden");
    }
    
    if (this.hasProgressContainerTarget) {
      this.progressContainerTarget.classList.add("hidden");
    }
    
    if (this.hasUploadStatusTarget) {
      this.uploadStatusTarget.textContent = "";
      this.uploadStatusTarget.classList.add("hidden");
    }
    
    // Delete the avatar using Turbo
    this.deleteAvatarWithTurbo();
  }

  showFileInputPreview(event) {
    const file = event.target.files[0];
    if (!file) return;
    
    this.processSelectedFile(file);
  }
  
  handleDragOver(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dropZoneTarget.classList.add("border-blue-500", "bg-blue-50", "dark:bg-gray-600");
  }
  
  handleDragLeave(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dropZoneTarget.classList.remove("border-blue-500", "bg-blue-50", "dark:bg-gray-600");
  }
  
  handleDrop(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dropZoneTarget.classList.remove("border-blue-500", "bg-blue-50", "dark:bg-gray-600");
    
    const file = event.dataTransfer.files[0];
    if (!file || !file.type.match('image/(jpeg|png|jpg)')) return;
    
    this.inputTarget.files = event.dataTransfer.files;
    this.processSelectedFile(file);
  }
  
  processSelectedFile(file) {
    // Update UI
    this.placeholderImageTarget.classList.add("hidden");
    this.attachedImageTarget.classList.add("hidden");
    this.previewImageTarget.classList.remove("hidden");
    this.clearBtnTarget.classList.remove("hidden");
    this.deleteProfileImageTarget.value = "0";

    // Display file name if element exists
    if (this.hasFileNameDisplayTarget) {
      this.fileNameDisplayTarget.textContent = file.name;
      this.fileNameDisplayTarget.classList.remove("hidden");
    }

    // Create image preview
    const reader = new FileReader();
    reader.onload = (e) => {
      this.previewImageTarget.querySelector("img").src = e.target.result;
    };
    reader.readAsDataURL(file);
    
    // Show progress container
    if (this.hasProgressContainerTarget) {
      this.progressContainerTarget.classList.remove("hidden");
      this.progressBarTarget.style.width = "0%";
    }
    
    // Upload the file immediately
    this.uploadFile(file);
  }
  
  uploadFile(file) {
    // Get the upload URL from meta tag
    const directUploadUrl = document.querySelector('meta[name="direct-upload-url"]')?.content;
    
    if (!directUploadUrl) {
      console.error("Direct upload URL not found");
      return;
    }
    
    const upload = new DirectUpload(file, directUploadUrl, this);
    
    upload.create((error, blob) => {
      if (error) {
        this.handleUploadError(error);
      } else {
        this.handleUploadSuccess(blob);
      }
    });
  }
  
  // DirectUpload callbacks
  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", event => {
      const progress = event.loaded / event.total * 100;
      if (this.hasProgressBarTarget) {
        this.progressBarTarget.style.width = `${progress}%`;
      }
    });
  }
  
  handleUploadSuccess(blob) {
    // Update the status
    if (this.hasUploadStatusTarget) {
      this.uploadStatusTarget.textContent = "Upload complete";
      this.uploadStatusTarget.classList.remove("hidden", "text-red-500");
      this.uploadStatusTarget.classList.add("text-green-500");
    }
    
    // Hide progress after a delay
    setTimeout(() => {
      if (this.hasProgressContainerTarget) {
        this.progressContainerTarget.classList.add("hidden");
      }
    }, 1000);
    
    // Send form to update avatar with Turbo
    this.updateAvatarWithTurbo(blob.signed_id);
  }
  
  handleUploadError(error) {
    console.error("Error uploading file:", error);
    
    if (this.hasUploadStatusTarget) {
      this.uploadStatusTarget.textContent = "Upload failed: " + error;
      this.uploadStatusTarget.classList.remove("hidden", "text-green-500");
      this.uploadStatusTarget.classList.add("text-red-500");
    }
    
    if (this.hasProgressContainerTarget) {
      this.progressContainerTarget.classList.add("hidden");
    }
  }
  
  updateAvatarWithTurbo(blobId) {
    // Create a form to submit with Turbo
    const form = document.createElement("form");
    form.action = "/settings/profile/update_avatar";
    form.method = "post";
    form.setAttribute("data-turbo", "true");
    form.setAttribute("data-remote", "true");
    
    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const csrfInput = document.createElement("input");
    csrfInput.type = "hidden";
    csrfInput.name = "authenticity_token";
    csrfInput.value = csrfToken;
    form.appendChild(csrfInput);
    
    // Add method override for PATCH
    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "patch";
    form.appendChild(methodInput);
    
    // Add the blob ID
    const blobInput = document.createElement("input");
    blobInput.type = "hidden";
    blobInput.name = "avatar_blob_id";
    blobInput.value = blobId;
    form.appendChild(blobInput);
    
    // Set the Accept header for Turbo Stream response
    form.setAttribute("accept", "text/vnd.turbo-stream.html");
    
    // Append to body and submit
    document.body.appendChild(form);
    form.submit();
    
    // Remove the form after submission
    setTimeout(() => {
      form.remove();
    }, 1000);
  }
  
  deleteAvatarWithTurbo() {
    // Create a form to submit with Turbo
    const form = document.createElement("form");
    form.action = "/settings/profile/delete_avatar";
    form.method = "post";
    form.setAttribute("data-turbo", "true");
    form.setAttribute("data-remote", "true");
    
    // Add CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
    const csrfInput = document.createElement("input");
    csrfInput.type = "hidden";
    csrfInput.name = "authenticity_token";
    csrfInput.value = csrfToken;
    form.appendChild(csrfInput);
    
    // Add method override for DELETE
    const methodInput = document.createElement("input");
    methodInput.type = "hidden";
    methodInput.name = "_method";
    methodInput.value = "delete";
    form.appendChild(methodInput);
    
    // Set the Accept header for Turbo Stream response
    form.setAttribute("accept", "text/vnd.turbo-stream.html");
    
    // Append to body and submit
    document.body.appendChild(form);
    form.submit();
    
    // Remove the form after submission
    setTimeout(() => {
      form.remove();
    }, 1000);
  }
}
