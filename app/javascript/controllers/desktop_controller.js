import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    
    var windowName = this.element.querySelectorAll('.app-bar')[0].dataset.appname;
    var leftPosition = window.sessionStorage.getItem(`window-${windowName}-left`);
    var topPosition = window.sessionStorage.getItem(`window-${windowName}-top`);
    // removed jan 12 2023 pineapple
   // this.element.style.transform = "none";
    this.element.style.left = leftPosition;
    this.element.style.top = topPosition;
    console.log('leftPosition', leftPosition);
 }
 static targets = ["location_form", "activate_form", "all_users", "rsi_users"]

 dragstart(event) {
   
  event.dataTransfer.setData("application/drag-key", event.target.id);
  event.dataTransfer.effectAllowed = "move";
}
click(event){

  
  function getMaxZIndex() {
    return Math.max(
      ...Array.from(document.querySelectorAll('.window'), el =>
        parseFloat(window.getComputedStyle(el).zIndex),
      ).filter(zIndex => !Number.isNaN(zIndex)),
      0,
    );
  }
  this.element.style.zIndex = getMaxZIndex() + 1;
  console.log(getMaxZIndex()); 
  

}
dragover(event) {

  event.target.style.cursor = "move";
  this.element.style.left = event.pageX - (event.target.offsetWidth / 2) + 'px';
  this.element.style.top = event.pageY - (event.target.offsetHeight / 2) + 'px';
  this.element.style.transform = "none";

  event.preventDefault()

  return true
}

dragenter(event) {
  console.log('dragenter', this);
  event.preventDefault()
}

drop(event) {
  console.log('drop');
  var windowName = event.target.dataset.appname;
  window.sessionStorage.setItem(`window-${windowName}-left`, this.element.style.left);
  window.sessionStorage.setItem(`window-${windowName}-top`, this.element.style.top);
  var data = event.dataTransfer.getData("application/drag-key")
  const dropTarget = event.target
  const draggedItem = this.element;
  const positionComparison = dropTarget.compareDocumentPosition(draggedItem)
  if ( positionComparison & 4) {
     // event.target.insertAdjacentElement('beforebegin', draggedItem);
  } 
  
  event.preventDefault()
}

/*
drop(event) {
  var data = event.dataTransfer.getData("application/drag-key")
  const dropTarget = event.target
  const draggedItem = this.element.querySelector(`[data-todo-id='${data}']`);
  const positionComparison = dropTarget.compareDocumentPosition(draggedItem)
  if ( positionComparison & 4) {
      event.target.insertAdjacentElement('beforebegin', draggedItem);
  } else if ( positionComparison & 2) {
      event.target.insertAdjacentElement('afterend', draggedItem);
  }
  event.preventDefault()
}
*/
dragend(event) {
  event.target.style.cursor = "default";
}

user_row(event){

}
rsi_users(event){
  
 // document.getElementsByClassName('list').hidden = true
  this.rsi_usersTarget.hidden = false;
}
discord_users(event){
  this.discord_usersTarget.hidden = false;
  this.all_usersTarget.hidden = true;
}
all_users(event){
  this.rsi_usersTarget.hidden = true;
  this.all_usersTarget.hidden = false;
}
local_users(event){
  this.rsi_usersTarget.hidden = true;
  this.all_usersTarget.hidden = false;
}

  task_drag(event) {

      // (1) prepare to moving: make absolute and on top by z-index
      this.element.style.position = 'absolute';
      this.element.style.zIndex = 1000;
    
      // move it out of any current parents directly into body
      // to make it positioned relative to the body
      document.body.append(this.element);
    
        this.element.style.left = event.pageX - event.target.offsetWidth / 2 + 'px';
        this.element.style.top = event.pageY - event.target.offsetHeight / 2 + 'px';
        this.element.style.transform = "none";
      // centers the this.element at (pageX, pageY) coordinates
      function moveAt(pageX, pageY) {
        console.log('moveAt', this.element);
       // this.element.style.left = pageX - this.element.offsetWidth / 2 + 'px';
      //  this.element.style.top = pageY - this.element.offsetHeight / 2 + 'px';
      }

      // move our absolutely positioned this.element under the pointer
      moveAt(event.pageX, event.pageY);
    
      function onMouseMove(event) {
        console.log('MouseMove');
        moveAt(event.pageX, event.pageY);
      }
    
      // (2) move the this.element on mousemove
      event.addEventListener('mousemove', onMouseMove);
    
      // (3) drop the this.element, remove unneeded handlers
      event.target.onmouseup = function() {
        document.removeEventListener('mousemove', onMouseMove);
        event.target.onmouseup = null;
      };
  }
  
new_location(event){

this.location_formTarget.submit();
}

rsi_authenticate(event){
  this.activate_formTarget.submit();
  }


}
