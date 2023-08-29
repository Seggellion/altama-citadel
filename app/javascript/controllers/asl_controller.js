import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { uhOhSoundPath: String }
  static targets = ["row","aslNumber", "displayName", "twitchName", "existingGroupRadio", "aslChars",
   "newGroupRadio", "friendGroupSelect", "newFriendGroupInput", "request_container", "messageContent", "messageHistory"];

  connect() {
    console.log("ASL Controller connected");
    this.setupMessagesChannel();

    if (this.hasAslNumberTarget && this.hasDisplayNameTarget && this.hasTwitchNameTarget) {
        this.populateFields();
    }
    
    this.scrollToBottom();
  }

  populateFields() {
    this.aslNumberTarget.value = localStorage.getItem('selectedUserAslNumber') || '';
    this.displayNameTarget.value = localStorage.getItem('selectedUsername') || '';
    this.twitchNameTarget.value = localStorage.getItem('selectedTwitchUsername') || '';
}

  selectRow(event) {
    this.rowTargets.forEach(row => {
        row.classList.remove('selected-row');
    });
    const row = event.currentTarget;
    row.classList.toggle('selected-row');
    
  }

  doubleClickRow(event) {
    const row = event.currentTarget;
    this.storeSelectedUserData(row);
    window.location.href = "/asl_add_contact"; // Navigate to the new route
}

addContactList(event) {
  const row = this.request_containerTarget;
  this.storeSelectedUserData(row);
  window.location.href = "/asl_add_contact"; // Navigate to the new route
}

addFriend() {
    // Assuming you have only one row selected at a time
    
    const selectedRow = this.rowTargets.find(row => row.classList.contains('selected-row'));
    if (selectedRow) {
        this.storeSelectedUserData(selectedRow);
        window.location.href = "/asl_add_contact"; // Navigate to the new route
    }
}


storeSelectedUserData(row) {
    const userId = row.dataset.userId;
    const aslNumber = row.dataset.aslNumber;
    const username = row.dataset.username;
    const twitchUsername = row.dataset.twitchUsername;
    
    localStorage.setItem('selectedUserId', userId);
    localStorage.setItem('selectedUserAslNumber', aslNumber);
    localStorage.setItem('selectedUsername', username);
    localStorage.setItem('selectedTwitchUsername', twitchUsername);
}



  addSelectedFriends() {
    this.rowTargets.forEach(row => {
      if (row.classList.contains('selected')) {
        const userId = row.dataset.userId;
        // Send the friend request for each selected user
      }
    });
  }


  sendMessage(event) {
    event.preventDefault();

    const messageContent = this.messageContentTarget.value;
    const aslNumber = this.aslNumberTarget.value;
    const ulElement = this.messageHistoryTarget.querySelector('ul');

    if (!messageContent.trim() || !aslNumber) {
        console.error('Message content or receiver ID missing.');
        return;
    }

    fetch("/send_message", { // Adjust this endpoint if you have a different route for sending messages
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ asl_number: aslNumber, content: messageContent })
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            const messageDiv = document.createElement('li');
            messageDiv.textContent = `${data.username}: ${data.content}`; 
            ulElement.appendChild(messageDiv);
            this.messageContentTarget.value = ''; // Clear the textarea
            this.scrollToBottom();
        } else {
            console.error('Failed to send the message:', data.message);
        }
    })
    .catch(error => {
        console.error('Error sending the message:', error);
    });
    this.scrollToBottom();

}


  submitFriendRequest() {
    const aslNumber = localStorage.getItem('selectedUserAslNumber');
    const username = localStorage.getItem('selectedUsername');  

    let group;

    if (this.existingGroupRadioTarget.checked) {
        group = this.friendGroupSelectTarget.value;
    } else if (this.newGroupRadioTarget.checked) {
        group = this.newFriendGroupInputTarget.value;
    }
    
    fetch("/send_friend_request", {
        method: "POST",
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ asl_number: aslNumber, username: username, group: group })
    })
    .then(response => response.json())
    .then(data => {
        console.log(data.message);
    })
    .catch(error => {
        console.error('Error sending friend request:', error);
    });
}

toggleGroupSelection() {
  if (this.existingGroupRadioTarget.checked) {
      this.friendGroupSelectTarget.removeAttribute('disabled');
      this.newFriendGroupInputTarget.setAttribute('disabled', 'disabled');
  } else if (this.newGroupRadioTarget.checked) {
      this.newFriendGroupInputTarget.removeAttribute('disabled');
      this.friendGroupSelectTarget.setAttribute('disabled', 'disabled');
  }
}

setupMessagesChannel() {
  this.messagesSubscription = createConsumer().subscriptions.create({
      channel: "MessagesChannel",
  }, {
      connected: () => this._connected(),
      disconnected: () => this._disconnected(),
      received: data => this._received(data)
  });
}

disconnect() {
  // Cleanup code
  if (this.subscription) {
    this.subscription.unsubscribe()
  }
}

scrollToBottom() {
  this.messageHistoryTarget.scrollTop = this.messageHistoryTarget.scrollHeight;
}

_connected() {
  // Called when the subscription is ready for use on the server
}

_disconnected() {
  // Called when the subscription has been terminated by the server
}

_received(data) {
  // Extracting the message from the received data
  this.playUhOhSound();

  const messageContent = data.message;
  const ulElement = this.messageHistoryTarget.querySelector('ul');
  // Getting the message-history div
  const messageHistoryDiv = this.messageHistoryTarget;

  // Appending the message to the div
  ulElement.innerHTML += `<li>${messageContent}</li>`;
    
  this.scrollToBottom();

  // Assuming the sender's ID is part of the received data
  const friendDiv = this.element.querySelector(`[data-friend-id="${data.sender_id}"]`);
  
  if (friendDiv) {
    // Remove old icon and add new one
    friendDiv.innerHTML = ''; // Clear the div content
    friendDiv.classList.add('blinking');
    friendDiv.innerHTML = showSvg('asl-message'); // Add the new icon

    // After a few seconds, stop the blinking effect
    setTimeout(() => {
      friendDiv.classList.remove('blinking');
    }, 5000); // Stop blinking after 5 seconds
  }

}

disconnect() {
  if (this.messagesSubscription) {
      createConsumer().subscriptions.remove(this.messagesSubscription);
  }
}

playUhOhSound() {
  const audio = new Audio(this.uhOhSoundPathValue);
  audio.play();
}

toggleHistory(event) {
  event.preventDefault();
  const historyDiv = this.messageHistoryTarget;

  if (historyDiv.style.display === "none" || !historyDiv.style.display) {
    historyDiv.style.display = "block";
    document.querySelector(".message-field").classList.remove("maximized")
  } else {
    document.querySelector(".message-field").classList.add("maximized")
    historyDiv.style.display = "none";
  }
}

updateCharCount() {
  const textareaValue = this.element.querySelector("#message").value;
  this.aslCharsTarget.value = textareaValue.length;
}






}
