import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["area", "selectionBox"];
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
