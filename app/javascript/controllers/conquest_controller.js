import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //connect() {
  // this.element.textContent = "Hello World!"
 // }
 static targets = ["newevent"]

  expand(event) {
    this.neweventTarget.style.display = 'block';
    //this.outputTarget.textContent =



  }
  
}
