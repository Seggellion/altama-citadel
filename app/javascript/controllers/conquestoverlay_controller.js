import { Controller } from "@hotwired/stimulus"

class ProgressRing extends HTMLElement {
    constructor() {
      super();
      const stroke = this.getAttribute('stroke');
      const radius = this.getAttribute('radius');
      const normalizedRadius = radius - stroke * 2;
      this._circumference = normalizedRadius * 2 * Math.PI;
  
      this._root = this.attachShadow({mode: 'open'});
      this._root.innerHTML = `
        <svg
          height="${radius * 2}"
          width="${radius * 2}"
         >
           <circle
             stroke="green"
             stroke-dasharray="${this._circumference} ${this._circumference}"
             style="stroke-dashoffset:${this._circumference}"
             stroke-width="${stroke}"
             fill="transparent"
             r="${normalizedRadius}"
             cx="${radius}"
             cy="${radius}"
          />
        </svg>
  
        <style>
          circle {
            transition: stroke-dashoffset 0.35s;
            transform: rotate(-90deg);
            transform-origin: 50% 50%;
          }
        </style>
      `;
    }
    
    setProgress(percent) {
      const offset = this._circumference - (percent / 100 * this._circumference);
      const circle = this._root.querySelector('circle');
      circle.style.strokeDashoffset = offset; 
    }
  
    static get observedAttributes() {
      return ['progress'];
    }
  
    attributeChangedCallback(name, oldValue, newValue) {
      if (name === 'progress') {
        this.setProgress(newValue);
      }
    }
  }
  window.customElements.define('progress-ring', ProgressRing);
export default class extends Controller {
    static targets = ["progressring"]
  connect() {

  let control_point_id = this.element.dataset.id

  const el = this.progressringTargets;
  const limit = 300;

  let progress = this.element.dataset.initialprogress * 1;

  const interval = setInterval(() => {
  
    for (var i = 0; i < el.length; i++) {
        if(progress <= 100){
        el[i].setAttribute('progress', progress);
    }
    }
    
    progress += (1 / limit) * 100;

    if (progress === limit)
      clearInterval(interval);
  }, 1000);

  }
  }