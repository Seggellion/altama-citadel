import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["square", "triangle"]

  connect() {
    this.squareTarget.addEventListener("mousedown", this.startDragging.bind(this));
    document.addEventListener("mousemove", this.drag.bind(this));
    document.addEventListener("mouseup", this.stopDragging.bind(this));
    this.isDragging = false;
  }

  disconnect() {
    this.squareTarget.removeEventListener("mousedown", this.startDragging);
    document.removeEventListener("mousemove", this.drag);
    document.removeEventListener("mouseup", this.stopDragging);
  }

  startDragging(event) {
    event.preventDefault();
    this.isDragging = true;
  }

  drag(event) {
    if (!this.isDragging) return;

    const triangleRect = this.triangleTarget.getBoundingClientRect();
    const squareRect = this.squareTarget.getBoundingClientRect();
    const parentRect = this.element.getBoundingClientRect();

    const triangleCenter = {
      x: triangleRect.left - parentRect.left + triangleRect.width / 2,
      y: triangleRect.top - parentRect.top + triangleRect.height / 2,
    };

    const angle = Math.atan2(
      event.clientY - triangleCenter.y - parentRect.top,
      event.clientX - triangleCenter.x - parentRect.left
    );

    const radius = triangleRect.width / 2 - squareRect.width / 2;

    const squarePosition = {
      x: triangleCenter.x + radius * Math.cos(angle) - squareRect.width / 2,
      y: triangleCenter.y + radius * Math.sin(angle) - squareRect.height / 2,
    };

    this.squareTarget.style.left = `${squarePosition.x}px`;
    this.squareTarget.style.top = `${squarePosition.y}px`;
  }

  stopDragging() {
    this.isDragging = false;
  }

}
