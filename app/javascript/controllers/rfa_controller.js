import { Controller } from "@hotwired/stimulus"

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
    "rfaAll","rating_field", "review_form", "total_service_fees",
    "total_charge", "commodityCustomerRate","appsPane"]

    connect(){
       this.prices =  Array.from(document.querySelectorAll('[id*="-market-price"]'));
      this.all_commodities = Array.from(document.querySelectorAll('[id*="-market-price"]'));

      if(this.all_commodities.length > 0){

          [...this.all_commodities].forEach(commodity => console.log(commodity.getAttribute('data-commodity')))

          let quantities = Array.from(document.querySelectorAll('.quantity'));
          this.total_quantity =  quantities.map(amount).reduce(sum);
          this.total_market_price =  this.prices.map(amount).reduce(sum);


          const gross_total_price = this.total_quantity * this.total_market_price;
          this.total_charged_amount = 0;
          let discount_amount = document.querySelectorAll('[data-amt]')[0].dataset.amt;
        // this.total_discount = discount_amount / 100.00;
        //  this.net_total_price =  (total_market_price * (1.00 - this.total_discount));
        // console.log('this.net_total_price', this.net_total_price);
        }


    }
 
clear(event){
  
  if(event.target!= this.status_buttonTarget){
    document.querySelector("#chevron").classList.remove("open");
    this.status_menuTarget.classList.remove("open");
  }
}

service_fee(event){
this.total_charged_amount = 0;
let service_fee = parseFloat(event.target.value).toFixed(2);
let total_fees = 0;
let fees_sum = 0;
let original_total = this.net_total_price;
let updated_discount_amount = this.total_discount * original_total;

// let new_total = ((service_fee * gross_total_price)+gross_total_price) + this.net_total_price;
let fee_rate_amt = total_fees / this.total_quantity;
this.total_discounted_amount = 0;

for (var i = 0; i < this.all_commodities.length; i++) {
  let current_commodity = this.all_commodities[i].getAttribute('data-commodity');
  console.log('current_commodity:',this.all_commodities[i]);

  // let commodity_total_price_field = document.getElementById(`rfa_${current_commodity}-total`);
  let current_customer_commodity = document.querySelector(`[data-customercommodity="${current_commodity}"]`);

  let commodity_quantity = parseFloat(document.getElementById(`rfa_${current_commodity}`).value);
  
  
  let selling_price = parseFloat(document.getElementById(`rfa_${current_commodity}-selling-price`).value);
  if (commodity_quantity > 0 && selling_price > 0){
    
    let market_price = parseFloat(document.getElementById(`rfa_${current_commodity}-market-price`).value);
    let commodity_total = document.getElementById(`rfa_${current_commodity}-total`);
    total_fees = (service_fee / 10) * market_price;
    fees_sum += total_fees * commodity_quantity;
    let discount_amount = parseFloat(document.querySelectorAll('[data-amt]')[0].dataset.amt);
    let discount = discount_amount / 100.00;
    let discounted_market_price = market_price - (market_price * discount);
    

// let subtotal = this.total_discounted_amount + (market_price * service_fee)

  //  this.total_discounted_amount = this.total_discounted_amount + (market_price * discount);
    current_customer_commodity.innerHTML = discounted_market_price + total_fees;
    this.total_charged_amount += parseFloat((discounted_market_price + total_fees) * commodity_quantity);
    this.total_service_feesTarget.value = fees_sum;
    commodity_total.value =  ((discounted_market_price * commodity_quantity) + total_fees).toFixed(2);
  } 
}
  
document.getElementById('rangeValue').innerHTML = (service_fee ) + '%';

  let all_totals = document.getElementsByClassName('totals');

//  for (var i = 0; i < all_totals.length; i++) {
 //   this.total_charged_amount = +all_totals[i].value + +this.total_charged_amount ;
 //   console.log('all_totals[i].value : ', this.total_charged_amount );
    
 //   }

let new_total = this.total_charged_amount;

  this.total_chargeTarget.value =  new_total.toFixed(2);

}

  apps_pane(event){
    this.appsPaneTarget.classList.toggle('closed');
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
    this.status_menuTarget.classList.toggle("open");
    document.querySelector("#chevron").classList.toggle("open");
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
