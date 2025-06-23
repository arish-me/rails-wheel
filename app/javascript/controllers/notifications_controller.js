import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["button", "notificationsList"] // Keep this

  connect() {
    console.log("Notifications controller connected")

    // Close dropdown when clicking outside
    document.addEventListener("click", this.handleClickOutside.bind(this))

    // Subscribe to notifications channel
    this.subscription = consumer.subscriptions.create("Noticed::NotificationChannel", {
      connected: () => {
        console.log("Successfully connected to Noticed::NotificationChannel")
      },
      disconnected: () => {
        console.log("Disconnected from Noticed::NotificationChannel")
      },
      received: this.handleNotification.bind(this)
    })
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside.bind(this))
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    // Find the dialog element and trigger its open method
    const dialog = this.element.querySelector("[data-dialog-target='drawer']")
    if (dialog) {
      const dialogController = this.application.getControllerForElementAndIdentifier(dialog, "dialog")
      if (dialogController) {
        dialogController.open() // This opens the pop-up

        // *** IMPORTANT ***
        // After the dialog opens, the notificationsList should be in the DOM.
        // You might need a slight delay or to ensure the dialog.open() is synchronous,
        // but typically the element will be available right after.
        // If the dialog opens asynchronously, consider an event from the dialog controller
        // or a small setTimeout here. For now, assume it's synchronous enough.

        // Immediately after opening, ensure the list is visible
        if (this.hasNotificationsListTarget) {
          this.notificationsListTarget.classList.remove("hidden");
        }
      }
    }
  }

  handleClickOutside(event) {
    // Check if the click was outside of *this* controller's element
    // and if the notificationsListTarget exists and is not already hidden.
    // Also, ensure the notifications list itself (the pop-up content) is hidden, not just the parent.
    if (!this.element.contains(event.target)) {
        // Only attempt to hide if the target exists
        if (this.hasNotificationsListTarget) {
            this.notificationsListTarget.classList.add("hidden");
        }
        // If you have a separate Stimulus Dialog controller, it might also have a close method to call here
        const dialog = this.element.querySelector("[data-dialog-target='drawer']");
        if (dialog) {
            const dialogController = this.application.getControllerForElementAndIdentifier(dialog, "dialog");
            if (dialogController && typeof dialogController.close === 'function') {
                dialogController.close();
            }
        }
    }
  }

  handleNotification(data) {
    console.log("Received notification:", data);

    // Update unread count
    const countBadge = this.buttonTarget?.querySelector("span");
    if (countBadge) {
      const currentCount = parseInt(countBadge.textContent);
      countBadge.textContent = currentCount + 1;
    } else if (this.buttonTarget) {
      const badge = document.createElement("span");
      badge.className = "absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full";
      badge.textContent = "1";
      this.buttonTarget.appendChild(badge);
    }

    // *** IMPORTANT: Only try to update the notifications list if the target exists ***
    // if (!this.hasNotificationsListTarget) {
    //   // If the list isn't currently in the DOM (i.e., pop-up is closed),
    //   // we just update the count. The new notification will appear when the pop-up is opened next.
    //   console.warn("notificationsListTarget not found. Notification will appear on next pop-up open.");
    //   return; // Exit if the target isn't available
    // }

    // // Now that we know notificationsListTarget exists, find the inner div
    // // Make sure your HTML for notificationsListTarget has a child with class "divide-y"
    // const notificationsListContainer = this.notificationsListTarget.querySelector(".divide-y");

    // if (notificationsListContainer) {
    //   const notificationHtml = this.createNotificationHtml(data);
    //   notificationsListContainer.insertAdjacentHTML("afterbegin", notificationHtml);
    // } else {
    //   console.error("Could not find '.divide-y' element inside notificationsListTarget.");
    // }
  }

  createNotificationHtml(data) {
    return `
      <div class="p-4 hover:bg-gray-50 bg-blue-50">
        <div class="flex items-start">
          <div class="flex-1">
            <p class="text-sm text-gray-900">${data.message}</p>
            <p class="mt-1 text-xs text-gray-500">Just now</p>
          </div>
          <button
            class="ml-2 text-xs text-blue-600 hover:text-blue-800"
            data-action="click->notifications#markAsRead"
            data-notification-id="${data.id}">
            Mark as read
          </button>
        </div>
      </div>
    `
  }

  async markAsRead(event) {
    event.preventDefault()
    const notificationId = event.currentTarget.dataset.notificationId

    try {
      const response = await fetch(`/notifications/${notificationId}/mark_as_read`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })

      if (response.ok) {
        // Update UI
        const notification = event.currentTarget.closest(".p-4")
        notification.classList.remove("bg-blue-50")
        event.currentTarget.remove()

        // Update unread count
        const countBadge = this.buttonTarget.querySelector("span")
        if (countBadge) {
          const currentCount = parseInt(countBadge.textContent)
          if (currentCount > 1) {
            countBadge.textContent = currentCount - 1
          } else {
            countBadge.remove()
          }
        }
      }
    } catch (error) {
      console.error("Error marking notification as read:", error)
    }
  }
}

// import { Controller } from "@hotwired/stimulus"
// import consumer from "channels/consumer"

// export default class extends Controller {
//   static targets = ["button", "notificationsList"]

//   connect() {
//     console.log("Notifications controller connected")

//     // Close dropdown when clicking outside
//     document.addEventListener("click", this.handleClickOutside.bind(this))

//     // Subscribe to notifications channel
//     this.subscription = consumer.subscriptions.create("Noticed::NotificationChannel", {
//       connected: () => {
//         console.log("Successfully connected to Noticed::NotificationChannel")
//       },
//       disconnected: () => {
//         console.log("Disconnected from Noticed::NotificationChannel")
//       },
//       received: this.handleNotification.bind(this)
//     })
//   }

//   disconnect() {
//     document.removeEventListener("click", this.handleClickOutside.bind(this))
//     if (this.subscription) {
//       this.subscription.unsubscribe()
//     }
//   }

//   toggle(event) {
//     event.preventDefault()
//     event.stopPropagation()

//     // Find the dialog element and trigger its open method
//     const dialog = this.element.querySelector("[data-dialog-target='drawer']")
//     if (dialog) {
//       const dialogController = this.application.getControllerForElementAndIdentifier(dialog, "dialog")
//       if (dialogController) {
//         dialogController.open()
//       }
//     }
//   }

//   handleClickOutside(event) {
//     if (!this.element.contains(event.target)) {
//       document.getElementById("notificationsList").classList.add("hidden")
//       // this.notificationsListTarget.classList.add("hidden")
//     }
//   }

//   handleNotification(data) {
//     console.log("Received notification:", data);

//     // Update unread count
//     const countBadge = this.buttonTarget?.querySelector("span");
//     if (countBadge) {
//       const currentCount = parseInt(countBadge.textContent);
//       countBadge.textContent = currentCount + 1;
//     } else if (this.buttonTarget) {
//       const badge = document.createElement("span");
//       badge.className = "absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full";
//       badge.textContent = "1";
//       this.buttonTarget.appendChild(badge);
//     }

//     // Only try to update the notifications list if the target exists
//     // if (!this.hasNotificationsListTarget) {
//     //   return;
//     // }

//     //const notificationsList = this.notificationsListTarget.querySelector(".divide-y");

//     const notificationsList = document.getElementById("notificationsList").querySelector(".divide-y");

//     if (notificationsList) {
//       const notificationHtml = this.createNotificationHtml(data);
//       notificationsList.insertAdjacentHTML("afterbegin", notificationHtml);
//     }
//   }

//   createNotificationHtml(data) {
//     return `
//       <div class="p-4 hover:bg-gray-50 bg-blue-50">
//         <div class="flex items-start">
//           <div class="flex-1">
//             <p class="text-sm text-gray-900">${data.message}</p>
//             <p class="mt-1 text-xs text-gray-500">Just now</p>
//           </div>
//           <button
//             class="ml-2 text-xs text-blue-600 hover:text-blue-800"
//             data-action="click->notifications#markAsRead"
//             data-notification-id="${data.id}">
//             Mark as read
//           </button>
//         </div>
//       </div>
//     `
//   }

//   async markAsRead(event) {
//     event.preventDefault()
//     const notificationId = event.currentTarget.dataset.notificationId

//     try {
//       const response = await fetch(`/notifications/${notificationId}/mark_as_read`, {
//         method: "POST",
//         headers: {
//           "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
//           "Accept": "application/json"
//         }
//       })

//       if (response.ok) {
//         // Update UI
//         const notification = event.currentTarget.closest(".p-4")
//         notification.classList.remove("bg-blue-50")
//         event.currentTarget.remove()

//         // Update unread count
//         const countBadge = this.buttonTarget.querySelector("span")
//         if (countBadge) {
//           const currentCount = parseInt(countBadge.textContent)
//           if (currentCount > 1) {
//             countBadge.textContent = currentCount - 1
//           } else {
//             countBadge.remove()
//           }
//         }
//       }
//     } catch (error) {
//       console.error("Error marking notification as read:", error)
//     }
//   }
// }