import { Controller } from "@hotwired/stimulus"
function styler(event){
    event.target.style.backgroundColor = 'transparent'
};
export default class extends Controller {
    static targets = [ "locationField", "localField"] //, "usershipForm" ]



    moonSelect(event){
        var current_shown = document.getElementsByClassName('show')

        if (current_shown.length > 0 ){
            current_shown[0].classList.remove('show');
        }

        var selected_option = event.target.selectedOptions[0].text;
        var selected_element = document.getElementById(selected_option  + '-selector' );
        
        if (selected_option == this.localFieldTarget.dataset.locationName ){
            this.localFieldTarget.hidden = false;
        }else{
            this.localFieldTarget.hidden = true;
        }
        if ( selected_element !== null){
            selected_element.classList.add('show');
        }
    }

    /*addNew(event){

        document.getElementById("userships_form").style.display = "block";
        document.getElementById("submit").style.display = "none";
    }
    */

    selectSubLocation(event){
        event.target.style.backgroundColor = 'yellow'
        this.locationFieldTarget.value = event.target.dataset.location;
        var option_select = document.getElementById('rfa_location_id_parent');


        const newItem = document.createElement("div");
        newItem.innerHTML = "Location: " + event.target.innerHTML;
        newItem.setAttribute("id", "rfa_location_id_parent");

        option_select.parentNode.replaceChild(newItem, option_select);
        this.localFieldTarget.hidden = true;
        
        setTimeout(()=> { styler(event) }, 500);
    }

    locationSelect(event){
        
        var selected_option = event.target.selectedOptions[0].value;
        this.locationFieldTarget.value = selected_option;

    }

    verify(event){
        document.getElementById('rsi_verification').classList.add('open');
        document.getElementById('web').classList.add('modal');
      }
    closeVerify(event){
        document.getElementById('rsi_verification').classList.remove('open');
        document.getElementById('web').classList.remove('modal');
    }

    copyToClipboard(event){
        event.target.preventDefault;
        var text = event.target.text;
        window.navigator.clipboard.writeText(text);
       window.open('https://robertsspaceindustries.com/account/profile', '_blank');
    }

}