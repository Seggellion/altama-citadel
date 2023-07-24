import { Controller } from "@hotwired/stimulus"

export default class extends Controller {


  static targets = ["header"]
  static zIndex = 0 

  connect() {
    this.headerTarget.addEventListener('mousedown', this.mousedown.bind(this))
    document.addEventListener('mousemove', this.mousemove.bind(this))
    document.addEventListener('mouseup', this.mouseup.bind(this))
    this.loadPosition()
  }

  mousedown(event) {
    this.xOffset = event.clientX - this.headerTarget.getBoundingClientRect().left
    this.yOffset = event.clientY - this.headerTarget.getBoundingClientRect().top
    this.isMouseDown = true
    document.body.classList.add('dragging') 
    this.constructor.zIndex++
    this.element.style.zIndex = this.constructor.zIndex
  }

  mousemove(event) {
    if (!this.isMouseDown) return
    this.element.style.position = 'absolute'
    
    let left = event.clientX - this.xOffset
    let top = event.clientY - this.yOffset

    // Restricting window within the viewport
    left = Math.min(Math.max(left, 0), window.innerWidth - this.element.offsetWidth)
    top = Math.min(Math.max(top, 0), window.innerHeight - this.element.offsetHeight)
    
    this.element.style.left = left + 'px'
    this.element.style.top = top + 'px'
    
    this.storePosition()
  }

  mouseup() {
    this.isMouseDown = false
    document.body.classList.remove('dragging') 
    this.storePosition()
  }

  storePosition() {
    const { left, top } = this.element.style
    localStorage.setItem(`${this.element.id}_position`, JSON.stringify({ left, top }))
  }

  loadPosition() {
    let position = JSON.parse(localStorage.getItem(`${this.element.id}_position`))
    if (position) {
      let left = parseFloat(position.left)
      let top = parseFloat(position.top)

      // Restricting window within the viewport on load
      left = Math.min(Math.max(left, 0), window.innerWidth - this.element.offsetWidth)
      top = Math.min(Math.max(top, 0), window.innerHeight - this.element.offsetHeight)
      
      this.element.style.left = left + 'px'
      this.element.style.top = top + 'px'
    }
  }
}
