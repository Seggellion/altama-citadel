import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //connect() {
  // this.element.textContent = "Hello World!"
 // }
 static targets = ["mainmenu"]

  greet(event) {


    if (this.mainmenuTarget.classList.contains("open")){
      this.mainmenuTarget.classList.remove("open"); 
      event.target.classList.remove("clicked");     
    }else{
      this.mainmenuTarget.classList.add("open");
      event.target.classList.add("clicked");
    }


  }
  
}
