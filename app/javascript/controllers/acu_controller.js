import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    
    document.addEventListener("keydown", function(event) {
      // Check if the key pressed was the "enter" key
      
        // Call your function to perform the desired action
        document.querySelector('#query').value = event.key; 
        const command_entry = document.getElementById("command_entry");
        command_entry.submit(); 
        
      
    });
    

  }
   



}