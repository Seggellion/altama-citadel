import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["slideout", "trigger"]


  connect() {
    console.log('user status stimulus coontroller');
    this.boundHideSlideout = this.hideSlideout.bind(this);
    this.subscribeToStatusUpdatesChannel()
}

subscribeToStatusUpdatesChannel() {
  console.log('Subscribing to StatusUpdatesChannel');
  this.subscription = createConsumer().subscriptions.create("StatusUpdatesChannel", {
    received: this.handleReceived.bind(this)
  })
}

handleReceived(data) {
  let contactList = document.querySelector('.contact-list');
  const friendElement = contactList.querySelector(`[data-friend-id="${data.user_id}"]`);
  
  if (friendElement) {
    // Generate the new status image HTML based on the received status
    const status = data.status.toLowerCase();
    
    // Use the assetPaths variable to get the correct asset path
    const newStatusImageSrc = assetPaths[status];
    
    const newStatusImageAlt = status.split(' ').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');

    // Create a new image element
    const newImgElement = document.createElement('img');
    newImgElement.setAttribute('src', newStatusImageSrc);
    newImgElement.setAttribute('alt', newStatusImageAlt);

    // Remove the old image element and add the new one
    const oldImgElement = friendElement.querySelector('img');
    if (oldImgElement) {
      oldImgElement.remove();
    }
    friendElement.appendChild(newImgElement);
  }
}

toggleSlideout(event) {
  const slideout = this.slideoutTarget;
  if (slideout.classList.contains("shown")) {
    this.hideSlideout();
  } else {
    slideout.classList.remove("hidden");
    slideout.classList.add("shown");

    // Add the event listener to the document
    setTimeout(() => {
      document.addEventListener("click", this.boundHideSlideout);
    });
  }

  // Stop propagation so that the event listener on document doesn't hide it immediately
  event.stopPropagation();
}

hideSlideout(event) {
  const slideout = this.slideoutTarget;

  if (!event || (event.target !== slideout && !slideout.contains(event.target))) {
    slideout.classList.remove("shown");
    slideout.classList.add("hidden");
    document.removeEventListener("click", this.boundHideSlideout);
  }
}


  received(data) {
    console.log("Received data:", data);
    // Rest of your code
  }

  disconnect() {
    // Cleanup code
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

}