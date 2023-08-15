import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["list"]

  connect() {    
    this.subscribeToChannel()
  }

  subscribeToChannel() {
    console.log('subscribeToChannel');
    this.subscription = createConsumer().subscriptions.create("MessagesChannel", {
      received: this.handleReceived.bind(this)
    })
  }

  scrollToBottom() {
    const messageHistoryDiv = this.element.querySelector('.message-history');
    messageHistoryDiv.scrollTop = messageHistoryDiv.scrollHeight;
  }

  handleReceived(data) {
    console.log("Received message:", data);

    // Auto-scroll to the bottom
   // this.scrollToBottom();

  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }
}
