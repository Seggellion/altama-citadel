import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "submenu","features", "form_popup", "event_popup", "FormSingleTab",
   "FormMultipleTab", "FormSingle", "FormMultiple"]

  connect() {
console.log('loaded');

  document.addEventListener('mouseup', function(e) {
      document.querySelectorAll('.sub-menu').forEach(function(el) {      
        if (!el.contains(e.target)) {
          const att = document.createAttribute("hidden");        
          el.setAttributeNode(att);
        }
    });
  });

  }

  submenu(event){

    if(event.target.childNodes[1].hasAttribute('hidden')){
      
      event.target.childNodes[1].removeAttribute("hidden");
      
      
    }else{
      event.target.childNodes[1].hidden = true;
    } 
    
  }


article_type(event){
  if (event.target.value === "location"){
    document.querySelector("#article_location_id").classList.remove('hidden');
    document.querySelector("#article_user_reference_id").classList.add('hidden');
    document.querySelector("#article_reference_id").classList.add('hidden');
    document.querySelector("#article_parent_location_id").classList.remove('hidden'); 
    document.querySelector("#article_location_type").classList.remove('hidden');     
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
  }else if(event.target.value === "dossier"){
    document.querySelector("#article_user_reference_id").classList.remove('hidden');
    document.querySelector("#article_reference_id").classList.add('hidden');

    document.querySelector("#article_location_id").classList.add('hidden');
    document.querySelector("#article_location_type").classList.add('hidden'); 
    document.querySelector("#article_parent_location_id").classList.add('hidden'); 

    document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
  }else if(event.target.value === "event"){
    
    document.querySelector("#article_user_reference_id").classList.add('hidden');
    document.querySelector("#article_reference_id").classList.remove('hidden');
    
    document.querySelector("#article_location_id").classList.add('hidden');
    document.querySelector("#article_location_type").classList.add('hidden'); 
    document.querySelector("#article_parent_location_id").classList.add('hidden'); 

    document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
  }else{
    document.querySelector("#article_user_reference_id").classList.add('hidden');
    document.querySelector("#article_reference_id").classList.add('hidden');
    document.querySelector("#article_location_id").classList.add('hidden');
    document.querySelector("#article_location_type").classList.add('hidden'); 
    document.querySelector("#article_parent_location_id").classList.add('hidden'); 
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
  }
}

new_location(event){
  if (event.target.value === ""){
    document.querySelector("#article_parent_location_id").classList.remove('hidden');
    document.querySelector("#article_location_type").classList.remove('hidden'); 
 //   document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
  }else{
    document.querySelector("#article_parent_location_id").classList.add('hidden');
    document.querySelector("#article_location_type").classList.add('hidden'); 
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
  }
}

require_location(event){
  if (event.target.value === ""){
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
  }else{
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
  }
}
select_parent(event){
  if (event.target.value === ""){    
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
  }else{    

    if( document.querySelector("#article_location_type").value !== ""  ){
      document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
    }else{
      document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
    }
//    document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
  }
}

location_type(event){
  if (event.target.value === ""){    
    document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
  }else{    

    if( document.querySelector("#article_parent_location_id").value !== ""  ){
      document.querySelector('.codex-center-viewport input[type="submit"]').classList.remove('hidden');    
    }else{
      document.querySelector('.codex-center-viewport input[type="submit"]').classList.add('hidden');    
    }

    
  }
}




  add_event_option(event){
    event.preventDefault();
    document.querySelectorAll('.event-row[hidden]')[0].removeAttribute("hidden");
   // document.getElementsByClassName('event-date').last.removeAttribute("hidden");
  }

  timeline_popup(event){
    event.preventDefault();
    this.form_popupTarget.hidden = false;
    this.form_popupTarget.removeAttribute("hidden");
    document.querySelectorAll('.codex-container')[0].classList.add('popup');
    
  }
  close_popup(event){
    this.form_popupTarget.hidden = true;
    document.querySelectorAll('.codex-container')[0].classList.remove('popup');
  }

  single_event(event){
    this.FormMultipleTabTarget.classList.remove('selected');
    this.FormSingleTabTarget.classList.add('selected');
    this.FormSingleTarget.hidden = false;
    this.FormMultipleTarget.hidden = true;
  }

  multiple_event(event){
  this.FormMultipleTabTarget.classList.add('selected');
  this.FormSingleTabTarget.classList.remove('selected');
  this.FormSingleTarget.hidden = true;
  this.FormMultipleTarget.hidden = false;
  }

  hide(event){

    //if(this.element === event.target || this.element.contains(event.target)) return;
    if(this.submenuTarget == event.target || this.featuresTarget == event.target ){
      console.log('clicked menu');
    }else{
      console.log('clicked out');
      this.submenuTarget.hidden = true;    
    }
    
  //  this.submenuTarget.hidden = true;
  }

  
}
