import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["audio"]
    connect() {
        document.addEventListener('turbolinks:load', this.playAudio.bind(this))
        document.addEventListener('turbolinks:before-cache', this.pauseAudio.bind(this))
        this.audioTarget.addEventListener('ended', this.removeAudio.bind(this))
      }
    
      disconnect() {
        document.removeEventListener('turbolinks:load', this.playAudio.bind(this))
        document.removeEventListener('turbolinks:before-cache', this.pauseAudio.bind(this))
        this.audioTarget.addEventListener('ended', this.removeAudio.bind(this))
      }
    
      playAudio() {
        this.audioTarget.play();
      }
    
      pauseAudio() {
        this.audioTarget.pause();
      }

      removeAudio() {
        this.audioTarget.remove();
      }
}
