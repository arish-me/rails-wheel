// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import 'flowbite';
import "controllers"
import "chartkick"
import "Chart.bundle"
Turbo.StreamActions.redirect = function () {
  Turbo.visit(this.target);
};


import "trix"
import "@rails/actiontext"
//import "codemirror/lib/codemirror.css";


import { EditorView, basicSetup } from "codemirror";
import { liquid } from "@codemirror/lang-liquid";

document.addEventListener("turbo:load", () => {
  const textareas = document.querySelectorAll("[data-codemirror]");
  const previewElement = document.getElementById("live-preview");
  const formElement = document.getElementById("template-form");

  const clientId = formElement.dataset.clientId; // Ensure the form has data-client-id

  textareas.forEach((textarea) => {
    const parent = textarea.parentNode;

    // Hide the original textarea
    textarea.style.display = "none";

    // Create the CodeMirror instance
    const editor = new EditorView({
      doc: textarea.value,
      extensions: [basicSetup, liquid()],
      parent: parent,
      dispatch: (transaction) => {
        editor.update([transaction]);
        textarea.value = editor.state.doc.toString(); // Sync back to the original textarea

        // Trigger preview update
        updatePreview(editor.state.doc.toString());
      },
    });
  });

  const updatePreview = (liquidCode) => {
    if (!clientId) {
      console.error("Client ID not found");
      return;
    }

    fetch(`/clients/${clientId}/templates/preview`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
      body: JSON.stringify({ content: liquidCode }),
    })
      .then((response) => response.text())
      .then((html) => {
        previewElement.innerHTML = html;
      })
      .catch((error) => {
        console.error("Error updating preview:", error);
        previewElement.innerHTML = `<p class="text-red-500">Error rendering preview</p>`;
      });
  };
});
