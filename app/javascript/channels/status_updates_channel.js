import { createConsumer } from "@rails/actioncable"
export default createConsumer()

consumer.subscriptions.create("StatusUpdatesChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to StatusUpdatesChannel");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log('recieved?');
    const userElement = document.querySelector(`[data-user-id='${data.user_id}']`);
    
    if (userElement) {
      userElement.innerHTML = `<img src="/assets/${data.status}.png" alt="${data.status}"> ${data.username}`;
    }
  }
});
