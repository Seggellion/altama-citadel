import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
//connect() {
// this.element.textContent = "Hello World!"
// }
static targets = ["total_field", "mkt_price", "total_discount", "aec_field"]



total_amount(event){

//    let commodity = String(event.currentTarget.name.match(/[^[\]]+(?=])/g));

    let market_container =  event.currentTarget.parentNode.nextElementSibling;
    let total_fees_container = document.getElementById('total_service_fees');
   // let market_price = market_container.querySelector('input').value;
    let current_commodity = event.currentTarget.id.slice(-3).toUpperCase();
    let market_price = parseFloat(document.getElementById(`rfa_${current_commodity}-price`).value);
    let discount_amount = parseFloat(document.querySelectorAll('[data-amt]')[0].dataset.amt);
    let discount = discount_amount  /100.00;
    let discounted_market_price = market_price - (market_price * discount);
    let fees_sum = 0;

    let commodity_total_price_field = document.getElementById(`rfa_${current_commodity}-total`);
    document.getElementById(`rfa_HYD-total`);

    let commodity_quantity = parseFloat(event.currentTarget.value);

    let aec_field = document.getElementById('rfa_aec_rewards');
    let total_charges_field = document.getElementById('rfa_total_charge');

    
    let aec_amount = document.querySelectorAll('[data-aec]')[0];

    let service_fee_percent = parseFloat(document.getElementById('rfa_servicefee').value).toFixed(2);
   // let service_fee_percent = service_fee / 1000.00;

let service_fee_total = (service_fee_percent / 10) * market_price

    let all_totals = document.getElementsByClassName('totals');
    let current_value = event.target.value;
    let aec_rate = +aec_amount.dataset.aec / 100.00;
    let subtotal = (current_value * market_price) * service_fee_percent;
    
   // let calculated_amount = Math.ceil(subtotal - (subtotal * discount));
    
  //  this.total_fieldTarget.value = calculated_amount.toFixed(2);
//console.log('this.total_fieldTarget.value', this.total_fieldTarget.value);
//this.total_fieldTarget.setAttribute("value", calculated_amount.toFixed(2));

let calculated_amount = commodity_quantity *  (discounted_market_price + service_fee_total); 

    commodity_total_price_field.value = calculated_amount.toFixed(2);
    commodity_total_price_field.setAttribute("value", calculated_amount.toFixed(2));
    fees_sum += service_fee_total * commodity_quantity;

    let total_charged_amount = 0.0;
    for (var i = 0; i < all_totals.length; i++) {
    total_charged_amount = +all_totals[i].value + +total_charged_amount;
 
    }

let total_charged_amount_before_discount = total_charged_amount;
let aec_subtotal= Math.ceil(total_charged_amount_before_discount * aec_rate);
    total_charges_field.value = total_charged_amount.toFixed(2);
    total_fees_container.value = fees_sum;
    aec_field.value = aec_subtotal;
    }

}
