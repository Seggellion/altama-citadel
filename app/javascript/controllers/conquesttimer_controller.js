import { Controller } from "@hotwired/stimulus"


class Timer {
  constructor () {
    this.isRunning = false;
    this.startTime = 0;
    this.overallTime = 0;
  }

  _getTimeElapsedSinceLastStart () {
    if (!this.startTime) {
      return 0;
    }
  
    return Date.now() - this.startTime;
  }

  start () {
    
    if (this.isRunning) {
      return console.error('Timer is already running');
    }

    this.isRunning = true;
    
    this.startTime = Date.now();
  }

  stop () {
    if (!this.isRunning) {
      return console.error('Timer is already stopped');
    }

    this.isRunning = false;

    this.overallTime = this.overallTime + this._getTimeElapsedSinceLastStart();
  }

  reset () {
    this.overallTime = 0;

    if (this.isRunning) {
      this.startTime = Date.now();
      return;
    }

    this.startTime = 0;
  }

  getTime () {
    if (!this.startTime) {
      return 0;
    }

    if (this.isRunning) {
      return this.overallTime + this._getTimeElapsedSinceLastStart();
    }

    return this.overallTime;
  }
}

export default class extends Controller {
 static targets = ["timer", "form"]

  connect() {
    if (this.timerTargets){
  //let start_time = new Date(this.timerTarget.getAttribute('data-starttime')).getTime();
 // let old_start_time = new Date(this.timerTarget.getAttribute('data-starttime')).getTime();

const dt = this.timerTarget.getAttribute('data-starttime');
  const dateParts = dt.split(' ');           // ['2018-06-14', '11:59', 'AM']
  const timeParts = dateParts[1].split(':'); // ['11', '59']
  const day = dateParts[0];                 // '2018-06-14'
  const hours = parseInt(timeParts[0]);    // 11
  const minutes = parseInt(timeParts[1])  ;
  const seconds = parseInt(timeParts[2]) ;
  var countDownDate = new Date(day);
  countDownDate.setHours(hours);
  countDownDate.setMinutes(minutes);
  countDownDate.setSeconds(seconds);

let start_time = countDownDate.getTime();
  start_time = Math.round(start_time / 1000);
  let limit = this.timerTarget.getAttribute('data-capture-limit');
 let current_moment = new Date(((new Date(Date.now())).toUTCString())).getTime();
current_moment = Math.round(current_moment / 1000);
    const duration= ((current_moment - start_time) - 57600);
    const timer = new Timer();

    timer.start();
    setInterval(() => {
      const timeInSeconds = Math.round(timer.getTime() / 1000);

      this.timerTarget.innerText = timeInSeconds + duration;
      if ((timeInSeconds + duration) == limit ){
        let new_form = this.element.getElementsByClassName('active')[0].querySelectorAll('[data-conquesttimer-target]')[0];
        new_form.submit();
     
      }
    }, 100)
  };





  }
  
}
