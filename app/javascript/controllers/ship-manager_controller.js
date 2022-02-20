import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
/*connect() {
  console.log('connect');
 }*/
static targets = ["ship_manager", "manufacturer", "manufacturer_new_popup", "ship_new_popup","ship_modify_popup"]

create_manufacturer(event){
  this.manufacturer_new_popupTarget.style.display = 'block';
}

create_ship(event){
  this.ship_new_popupTarget.style.display = 'block';
}

modify_ship(event){
  this.ship_modify_popupTarget.style.display = 'block';
}

  manufacturers(event) {
    let current_active = document.getElementsByClassName('active');
    if (current_active.length > 0){
    for (var i = 0; i < current_active.length; i++) {
      current_active[i].classList.remove('active');
    }
  }
    event.target.className = 'active';
    this.manufacturerTarget.style.display = 'block';
    this.ship_managerTarget.style.display = 'none';
  
  }

  ship_manager(event) {
    let current_active = document.getElementsByClassName('active');

    if (current_active.length > 0){
    for (var i = 0; i < current_active.length; i++) {
      current_active[i].classList.remove('active');
    }
  }
    event.target.className = 'active';

    this.ship_managerTarget.style.display = 'block';
    this.manufacturerTarget.style.display = 'none';
  }
  
}
