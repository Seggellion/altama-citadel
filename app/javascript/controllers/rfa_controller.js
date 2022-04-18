import { Controller } from "@hotwired/stimulus"

const prices =  Array.from(document.querySelectorAll('[id*="-price"]'));
const all_commodities = Array.from(document.querySelectorAll('[id*="-price"]'));

[...all_commodities].forEach(commodity => console.log(commodity.getAttribute('data-commodity')))

const quantities = Array.from(document.querySelectorAll('.quantity'));
const total_market_price =  prices.map(amount).reduce(sum);
const total_quantity =  quantities.map(amount).reduce(sum);
const gross_total_price = total_quantity * total_market_price;

const discount_amount = document.querySelectorAll('[data-amt]')[0].dataset.amt;
const total_discount = discount_amount / 100.00;
const net_total_price =  (total_market_price * (1.00 - total_discount));

function amount(item){
  return parseFloat(item.value);
}

function sum(prev, next){
  return prev + next;
}


export default class extends Controller {
  static targets = ["form", "status_field", 
  "user", "status_menu", "status_button",
   "rfaUnassigned", "rfaSolved","rfaMine",
    "rfaAll","rating_field", "review_form", 
    "total_charge", "commodityCustomerRate"]

 
clear(event){
  let status_menu_element = document.getElementsByClassName('status-menu-wrapper')[0]
   
  if(event.target!= this.status_buttonTarget){
    
    status_menu_element.classList.remove("open"); 
  }
}

service_fee(event){
let service_fee = Math.floor(event.target.value / 10.00);
let total_fees =  (service_fee * gross_total_price) ;
let original_total =net_total_price ;
let updated_discount_amount = total_discount * original_total;
// let new_total = ((service_fee * gross_total_price)+gross_total_price) + net_total_price;
let fee_rate_amt = total_fees / total_quantity;
let total_discounted_amount = 0;

for (var i = 0; i < all_commodities.length; i++) {
  let current_commodity = all_commodities[i].getAttribute('data-commodity');
  let commodity_quantity = parseFloat(document.getElementById(`rfa_${current_commodity}`).value);
  if (commodity_quantity > 0){
    let commodity_market_price = parseFloat(document.getElementById(`rfa_${current_commodity}-price`).value);
    total_discounted_amount = total_discounted_amount + (commodity_market_price * total_discount);
    let commodity_portion = total_quantity / commodity_quantity;
    console.log('gross_total_price: ',gross_total_price );
    console.log('total_discounted_amount: ',total_discounted_amount );
    console.log('updated_discount_amount: ',updated_discount_amount );
    console.log('original_total: ',original_total );
    console.log('commodity_portion: ',commodity_portion );
    console.log('current_commodity: ',current_commodity );
    console.log('commodity_market_price : ',commodity_market_price  );
    console.log('total_fees : ',total_fees  );
    let commodity_fee_rate = total_fees * commodity_portion;
    //this.commodityCustomerRateTarget.dataset.customerCommodity
    let current_customer_commodity = document.querySelector(`[data-customercommodity="${current_commodity}"]`);
    let original_customer_commodity_rate = (commodity_market_price-(total_discount * commodity_market_price) );
    console.log('commodity_fee_rate : ',commodity_fee_rate );
    console.log('commodity_quantity : ',commodity_quantity  );
    console.log('current_customer_commodity: ', current_customer_commodity );
    console.log('original_customer_commodity_rate: ', original_customer_commodity_rate );
    console.log('total_discount : ', total_discount  );
    current_customer_commodity.innerHTML = original_customer_commodity_rate + commodity_fee_rate;

  } 
}
  document.getElementById('rangeValue').innerHTML = (service_fee * 10.00) + '%';
console.log('sevice-fee', service_fee);
let new_total = total_discounted_amount + service_fee;
// get total  charge before fee addition
// find difference beteen charges.
// divide difference by quantity

//then do this for all commodities
// Find out how much each commodity contributes to total amount
// Associate individual total contribution to customer selling price

//this.commodityCustomerRateTarget.element.innerHTML =  
console.log('commodityCustomerRateTarget: ', this.commodityCustomerRateTargets);
  this.total_chargeTarget.value = new_total;
  console.log('total_market_price:', total_market_price);  
  console.log('total_quantity:', total_quantity);
  console.log('service_fee:', service_fee);
  console.log('new_total:', new_total);
}

  open(event) {
    this.status_fieldTarget.value = 1;
    this.formTarget.submit();
  }

  pending(event) {

    this.status_fieldTarget.value = 2;
    this.formTarget.submit();
  }

  hold(event) {

    this.status_fieldTarget.value = 3;
    this.formTarget.submit();
   // Turbo.navigator.submitForm(this.formTarget);
  }

  free_fuel(event){
    this.target.classList.add('selected');
    Turbo.navigator.submitForm(this.formTarget);
  }

  rfaAll(event){
    this.rfaAllTarget.classList.add('show');
    this.rfaUnassignedTarget.classList.remove('show');
    this.rfaSolvedTarget.classList.remove('show');
    this.rfaMineTarget.classList.remove('show');
  }
  rfaMine(event){
    this.rfaMineTarget.classList.add('show');
    this.rfaAllTarget.classList.remove('show');
    this.rfaUnassignedTarget.classList.remove('show');
    this.rfaSolvedTarget.classList.remove('show');
  }
  rfaUnassigned(event){
    this.rfaUnassignedTarget.classList.add('show');
    this.rfaMineTarget.classList.remove('show');
    this.rfaAllTarget.classList.remove('show');
    this.rfaSolvedTarget.classList.remove('show');
  }

  rfaSolved(event){
    this.rfaSolvedTarget.classList.add('show');
    this.rfaAllTarget.classList.remove('show');
    this.rfaMineTarget.classList.remove('show');
  }

  solved(event) {
    this.status_fieldTarget.value = 4;
    this.formTarget.submit();
  }

  takeit(event){
    event.preventDefault();
    let current_user = this.userTarget.dataset.user
    let element = document.getElementById('rfa_user_assigned_id');
    element.value = current_user
  }


  statusbutton(event){
    event.preventDefault();
    this.status_menuTarget.classList.add("open");
  }
  star1(event){
    this.rating_fieldTarget.value = "1"    
    event.target.classList.add('selected');
    this.review_formTarget.submit();
  }

  star2(event){
    this.rating_fieldTarget.value = "2"
    event.target.classList.add('selected');
    this.review_formTarget.submit();
  }
  star3(event){
    this.rating_fieldTarget.value = "3"
    event.target.classList.add('selected');
    this.review_formTarget.submit();
  }
  star4(event){
    this.rating_fieldTarget.value = "4"
    event.target.classList.add('selected');
    this.review_formTarget.submit();
  }

  star5(event){
    this.rating_fieldTarget.value = "5"
    event.target.classList.add('selected');
    this.review_formTarget.submit();
  }


  verify(event){
    document.getElementById('rsi_verification').classList.add('open');
  }
  
}
