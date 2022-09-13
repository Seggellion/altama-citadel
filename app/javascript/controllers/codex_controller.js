import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "submenu","features", "form_popup", "event_popup"]

  connect() {
console.log('loaded');

  }

  submenu(event){

    if(this.submenuTarget.hasAttribute('hidden')){
      
      this.submenuTarget.removeAttribute("hidden");
      
      
    }else{
      this.submenuTarget.hidden = true;
    } 
    
  }



  add_event_option(event){
    event.preventDefault();
    document.querySelectorAll('.event-date[hidden]')[0].removeAttribute("hidden");
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

  hide(event){
    console.log('this.element', this.element);
    console.log('event.target', event.target);
    console.log('this.featuresTarget', this.featuresTarget);
    console.log('this.element.contains(event.target)', this.element.contains(event.target));
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
