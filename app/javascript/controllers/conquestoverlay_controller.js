import { Controller } from "@hotwired/stimulus"

class ProgressRing extends HTMLElement {
    constructor() {
      super();
      const stroke = this.getAttribute('stroke');
      const radius = this.getAttribute('radius');
      const color = this.getAttribute('team-color');
      console.log('color: ', color);
      const normalizedRadius = radius - stroke * 2;
      this._circumference = normalizedRadius * 2 * Math.PI;
  
      this._root = this.attachShadow({mode: 'open'});
      this._root.innerHTML = `
        <svg
          height="${radius * 2}"
          width="${radius * 2}"
         >
           <circle
             stroke="${color}"
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
    static targets = ["progressring", "countdown"]
  connect() {
 
  let control_point_id = this.element.dataset.id

  const el = this.progressringTargets;
  
  const limit = this.countdownTarget.getAttribute('data-capture-limit');
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


  // other timer:



  function startTimer(duration, display, elapsed) {
    var timer = duration, minutes, seconds;
    setInterval(function () {
        minutes = parseInt((timer - elapsed) / 60, 10);
        seconds = parseInt((timer - elapsed) % 60, 10);

        minutes = minutes < 10 ? "0" + minutes : minutes;
        seconds = seconds < 10 ? "0" + seconds : seconds;

        display.textContent = minutes + ":" + seconds;

        if (--timer < 0 && seconds > 0 && minutes > 0) {
          
            timer = duration;
        
        }else{
          return
        }
    }, 1000);
}



    let start_time = this.countdownTarget.getAttribute('data-starttime');
    if (start_time){
    start_time = new Date(start_time).getTime();
    start_time =  Math.round(start_time / 1000);
    //let current_moment = DateTime.now;
   
   const d = new Date();
 let current_moment = d.getTime();
 current_moment = Math.round(current_moment / 1000);
 console.log('current_moment: ', current_moment > start_time);
    const elapsed = (current_moment - start_time);

console.log('elapsed: ', elapsed);
        display = this.countdownTarget;
    startTimer(limit, display, elapsed);
  };

  }
  
  }