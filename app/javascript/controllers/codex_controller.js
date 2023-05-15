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
  const selectors = {
    common: ['.codex-center-viewport input[type="submit"]'],
    location: ["#article_location_id", "#article_parent_location_id", "#article_location_type"],
    dossier: ["#article_user_reference_id"],
    event: ["#article_reference_id"],
    none: ["#article_user_reference_id", "#article_reference_id", "#article_location_id", "#article_location_type", "#article_parent_location_id"]
  };

  const removeHiddenClasses = selectors[event.target.value] || [];
  const addHiddenClasses = selectors['none'].filter(selector => !removeHiddenClasses.includes(selector));

  if (event.target.value === "location") {
    addHiddenClasses.push('.codex-center-viewport input[type="submit"]');
  } else {
    removeHiddenClasses.push('.codex-center-viewport input[type="submit"]');
  }

  removeHiddenClasses.forEach(selector => document.querySelector(selector)?.classList.remove('hidden'));
  addHiddenClasses.forEach(selector => document.querySelector(selector)?.classList.add('hidden'));
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

find_people(event){
  // if target has class?
if (event.target.classList()){

}else{
  document.querySelector('.find_people').classList.add('active');   
}

var hidden_articles = document.querySelectorAll('.article-select');
const filterValue = 'dossier';
hidden_articles.forEach((element) => {
  const dataAttributeValue = element.getAttribute('data-category'); // Replace with your data attribute name
  if (dataAttributeValue !== filterValue) {
   // filteredElements.push(element);
   element.classList.add('hidden');  
  }
});
 

}

find_commodity(event){
  var hidden_articles = document.querySelectorAll('.article-select');
  const filterValue = 'commodity';
  hidden_articles.forEach((element) => {
    const dataAttributeValue = element.getAttribute('data-category'); // Replace with your data attribute name
    if (dataAttributeValue !== filterValue) {
     // filteredElements.push(element);
     element.classList.add('hidden');  
    }
  });

  document.querySelector('.find_commodity').classList.add('active');   
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
