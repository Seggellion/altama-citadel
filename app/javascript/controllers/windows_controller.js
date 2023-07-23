import { Controller } from "@hotwired/stimulus"

export default class extends Controller {


  static targets = ["header"]

  connect() {
    this.element.addEventListener('mousedown', this.mousedown.bind(this))
    document.addEventListener('mousemove', this.mousemove.bind(this))
    document.addEventListener('mouseup', this.mouseup.bind(this))
  }

  mousedown(event) {
    this.xOffset = event.clientX - this.element.getBoundingClientRect().left
    this.yOffset = event.clientY - this.element.getBoundingClientRect().top
    this.isMouseDown = true
    document.body.classList.add('dragging') 
  }

  mousemove(event) {
    if (!this.isMouseDown) return
    this.element.style.position = 'absolute'
    this.element.style.left = event.clientX - this.xOffset + 'px'
    this.element.style.top = event.clientY - this.yOffset + 'px'
  }

  mouseup() {
    this.isMouseDown = false
    document.body.classList.remove('dragging') 
  }


  
}
