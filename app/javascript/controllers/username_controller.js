import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ["rsiUsername", "submit", "shipSelect", "shipName"];

  connect() {
    this.updateSubmitButtonState();
  }

  updateSubmitButtonState() {
    const isShipSelected = this.shipSelectTarget.value !== "";
    const isRsiUsernameValid = this.rsiUsernameTarget.value.trim() !== ""; // Assuming validation logic is handled elsewhere
    const isShipNameValid = this.shipNameTarget.value.trim() !== "";

    this.submitTarget.disabled = !(isShipSelected && isRsiUsernameValid && isShipNameValid);
  }

  validateForm(event) {
    if (!this.element.checkValidity()) {
      event.preventDefault();
    }
  }

  verify(event) {
    const rsiUsername = event.target.value;
    const url = `/verify_username?rsi_username=${rsiUsername}`;

    fetch(url, {
      headers: { 'Accept': 'text/vnd.turbo-stream.html' }
    }).then(response => {
      if (response.ok) {
        return response.text();
      } else {
        throw new Error('Network response was not ok.');
      }
    }).then(html => {
      Turbo.renderStreamMessage(html);
      this.updateSubmitButtonState(); // Update submit button state after verification
    }).catch(error => {
      console.error('Error:', error);
    });
  }
}
