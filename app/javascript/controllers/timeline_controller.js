import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["event_popup", "event_editor", "event_details"]
connect(){

}
 event_popup(event){
  console.log(this.event_popupTarget);
this.event_popupTarget.removeAttribute("hidden");
this.event_popupTarget.hidden = false;
}

close_event_popup(event){
  
  this.event_popupTarget.hidden = true;
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
