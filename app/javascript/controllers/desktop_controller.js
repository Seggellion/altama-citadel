import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //connect() {
  // this.element.textContent = "Hello World!"
 // }
 static targets = ["location_form"]

 dragstart(event) {
   console.log('dragstart');
  event.dataTransfer.setData("application/drag-key", event.target.id);
  event.dataTransfer.effectAllowed = "move";
}

dragover(event) {

  event.target.style.cursor = "move";
  this.element.style.left = event.pageX - event.target.offsetWidth / 2 + 'px';
  this.element.style.top = event.pageY - event.target.offsetHeight / 2 + 'px';
  event.preventDefault()

  return true
}

dragenter(event) {
  console.log('dragenter');
  event.preventDefault()
}

drop(event) {
  console.log('drop');
  var data = event.dataTransfer.getData("application/drag-key")
  const dropTarget = event.target
  const draggedItem = this.element;
  const positionComparison = dropTarget.compareDocumentPosition(draggedItem)
  if ( positionComparison & 4) {
      event.target.insertAdjacentElement('beforebegin', draggedItem);
  } else if ( positionComparison & 2) {
      event.target.insertAdjacentElement('afterend', draggedItem);
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


  task_drag(event) {

      // (1) prepare to moving: make absolute and on top by z-index
      this.element.style.position = 'absolute';
      this.element.style.zIndex = 1000;
    
      // move it out of any current parents directly into body
      // to make it positioned relative to the body
      document.body.append(this.element);
    
        this.element.style.left = event.pageX - event.target.offsetWidth / 2 + 'px';
        this.element.style.top = event.pageY - event.target.offsetHeight / 2 + 'px';

      // centers the this.element at (pageX, pageY) coordinates
      function moveAt(pageX, pageY) {
        console.log('moveAt', this.element);
       // this.element.style.left = pageX - this.element.offsetWidth / 2 + 'px';
      //  this.element.style.top = pageY - this.element.offsetHeight / 2 + 'px';
      }
    console.log('this.element.style.top', this.element.style.top);
    console.log('event.pageX', event.pageX);
    console.log('event.pageY', event.pageY);
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


}
