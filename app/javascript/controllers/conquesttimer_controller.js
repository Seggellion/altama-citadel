import { Controller } from "@hotwired/stimulus"


class Timer {
  constructor () {
    console.log('started!', this.isRunning);
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
  let start_time = new Date(this.timerTarget.getAttribute('data-starttime')).getTime();
  start_time = Math.round(start_time / 1000);
 let current_moment = new Date().getTime();
 current_moment = Math.round(current_moment / 1000);
    const duration= current_moment - start_time;
    //const duration = Math.round(time_difference/ 1000);
    console.log('date now: ', Date.now);
    console.log('start time: ', start_time);
    console.log('current_moment: ', current_moment);
    console.log('duration: ', duration);
    const timer = new Timer();
    timer.start();
    setInterval(() => {
      const timeInSeconds = Math.round(timer.getTime() / 1000);
      this.timerTarget.innerText = timeInSeconds + duration;
      if ((timeInSeconds + duration) > 300){
        // this.formTarget.submit();
      }
    }, 100)
  }
  //  this.formTarget.submit();


  }
  
}
