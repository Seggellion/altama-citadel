import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

 static targets = ["event_popup"]
connect(){
  console.log('hello');
}
 event_popup(event){
  console.log(this.event_popupTarget);
this.event_popupTarget.removeAttribute("hidden");
this.event_popupTarget.hidden = false;
}

close_event_popup(event){
  
  this.event_popupTarget.hidden = true;
}

}
