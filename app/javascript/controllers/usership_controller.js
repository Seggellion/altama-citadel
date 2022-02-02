import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["form"]

  submit(event) {
    

    var selected = document.querySelectorAll('[data-selected="true"]')[0].getElementsByTagName('form')[0];
    console.log('hi', selected);

    selected.submit();


  };
  
  select(event) {
    
    var is_selected =  event.target.dataset.selected;    
    var all_selected = document.querySelectorAll('[data-selected]');

      for (var i = 0; i < all_selected.length; i++) {
        all_selected[i].dataset.selected = false;
        all_selected[i].classList.remove("selected");
      }

    if (is_selected !== 'false' ){
      event.target.classList.remove("selected");
      event.target.dataset.selected = false;
    }else{
      event.target.classList.add("selected");
      event.target.dataset.selected = true;
    }


  }

}
