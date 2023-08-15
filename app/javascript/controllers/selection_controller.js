import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["area", "selectionBox", "contextMenu"];

  isDragging = false;
  startX = 0;
  startY = 0;



  startDrag(event) {
    this.isDragging = true;
    this.startX = event.clientX;
    this.startY = event.clientY;
    this.selectionBoxTarget.style.width = '0';
    this.selectionBoxTarget.style.height = '0';
  }
  
    
  connect() {
    this.contextMenuTarget.style.display = 'none';
    document.addEventListener('mousedown', this.handleOutsideClick.bind(this));
}

disconnect() {
    document.removeEventListener('mousedown', this.handleOutsideClick.bind(this));
}

showContextMenu(event) {
    event.preventDefault(); // Prevent the default right-click context menu
    this.contextMenuTarget.style.left = `${event.pageX}px`;
    this.contextMenuTarget.style.top = `${event.pageY}px`;
    this.contextMenuTarget.style.display = 'block';
}

hideContextMenu() {
    this.contextMenuTarget.style.display = 'none';
}

displayPreferences(event) {
    // Your logic for showing display preferences goes here.
    event.stopPropagation();
    console.log('error');
    window.location.href = "/display_preferences";

}

handleOutsideClick(event) {
    if (!this.contextMenuTarget.contains(event.target)) {
        this.hideContextMenu();
    }
}


  drag(event) {
    if (!this.isDragging) return;

    const currentX = event.clientX;
    const currentY = event.clientY;

    const width = currentX - this.startX;
    const height = currentY - this.startY;

    this.selectionBoxTarget.style.width = `${Math.abs(width)}px`;
    this.selectionBoxTarget.style.height = `${Math.abs(height)}px`;
    this.selectionBoxTarget.style.left = `${(width > 0) ? this.startX : currentX}px`;
    this.selectionBoxTarget.style.top = `${(height > 0) ? this.startY : currentY}px`;
  }

  endDrag(event) {
    this.isDragging = false;
    this.selectionBoxTarget.style.width = '0';
    this.selectionBoxTarget.style.height = '0';
  }
}
