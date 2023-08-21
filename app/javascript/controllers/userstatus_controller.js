import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["slideout"]


  connect() {
    console.log('user status');
}


toggleSlideout(event) {

    const slideout = this.slideoutTarget;
    if (slideout.classList.contains("shown")) {
      slideout.classList.remove("shown");
      slideout.classList.add("hidden");
      document.removeEventListener("click", this.hideSlideout.bind(this));
    } else {
      
      slideout.classList.remove("hidden");
      slideout.classList.add("shown");
      console.log('show');
      //document.addEventListener("click", this.hideSlideout.bind(this));
    }
    event.stopPropagation();
  }

  hideSlideout(event) {
    const slideout = this.slideoutTarget;
    const trigger = this.triggerTarget;
    if (event.target !== slideout && event.target !== trigger && !slideout.contains(event.target) && !trigger.contains(event.target)) {
      slideout.classList.remove("shown");
      slideout.classList.add("hidden");
      document.removeEventListener("click", this.hideSlideout.bind(this));
    }
  }



}