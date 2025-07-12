// app/javascript/controllers/multi_select_controller.js
import { Controller } from "@hotwired/stimulus"
import Choices from "choices.js"

export default class extends Controller {
  static targets = ["select"]

  // Define Stimulus values and their default types
  static values = {
    maxItems: { type: Number, default: 1 }, // Default to 1 for single-select if not specified
    placeholderValue: { type: String, default: 'Select an option' },
    removeItemButton: { type: Boolean, default: false },
    searchEnabled: { type: Boolean, default: true },
    // Add any other Choices.js options you want to expose
    // For example:
    // searchFloor: { type: Number, default: 1 },
    // noResultsText: { type: String, default: 'No results found' }
  }

  choicesInstance = null

  connect() {
    // Construct Choices.js options using Stimulus values
    const options = {
      maxItemCount: this.maxItemsValue,
      placeholder: true, // Placeholder is always active if placeholderValue is set
      placeholderValue: this.placeholderValueValue,
      removeItemButton: this.removeItemButtonValue,
      searchEnabled: this.searchEnabledValue,
      searchChoices: true, // Usually desired with searchEnabled
      searchFloor: 1, // Default, can be made a value
      noResultsText: 'No results found', // Default, can be made a value
      noChoicesText: 'No more choices to be made', // Default, can be made a value
      itemSelectText: 'Press to select', // Default, can be made a value
      delimiter: ',',
      editItems: true,
      allowHTML: false,
      allowHtmlUserInput: false,
      loadingText: 'Loading...',
      // You can add more options here and make them Stimulus values as needed
    };

    // If maxItemsValue is 1, Choices.js treats it as single select automatically
    // You might want different defaults or explicitly set `maxItemCount: 1` if it's a single select.
    // For a multi-select specific controller, ensure maxItemsValue is set accordingly in HTML.

    this.choicesInstance = new Choices(this.selectTarget, options);
  }

  disconnect() {
    if (this.choicesInstance) {
      this.choicesInstance.destroy();
    }
  }
}