import { Controller } from "@hotwired/stimulus"

export default class extends Controller {


  connect() {

    var insert_mode = true;

    document.addEventListener('keydown', function(e) {

       if (e.key == "Escape") {
        document.getElementById('vim_command').classList.remove('insert');
        document.getElementById('text_entry').disabled = true;   
        document.getElementById('vim_query').disabled = false;   
        document.getElementById('line-numbers').classList.add('no-insert-mode');
        insert_mode = false;
      }

      if (insert_mode == false && e.key == "i") {
        document.getElementById('vim_command').classList.add('insert');        
        document.getElementById('text_entry').disabled = false;
        document.getElementById('vim_query').disabled = true;
        document.getElementById('line-numbers').classList.remove('no-insert-mode');
        insert_mode = true;
      }

      if (insert_mode == false && e.key == ":") {
        document.getElementById('vim_query').disabled = false;    
        document.getElementById("vim_query").focus();

      }

    });



  let myList = document.querySelectorAll('.scroll')


  let isDown = [];
  let startX = [];
  let scrollLeft = [];

  myList.forEach((slider,i)=> {
  
    slider.addEventListener("mousedown", e => {
      isDown[i] = true;
      slider.classList.add("active");
      startX[i] = e.pageX - slider.offsetLeft;
      scrollLeft[i] = slider.scrollLeft;
      console.log('scrolling');
    });
    slider.addEventListener("mouseleave", () => {
      isDown[i] = false;
      slider.classList.remove("active");
    });
    slider.addEventListener("mouseup", () => {
      isDown[i] = false;
      slider.classList.remove("active");
    });
    slider.addEventListener("mousemove", e => {
      if (!isDown[i]) return;
      e.preventDefault();
      const x = e.pageX - slider.offsetLeft;
      const walk = x - startX[i];
      slider.scrollLeft = scrollLeft[i] - walk;
    });
  })


}
}