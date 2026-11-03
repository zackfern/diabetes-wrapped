import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timezone"
export default class extends Controller {
  static targets = ['tz']

  connect() {
    // Only set the value if it isn't already selected:
    if (this.tzTarget.selectedIndex < 1) {
      this.tzTarget.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    }
  }
}
