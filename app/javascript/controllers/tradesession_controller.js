import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

   this.fillBackground();


  }


  fillBackground() {
    const charBackground = document.querySelector('#charContent');
    const character = '░';

    const fontSize = 16; // Adjust this value to your desired font size
    const lineHeight = 1.0; // Adjust this value to match your desired line height
  
    charBackground.style.fontSize = `${fontSize}px`;
    charBackground.style.lineHeight = lineHeight;
  
    const width = window.innerWidth;
    const height = window.innerHeight;
  
    const columns = Math.ceil((width*2) / fontSize);
    const rows = Math.ceil(height / (fontSize * lineHeight));
  
    let backgroundString = '';
  
    for (let i = 0; i < rows; i++) {
      for (let j = 0; j < columns; j++) {
        backgroundString += character;
      }
      backgroundString += '\n';
    }
  
    charBackground.textContent = backgroundString;
  
  }


}
