import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //connect() {
  // this.element.textContent = "Hello World!"
 // }
 static targets = ["rating_field", "form", "description"]

    star1(event){
        this.rating_fieldTarget.value = "1"
        //document.querySelector('form').submit();
        this.descriptionTarget.classList.add('show');
        event.target.classList.add('selected');
      //  Turbo.navigator.submitForm(this.formTarget)
    }
    star2(event){
        this.rating_fieldTarget.value = "2"
        this.descriptionTarget.classList.add('show');
        event.target.classList.add('selected');
       
    }
    star3(event){
        this.rating_fieldTarget.value = "3"
        this.descriptionTarget.classList.add('show');
        event.target.classList.add('selected');
    }
    star4(event){
        this.rating_fieldTarget.value = "4"
        this.descriptionTarget.classList.add('show');
        event.target.classList.add('selected');
    }    
    star5(event){
        this.rating_fieldTarget.value = "5"
        this.descriptionTarget.classList.add('show');
        event.target.classList.add('selected');
    }
    
}
