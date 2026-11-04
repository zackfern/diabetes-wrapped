import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="signup-form"
export default class extends Controller {
  static targets = ["rangeMin", "rangeMax", "tz"];

  connect() {
    // Only set the value if it isn't already selected:
    if (this.tzTarget.selectedIndex < 1) {
      this.tzTarget.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    }
  }

  change_unit(event) {
    if (event.target.value === "mmol/L") {
      // Set to sensible defaults:
      this.rangeMinTarget.value = 3.8;
      this.rangeMaxTarget.value = 10;

      // Set step to support fractional values:
      this.rangeMinTarget.setAttribute("step", "0.1");
      this.rangeMaxTarget.setAttribute("step", "0.1");
    } else {
      this.rangeMinTarget.value = 70;
      this.rangeMaxTarget.value = 180;

      // Disable fractional values:
      this.rangeMinTarget.removeAttribute("step");
      this.rangeMaxTarget.removeAttribute("step");
    }
  }
}
