import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
    static targets = [ "username", "submit" ]


  verify(event) {
    const rsiUsername = event.target.value;
    const url = `/verify_username?rsi_username=${rsiUsername}`;

    //Turbo.visit(url, { action: 'replace', target: 'rsi_username_verification' });
  //  Turbo.visit(url, { action: 'replace', target: 'username_verification_result' });


    fetch(url, {
        headers: { 'Accept': 'text/vnd.turbo-stream.html' }
      }).then(response => {
        if (response.ok) {
          return response.text();
          this.submitTarget.disabled = false;
        } else {
          throw new Error('Network response was not ok.');
        }
      }).then(html => {
        Turbo.renderStreamMessage(html);
      }).catch(error => {
        console.error('Error:', error);
      });

      this.submitTarget.disabled = false;

  }
}
