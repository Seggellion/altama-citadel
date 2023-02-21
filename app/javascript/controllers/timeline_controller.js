import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["event_popup", "event_editor", "event_details"]
connect(){


}
 event_popup(event){
  event.target.parentElement.parentElement.style.zIndex = "9001";
  
this.event_popupTarget.removeAttribute("hidden");
this.event_popupTarget.hidden = false;
localStorage.setItem("scrollPositon", document.querySelector(".timeline-grid").scrollLeft);
}

close_event_popup(event){  
  localStorage.setItem("scrollPositon", document.querySelector(".timeline-grid").scrollLeft);
  this.event_popupTarget.hidden = true;
  this.event_popupTarget.style.zIndex = "1";
  event.target.parentElement.parentElement.parentElement.style.zIndex = "1";
}

toggle_edit(event){
  console.log('test');
  if(this.event_editorTarget.hasAttribute('hidden')){
  this.event_editorTarget.hidden = false;
  this.event_detailsTarget.hidden = true;
  this.event_editorTarget.removeAttribute("hidden");
}else{
  this.event_editorTarget.hidden = true;
  this.event_detailsTarget.hidden = false;
  this.event_detailsTarget.removeAttribute("hidden");
}
}



}
