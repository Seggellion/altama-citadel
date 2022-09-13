import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('test');
    var insert_mode = true;
    document.addEventListener('keydown', function(e) {
      console.log('key:', e.key);
     
     //if ( e.which == 27) {
       if (e.key == "Escape") {
        document.getElementById('vim_command').classList.remove('insert');
        document.getElementById('text_entry').disabled = true;   
        document.getElementById('vim_query').disabled = false;    
        insert_mode = false;
      }

      if (insert_mode == false && e.key == "i") {
        document.getElementById('vim_command').classList.add('insert');        
        document.getElementById('text_entry').disabled = false;
        document.getElementById('vim_query').disabled = true;
        insert_mode = true;
      }

      if (insert_mode == false && e.key == ":") {
        document.getElementById('vim_query').disabled = false;    
        document.getElementById("vim_query").focus();

      }

    });


  }



}