import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["form", "ownedships"]

  submit(event) {
    

    var selected = document.querySelectorAll('[data-selected="true"]')[0].getElementsByTagName('form')[0];
    console.log('hi', selected);

    selected.submit();


  };
  
  select(event) {
    
    var is_selected =  event.currentTarget.dataset.selected;    
    var all_selected = document.querySelectorAll('[data-selected]');

      for (var i = 0; i < all_selected.length; i++) {
        all_selected[i].dataset.selected = false;
        all_selected[i].classList.remove("selected");
      }
    if (is_selected !== 'false' ){
      event.currentTarget.classList.remove("selected");
      event.currentTarget.dataset.selected = false;
      this.ownedshipsTarget.classList.remove('expand');
    }else{
      event.currentTarget.classList.add("selected");
      event.currentTarget.dataset.selected = true;

    }


  }

}
