import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //connect() {
  // this.element.textContent = "Hello World!"
 // }
 static targets = ["fid", "altamaFleet"]

  connect(){
    console.log('connected');
    const instance = this;
   // this.altamaFleetTarget.addEventListener("change", this.toggleFID());

  }

  toggleFID() {
    console.log('changed');
   // console.log('Target:',this );
    //console.log('Target:',instance );
   /* if (this.altamaFleetTarget.checked) {
      instance.fidTarget.hidden = false;
    } else {
      instance.fidTarget.hidden = true;
    }
    */
  }

  clickedFID(event){
    console.log('checked',this.fidTarget);
    this.fidTarget.classList.toggle('hide');
    
if (this.fidTarget.querySelector('#field01').required == true) {
  this.fidTarget.querySelector('#field01').required = false;
  this.fidTarget.querySelector('#field02').required = false;
  //  this.fidTarget.hidden = false;
}else{
  this.fidTarget.querySelector('#field01').required = true;
  this.fidTarget.querySelector('#field02').required = true;
 // this.fidTarget.hidden = true;
}
  }



}
