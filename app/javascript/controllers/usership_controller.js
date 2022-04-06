import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["form", "ownedships"]

  submit(event) {
    this.formTarget.submit();
  };
  
  edit(event){
    var ship_id =  event.currentTarget.dataset.ship;
    var edit_container = document.getElementById('container-' + ship_id);
    
      if (edit_container.classList.contains('show')){
        edit_container.classList.remove('show');
      }else{
        edit_container.classList.add('show');
      }


  }

  import(event){
    
  }

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
