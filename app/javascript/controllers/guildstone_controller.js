import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["menu","mainmenu", "createPosition", "createDepartment", "createNomination", "createRule", "createNonConfidence", "assignRole", "userPositionField"]
 


  show(event){
    document.getElementById("submit").style.display = "none";
    document.getElementById("rule_category_form").style.display = "block";
    document.getElementById("testingcat").style.display = "block";
    
    document.getElementById("rule_category").style.display = "none";
    console.log("test");
  }

  toggleMenu(event) {
    event.preventDefault();

    if (this.menuTarget.style.display === "none") {
      const departmentId = this.element.dataset.departmentId;
      fetch(`/departments/${departmentId}/users.json`)
        .then(response => response.json())
        .then(users => {
          const html = users.map(user => `<li>${user.name}</li>`).join('');
          this.menuTarget.innerHTML = `<ul>${html}</ul>`;
          this.menuTarget.style.display = "block";
        });
    } else {
      this.menuTarget.style.display = "none";
    }
  }


  hideMenu() {
    this.menuTarget.classList.remove('active');
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

  assignRole(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");
    var active_elements = document.querySelectorAll('.active');
    active_elements.forEach(el => {
      el.classList.remove('active');
    });
    this.assignRoleTarget.classList.toggle("active");
    
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

  createNonConfidence(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");
    var active_elements = document.querySelectorAll('.active');
    active_elements.forEach(el => {
      el.classList.remove('active');
    });
    this.createNonConfidenceTarget.classList.toggle("active");
    
    setTimeout(function(){
      button.classList.toggle("click");
    },100);
  }

  allApplications(event){
    var button =  event.currentTarget;
    button.classList.toggle("click");    
    
    setTimeout(function(){
      button.classList.toggle("click");
    },100);
  }


  userPositionUpdate(event){
    // console.log("working");
    this.userPositionFieldTarget.addEventListener("change", function(e) {
       // console.log("working");
         var userPositionId = this.options[this.selectedIndex].getAttribute('user_id');
         var positionId = this.options[this.selectedIndex].getAttribute('position_id');
         // alert(userPositionId);
          document.getElementById("position_user").value = userPositionId;
          document.getElementById("position_id").value = positionId;
       });
 }
 
  buttonClicked(event){
    var button =  event.currentTarget;
    button.classList.add("click");
    setTimeout(function(){
      button.classList.remove("click");
    },100);
    setTimeout(function(){
    },200);

  }

  
}
