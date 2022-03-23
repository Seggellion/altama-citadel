import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status_field", 
  "user", "status_menu", "status_button",
   "rfaUnassigned", "rfaSolved","rfaMine", "rfaAll"]

 
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

  rfaAll(event){
    this.rfaAllTarget.classList.add('show');
    this.rfaUnassignedTarget.classList.remove('show');
    this.rfaSolvedTarget.classList.remove('show');
    this.rfaMineTarget.classList.remove('show');
  }
  rfaMine(event){
    this.rfaMineTarget.classList.add('show');
    this.rfaAllTarget.classList.remove('show');
    this.rfaUnassignedTarget.classList.remove('show');
    this.rfaSolvedTarget.classList.remove('show');
  }
  rfaUnassigned(event){
    this.rfaUnassignedTarget.classList.add('show');
    this.rfaMineTarget.classList.remove('show');
    this.rfaAllTarget.classList.remove('show');
    this.rfaSolvedTarget.classList.remove('show');
  }

  rfaSolved(event){
    this.rfaSolvedTarget.classList.add('show');
    this.rfaAllTarget.classList.remove('show');
    this.rfaMineTarget.classList.remove('show');
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
    document.getElementById('rsi_verification').classList.add('open');
  }
  
}
