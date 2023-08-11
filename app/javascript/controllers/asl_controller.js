import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["row","aslNumber", "displayName", "twitchName", "existingGroupRadio", "newGroupRadio", "friendGroupSelect", "newFriendGroupInput"];

  connect() {
    console.log("ASL Controller connected");
   // this.setupFriendRequestChannel();
    this.subscribeToChannel();
    
    if (this.hasAslNumberTarget && this.hasDisplayNameTarget && this.hasTwitchNameTarget) {
      
        this.populateFields();
    }

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

  subscribeToChannel() {
    this.aslSubscription = createConsumer().subscriptions.create({ channel: "FriendRequestChannel" }, {
        received: this.received.bind(this)
    });
}

received(data) {
    // Handle received data, e.g., show a notification or update the UI
    console.log('Received data:', data);
}

disconnect() {
    if (this.aslSubscription) {
        createConsumer().subscriptions.remove(this.aslSubscription);
    }
}

}
