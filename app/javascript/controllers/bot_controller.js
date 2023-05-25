import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "giveaways", "participants" ]

  toggleGiveaways(event) {
    this.giveawaysTarget.classList.toggle('hidden')
  }

  toggleParticipants(event) {
    this.participantsTarget.classList.toggle('hidden')
  }
}