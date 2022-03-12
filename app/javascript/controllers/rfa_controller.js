import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status_field", "user", "status_menu", "status_button"]

 
clear(event){
  let status_menu_element = document.getElementsByClassName('status-menu-wrapper')[0]
   
  if(event.target!= this.status_buttonTarget){
    console.log('not clicked', event.target.id);
    status_menu_element.classList.remove("open"); 
  }
}

  open(event) {

    this.status_fieldTarget.value = 1;
    this.formTarget.submit();
  }

  pending(event) {

    this.status_fieldTarget.value = 2;
    this.formTarget.submit();
  }

  hold(event) {

    this.status_fieldTarget.value = 3;
    this.formTarget.submit();
  }

  solved(event) {

    this.status_fieldTarget.value = 4;
    this.formTarget.submit();
  }

  takeit(event){
    event.preventDefault();
    let current_user = this.userTarget.dataset.user
    let element = document.getElementById('rfa_user_assigned_id');
    element.value = current_user
  }
  statusbutton(event){
    event.preventDefault();
    this.status_menuTarget.classList.add("open");
  }

  verify(event){
    console.log('test');
    document.getElementById('rsi_verification').classList.add('open');
  }
  
}
