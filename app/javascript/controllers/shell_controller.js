import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    
    const history = document.getElementById('history');
    const existingEntries = JSON.parse(localStorage.getItem("commands") || '[]');    
    const last_response = history.getAttribute('data-response');    
    //const last_response_parsed = JSON.parse(last_response).slice(1);

    let parsed_response = [];
    
    for (let i = 0; i < existingEntries.length; i++) {
      
      var current_entry = existingEntries[i].toLowerCase();
      
      if (current_entry !== "ls" && current_entry !== ''){        
        var history_line = document.createElement('DIV');
        history_line.classList.add('command-line');
        history_line.textContent += `C:\\ ${ existingEntries[i] }`;
        
        history.appendChild(history_line);
      }else if(current_entry.toLowerCase() == "ls"){
        
        function IsJsonString(str) {
          try {
            var json = JSON.parse(str);
            if(typeof json === 'object'){
            return JSON.parse(str);
          };
          } catch (e) {
            var new_string  =  JSON.stringify(str);
            return new_string;
          }
        }

      parsed_response = IsJsonString(last_response);
        
      //  if (last_response){
     //     parsed_response = JSON.parse(last_response);    
     //   }
   
        var history_line = document.createElement('DIV');
        history_line.classList.add('command-line');
        history_line.textContent += `${ existingEntries[i] }`;
        
       history.appendChild(history_line);

       if(typeof history_array === 'object'){
        var history_array = IsJsonString(history.dataset.response);
 
        history_array.forEach(formatData);

          function formatData(value, index, array) {            
            let history_line_item = document.createElement('DIV');               
            history_line_item.textContent = `${ value }`;            
          //  history.innerHTML(history_line_item);
           history.appendChild(history_line_item);            
          }
      }
    }
    }
    
    document.getElementById('prompt').innerHTML = '<ul><li>Altama Shell v1.0</li></ul>';
        
    const input = document.getElementById('input');
    input.focus();
    const cursor = document.getElementById('cursor');
    const field_submission = document.getElementById('query');
    const command_lines = document.querySelectorAll('.command-line');

    const last_line = document.createElement('DIV');      
    last_line.textContent = `> ${ last_response }`;
    
    // history_line.textContent = `C:\\ ${ command_history }`;
    if (last_response == 'clear' && command_lines.length > 0){
      console.log('clear:')
        localStorage.clear();        
        command_lines.forEach(e => e.remove());    
    }else if(parsed_response[0] == "LS" ){
      
      const file_array = parsed_response.slice(0)

      file_array.forEach(formatData);

      function formatData(value, index, array) {
        console.log('list loaded');
        
      //  let history_line_item = document.createElement('DIV');    
       // history_line_item.textContent = `${ value }`;
      //  history.appendChild(value);
      }

  }
    if (existingEntries.at(-1) != last_response){
      existingEntries.push(last_response);      
      localStorage.setItem("commands", JSON.stringify(existingEntries));
      history.appendChild(last_line);

      // broken from airplane
   // if JSON.parse(last_response)[0] == "TS"{
  //  for (var i = 0; i < last_response_parsed.length; i++) {
  //    history.appendChild(last_response_parsed[i]) + "<br />";
  //    }
  //  }

  }
   
 
    function focusAndMoveCursorToTheEnd(e) {  
      input.focus();
      
      const range = document.createRange();
      // const selection = window.getSelection();
      const selection = document.querySelector('#input');
      const { childNodes } = input;
      const lastChildNode = childNodes && childNodes.length - 1;
      
      range.selectNodeContents(lastChildNode === -1 ? input : childNodes[lastChildNode]);
      range.collapse(false);
      console.log('selection:', selection);
      console.log('range:', range);
      selection.removeAllRanges();
      selection.addRange(range);
    }
    
    function handleCommand(command) {
      const line = document.createElement('DIV');
      
      line.textContent = `> ${ command }`;
    
      var existingEntries = JSON.parse(localStorage.getItem("commands") || '[]');
      existingEntries.push(command);
      localStorage.setItem("commands", JSON.stringify(existingEntries));

      history.appendChild(line);
    }
    
    // Every time the selection changes, add or remove the .noCursor
    // class to show or hide, respectively, the bug square cursor.
    // Note this function could also be used to enforce showing always
    // a big square cursor by always selecting 1 chracter from the current
    // cursor position, unless it's already at the end, in which case the
    // #cursor element should be displayed instead.
    document.addEventListener('selectionchange', () => {
      if (document.activeElement.id !== 'input') return;
      
      /*
      curious why this doesn't do anything?

      const range = window.getSelection().getRangeAt(0);
      console.log('range-original', range);
      const start = range.startOffset;
      const end = range.endOffset;
      const length = input.textContent.length;
  
      if (end < length) {
        input.classList.add('noCaret');
      } else {
        input.classList.remove('noCaret');
      }
          */
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
      console.log('etarget:',e.target);
      console.log('input:',input);
      if (e.target !== input) focusAndMoveCursorToTheEnd();
    });
    
    input.addEventListener('keydown', (e) => {
      field_submission.value = input.textContent;    
      if (e.key === 'Enter') {
        e.preventDefault();
            
        handleCommand(input.textContent);
        console.log('input.textContent');
        console.log('submit?');
        input.textContent = '';
       // focusAndMoveCursorToTheEnd();
        console.log('actualsubmit?');
        var command_entry = document.querySelector('#command_entry');
        command_entry.submit();
      }
    });
    
    // Set the focus to the input so that you can start typing straigh away:
    input.focus();



        
    }







}