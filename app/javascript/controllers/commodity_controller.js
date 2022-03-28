import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
//connect() {
// this.element.textContent = "Hello World!"
// }
static targets = ["total_field", "mkt_price", "total_discount", "aec_field"]


total_amount(event){


//    let commodity = String(event.currentTarget.name.match(/[^[\]]+(?=])/g));

    let market_container =  event.currentTarget.parentNode.nextElementSibling;
    let market_price = market_container.querySelector('input').value;
    let aec_field = document.getElementById('rfa_aec_rewards');
    let total_charges_field = document.getElementById('rfa_total_charge');

    let discount_amount = document.querySelectorAll('[data-amt]')[0].dataset.amt;
    let aec_amount = document.querySelectorAll('[data-aec]')[0];
    let all_totals = document.getElementsByClassName('totals');

    let discount = (discount_amount ) /100.00;
    
    
    let current_value = event.target.value;
    let aec_rate = +aec_amount.dataset.aec / 100.00;
    let subtotal = current_value * market_price;
    
    let calculated_amount = Math.ceil(subtotal - (subtotal * discount));
    
    this.total_fieldTarget.value = calculated_amount;
    
    let total_charged_amount = 0.0;
    for (var i = 0; i < all_totals.length; i++) {
    total_charged_amount = +all_totals[i].value + +total_charged_amount;
    
    }


let total_charged_amount_before_discount = total_charged_amount;
let aec_subtotal= Math.ceil(total_charged_amount_before_discount * aec_rate);
    total_charges_field.value = total_charged_amount;
    
    aec_field.value = aec_subtotal;
    }

}
