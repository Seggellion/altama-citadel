import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
        document.getElementById('prompt').innerHTML = '<ul><li>Altama Shell v1.0</li></ul>';

        const history = document.getElementById('history');
        const input = document.getElementById('input');
        const cursor = document.getElementById('cursor');
        const command_history = window.localStorage.getItem('commands');
        const last_response = history.getAttribute('data-response');
        const existingEntries = JSON.parse(localStorage.getItem("commands") || '[]');
        if (existingEntries.at(-1) != last_response){
            // var existingEntries = JSON.parse(localStorage.getItem("commands") || '[]');
            existingEntries.push(last_response);
            localStorage.setItem("commands", JSON.stringify(existingEntries));
        }
    

    
        for (let i = 0; i < existingEntries.length; i++) {
        // text += cars[i] + "<br>";
        var history_line = document.createElement('DIV');
        history_line.classList.add('command-line');
        history_line.textContent += `C:\\ ${ existingEntries[i] }`;
        history.appendChild(history_line);
        }
    
    const command_lines = document.querySelectorAll('.command-line');

    // history_line.textContent = `C:\\ ${ command_history }`;
    if (last_response == 'clear' && command_lines.length > 0){
        
        
        localStorage.clear();
        
        command_lines.forEach(e => e.remove());
    
    }
    
    
    function focusAndMoveCursorToTheEnd(e) {  
      input.focus();
      
      const range = document.createRange();
      const selection = window.getSelection();
      const { childNodes } = input;
      const lastChildNode = childNodes && childNodes.length - 1;
      range.selectNodeContents(lastChildNode === -1 ? input : childNodes[lastChildNode]);
      range.collapse(false);
    
      selection.removeAllRanges();
      selection.addRange(range);
    }
    
    function handleCommand(command) {
      const line = document.createElement('DIV');
      const field_submission = document.getElementById('query');
      
      line.textContent = `C:\\ ${ command }`;
      console.log('command:',command);
      field_submission.value = command;
      
      var existingEntries = JSON.parse(localStorage.getItem("commands") || '[]');
      existingEntries.push(command);
      localStorage.setItem("commands", JSON.stringify(existingEntries));
      history.appendChild(line);
    }
    
    // Every time the selection changes, add or remove the .noCursor
    // class to show or hide, respectively, the bug square cursor.
    // Note this function could also be used to enforce showing always
    // a big square cursor by always selecting 1 chracter from the current
    // cursor position, unless its already at the end, in which case the
    // cursor element should be displayed instead.
    
    document.addEventListener('selectionchange', () => {
      if (document.activeElement.id !== 'input') return;

      const range = window.getSelection().getRangeAt(0);
      const start = range.startOffset;
      const end = range.endOffset;
      const length = input.textContent.length;
      
    
      if (end < length) {
        input.classList.add('noCaret');
      } else {
        input.classList.remove('noCaret');
      }
    });
    
    input.addEventListener('input', () => {    
      // If we paste HTML, format it as plain text and break it up
      // input individual lines/commands:
      if (input.childElementCount > 0) {
        const lines = input.innerText.replace(/\n$/, '').split('\n');
        const lastLine = lines[lines.length - 1];
    
    
        for (let i = 0; i <= lines.length - 2; ++i) {
          handleCommand(lines[i]);
        }
      
        input.textContent = lastLine;
        focusAndMoveCursorToTheEnd();
      }
      
      // If we delete everything, display the square caret again:
      if (input.innerText.length === 0) {
        input.classList.remove('noCaret');  
      }  
    });
    
    document.addEventListener('keydown', (e) => {   
      // If some key is pressed outside the input, focus it and move the cursor
      // to the end:
      if (e.target !== input) focusAndMoveCursorToTheEnd();
    });
    
    input.addEventListener('keydown', (e) => {    
      if (e.key === 'Enter') {
        e.preventDefault();
            
        handleCommand(input.textContent);    
        input.textContent = '';
        focusAndMoveCursorToTheEnd();
        document.getElementById('command_entry').submit();
      }
    });
    
    // Set the focus to the input so that you can start typing straigh away:
    input.focus();

        
        
    }




}