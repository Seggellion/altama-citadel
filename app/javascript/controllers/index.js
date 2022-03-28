// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

document.addEventListener("click", clearMenu);


function clearMenu() {
  let main_menu_element = document.getElementById('main_menu');
  let button_element = document.getElementById('citadel_button');
  //if (main_menu_element.classList.contains("open")){

   if(event.target.id != 'main_menu' && event.target.id != 'citadel_button' ){
    main_menu_element.classList.remove("open");
    button_element.classList.remove("clicked");
    }
  //}
}

