import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="loading-page"
export default class extends Controller {
  static targets = ["progressBar"];
  static values = { url: String };

  refreshTime = 1500;

  connect() {
    this.refreshInterval = setInterval(
      () => { this.refreshProgress() },
      this.refreshTime
    );
  }

  disconnect() {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  }

  refreshProgress() {
    fetch(this.urlValue)
      .then(response => response.json())
      .then(data => this.setProgressOrReload(data));
  }

  setProgressOrReload(data) {
    const { visible, months } = data;
    if (visible === true) {
      // The report is finished, reload the page to see it:
      window.location.reload();
    }
    else {
      // Set the progress bar to reflect the number of processed months:
      this.progressBarTarget.value = months;
    }
  }
}
