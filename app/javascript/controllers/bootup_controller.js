import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
 connect() {

  
  setTimeout(function () {
    window.location.href ='/desktop';
}, 5000);
 }


  
  
}
