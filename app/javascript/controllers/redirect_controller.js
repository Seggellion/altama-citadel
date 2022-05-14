import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //connect() {
  // this.element.textContent = "Hello World!"
 // }


  connect() {
      setTimeout(function(){
      window.location.href = 'https://sos.altama.energy';
    }, 5000);
  }
}
