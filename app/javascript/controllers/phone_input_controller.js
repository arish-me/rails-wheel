// app/javascript/controllers/phone_input_controller.js
import { Controller } from "@hotwired/stimulus"
import intlTelInput from "intl-tel-input" // This imports the main JS
// The utils.js is loaded dynamically by intlTelInput, so you don't typically import it here.
// You just need to tell intlTelInput where to find it via the utilsScript option.

export default class extends Controller {
  static targets = ["phoneInput", "countryCodeHidden", "fullNumberHidden"]

  iti = null // Store the intlTelInput instance

  connect() {
    this.iti = intlTelInput(this.phoneInputTarget, {
      // Options for intl-tel-input
      // See: https://github.com/jackocnr/intl-tel-input#options
      initialCountry: "auto", // Automatically detect user's country
      geoIpLookup: this.getIpLookupCallback(), // Geolocation lookup for initial country
      // !!! IMPORTANT for Importmap: Path to utils.js !!!
      // This path must be relative to the web root or served by Importmap.
      // If you pinned it as "intl-tel-input/utils", then use that.
      //utilsScript: "/assets/intl-tel-input/build/js/utils.js", // This might need adjustment!
      // OR if you used `pin "intl-tel-input/utils", to: "intl-tel-input/build/js/utils.js"`:
      // utilsScript: this.element.dataset.phoneInputUtilsUrl || "/path/to/intl-tel-input/build/js/utils.js",
      // (Using a data attribute to pass the URL from ERB is the most robust way)

      separateDialCode: true,
      formatOnDisplay: true,
      // Add more options as needed, e.g.:
      // onlyCountries: ["us", "ca", "gb", "in"],
      // preferredCountries: ["us", "gb", "in"],
    })

    // Listen for changes and update hidden fields
    this.phoneInputTarget.addEventListener("change", this.updateHiddenFields.bind(this))
    this.phoneInputTarget.addEventListener("keyup", this.updateHiddenFields.bind(this))

    // Set initial valid number if one exists (e.g., editing an existing user)
    // intlTelInput returns a promise for its initialization
    this.iti.promise.then(() => {
        if (this.hasFullNumberHiddenTarget && this.fullNumberHiddenTarget.value) {
            // Set the number on the input, which will also update the country flag
            this.iti.setNumber(this.fullNumberHiddenTarget.value);
        }
        this.updateHiddenFields(); // Ensure hidden fields are populated correctly on load
    });
  }

  disconnect() {
    if (this.iti) {
      this.iti.destroy()
    }
  }

  updateHiddenFields() {
    if (!this.iti) return; // Ensure iti is initialized

    // Check if the number is valid based on the selected country
    if (this.iti.isValidNumber()) {
      const countryData = this.iti.getSelectedCountryData()
      const dialCode = countryData.dialCode
      // Get the number in E.164 format for reliable storage
      const fullPhoneNumberE164 = this.iti.getNumber(intlTelInput.numberFormat.E164)

      if (this.hasCountryCodeHiddenTarget) {
        this.countryCodeHiddenTarget.value = `+${dialCode}`
      }
      if (this.hasFullNumberHiddenTarget) {
        this.fullNumberHiddenTarget.value = fullPhoneNumberE164
      }
      // You can add logic here to remove error classes from the input
      this.phoneInputTarget.classList.remove("is-invalid")
    } else {
      // If the number is not valid, clear hidden fields to prevent invalid data submission
      if (this.hasCountryCodeHiddenTarget) {
        this.countryCodeHiddenTarget.value = ""
      }
      if (this.hasFullNumberHiddenTarget) {
        this.fullNumberHiddenTarget.value = ""
      }
      // Add logic here to add error classes to the input
      this.phoneInputTarget.classList.add("is-invalid")
    }
  }

  // Optional: Geolocation for initial country auto-detection
  getIpLookupCallback() {
    // This example uses ipinfo.io. You'd need to replace 'YOUR_IPINFO_TOKEN' with an actual token
    // obtained from ipinfo.io for production use.
    // For development, you can often leave this out or mock it.
    return function(callback) {
      fetch("https://ipinfo.io/json?token=YOUR_IPINFO_TOKEN")
        .then(response => response.json())
        .then(json => callback(json.country))
        .catch(() => callback("us")) // Default to US on error or if no token
    }
  }
}