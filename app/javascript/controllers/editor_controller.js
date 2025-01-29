import { Controller } from "@hotwired/stimulus";
import { EditorView, basicSetup } from "codemirror";
import { EditorState } from "@codemirror/state";
import { html } from "@codemirror/lang-html";
import { css } from "@codemirror/lang-css";

export default class extends Controller {
  static targets = [
    "htmlEditor",
    "cssEditor",
    "htmlEditorContainer",
    "cssEditorContainer",
    "preview",
    "framework",
    "form",
  ];

  connect() {
    this.initHtmlEditor();
    this.initCssEditor();
    this.showHtmlTab();
    this.updatePreview();

    if (this.hasFormTarget) {
      this.formTarget.addEventListener("submit", this.handleSubmit.bind(this));
    }
  }

  handleSubmit(event) {
    const htmlContent = this.htmlEditorView.state.doc.toString();
    const cssContent = this.cssEditorView.state.doc.toString();

    document.getElementById("html-hidden-field").value = htmlContent;
    document.getElementById("css-hidden-field").value = cssContent;
  }

  initHtmlEditor() {
    const initialHtmlContent =
      this.htmlEditorTarget.dataset.htmlContent || "<h1>Welcome!</h1>"; // Get from dataset

    this.htmlEditorView = new EditorView({
      state: EditorState.create({
        doc: initialHtmlContent,
        extensions: [basicSetup, html()],
      }),
      parent: this.htmlEditorTarget,
    });

    setTimeout(() => this.htmlEditorView.requestMeasure(), 100);
  }
  initCssEditor() {
    const initialCssContent = `body {
  background-color: #f8f9fa;
  font-family: Arial, sans-serif;
}
.container {
  text-align: center;
  margin-top: 50px;
}`;

    this.cssEditorView = new EditorView({
      state: EditorState.create({
        doc: initialCssContent,
        extensions: [basicSetup, css()],
      }),
      parent: this.cssEditorTarget,
    });

    setTimeout(() => this.cssEditorView.requestMeasure(), 100);
  }

  showHtmlTab() {
    this.htmlEditorContainerTarget.classList.remove("hidden");
    this.cssEditorContainerTarget.classList.add("hidden");

    // Refresh CodeMirror when switching tabs
    setTimeout(() => this.htmlEditorView.requestMeasure(), 100);
  }

  showCssTab() {
    this.cssEditorContainerTarget.classList.remove("hidden");
    this.htmlEditorContainerTarget.classList.add("hidden");

    setTimeout(() => this.cssEditorView.requestMeasure(), 100);
  }

  runCode() {
    this.updatePreview();
  }

  changeFramework() {
    this.updatePreview();
  }

  updatePreview() {
    const html = this.htmlEditorView.state.doc.toString();
    const css = this.cssEditorView.state.doc.toString();
    const framework = this.frameworkTarget.value;

    const FRAMEWORKS = {
      tailwind:
        "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css",
      bootstrap:
        "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css",
    };

    const iframe = this.previewTarget;
    const doc = iframe.contentDocument || iframe.contentWindow.document;
    doc.open();
    doc.write(`
      <html>
        <head>
          <link rel="stylesheet" href="${FRAMEWORKS[framework]}" />
          <style>${css}</style>
        </head>
        <body>${html}</body>
      </html>
    `);
    doc.close();
  }
}
