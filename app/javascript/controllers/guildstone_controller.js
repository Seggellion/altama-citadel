import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["mainmenu", "createPosition", "createDepartment", "createNomination", "createRule"]

  close(event) {
//event.target.
  }

  createPosition(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");
    var active_elements = document.querySelectorAll('.active');
    active_elements.forEach(el => {
      el.classList.remove('active');
    });
    this.createPositionTarget.classList.toggle("active");
    setTimeout(function(){
      button.classList.toggle("click");
    },100);
  }

  createDepartment(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");
    var active_elements = document.querySelectorAll('.active');
    active_elements.forEach(el => {
      el.classList.remove('active');
    });
    this.createDepartmentTarget.classList.toggle("active");
    setTimeout(function(){
      button.classList.toggle("click");
    },100);
  }

  createNomination(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");
    var active_elements = document.querySelectorAll('.active');
    active_elements.forEach(el => {
      el.classList.remove('active');
    });
    this.createNominationTarget.classList.toggle("active");
    
    setTimeout(function(){
      button.classList.toggle("click");
    },100);
  }

  createRule(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");
    var active_elements = document.querySelectorAll('.active');
    active_elements.forEach(el => {
      el.classList.remove('active');
    });
    this.createRuleTarget.classList.toggle("active");
    
    setTimeout(function(){
      button.classList.toggle("click");
    },100);
  }
  
}
