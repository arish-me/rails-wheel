// // app/javascript/channels/chat_channel.js
// import consumer from "./consumer"

// consumer.subscriptions.create({ channel: "NotificationsChannel", room: "Best Room" }, {
//   connected() {
//     console.log("connected")
//   }
//   disconnected() {
//     console.log("disconnected")
//   },
//   rejected() {
//     console.log("Rejected")
//   },
//   received(data) {
//     this.appendLine(data)
//   },

//   appendLine(data) {
//     const html = this.createLine(data)
//     const element = document.querySelector("[data-chat-room='Best Room']")
//     element.insertAdjacentHTML("beforeend", html)
//   },

//   createLine(data) {
//     return `
//       <article class="chat-line">
//         <span class="speaker">${data["sent_by"]}</span>
//         <span class="body">${data["body"]}</span>
//       </article>
//     `
//   }
// })