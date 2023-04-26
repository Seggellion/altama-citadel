import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "rowHeader", "tbody", "menu","buyLocation", "buyCommodity", "commoditiesData", "sellLocation" ]
  activeIndex = 0;

  
  rowCount = 5; // change this to the number of rows in your table


  connect() {
    //this.addRows();
    window.addEventListener('resize', this.addRows.bind(this));

    document.querySelectorAll('#traderun-menu').forEach((menu) => {
      const menuItems = menu.querySelectorAll('a');
      menuItems[this.activeIndex].classList.add('active');

      document.addEventListener('keydown', (event) => {
        const key = event.key;
        let nextIndex = this.activeIndex;

        if (key === 'ArrowLeft' || key === 'ArrowUp') {
          console.log('left');
          nextIndex = (this.activeIndex === 0) ? menuItems.length - 1 : this.activeIndex - 1;
        } else if (key === 'ArrowRight' || key === 'ArrowDown') {
          console.log('right');
          nextIndex = (this.activeIndex === menuItems.length - 1) ? 0 : this.activeIndex + 1;
        }

        if (key === " ") {          
          event.preventDefault();
        }

        if (nextIndex !== this.activeIndex) {
          menuItems[this.activeIndex].classList.remove('active');
          this.activeIndex = nextIndex;
          menuItems[this.activeIndex].classList.add('active');
        }
      });
    });



    document.addEventListener("keydown", function(event) {
      // Check if the key pressed was the "enter" key
      
      if (event.key === '/') {
        document.querySelector('#traderun-menu').classList.toggle('hidden');
      }else if (event.key === 'Enter') {
        const activeLink =  document.querySelector('#traderun-menu').querySelector('.active');
        if (activeLink && activeLink.tagName === 'A') {
          activeLink.click();
        }
      }

        // Call your function to perform the desired action
    //    document.querySelector('#query').value = event.key; 
     //   const command_entry = document.getElementById("command_entry");
     //   command_entry.submit(); 
        
      
    });
    

  }
   
  shipSelect(){
    let shipsDataElement = document.getElementById("ships-data");
    let shipsData = JSON.parse(shipsDataElement.dataset.ships);
    let buySCUElement = document.getElementById("buySCU");
    let sellSCUElement = document.getElementById("sellSCU");
    let scusHtml = "";
    
    let selectedShipName = event.target.value;
    if (selectedShipName) {
      let selectedShip = shipsData.find(ship => ship.model === selectedShipName)
      if (selectedShip) {        
        buySCUElement.innerHTML = `${selectedShip.scu}`
        sellSCUElement.innerHTML = `${selectedShip.scu}`
      } else {
        buySCUElement.innerHTML = '<p>No ship found.</p>'
      }
    } else {
      buySCUElement.innerHTML = ''
      sellSCUElement.innerHTML = ''
    }
   this.calculator(event);
  }

  buyLocation(){
    this.populateCommoditySelect();
    this.calculator(event);
  }

  buyCommodity(){
    const commoditiesDataElement = document.getElementById("commodities-data");
    const username = document.getElementById("trade_run_username").value;
    const locationData = document.getElementById("trade_run_buy_location").value;
    const ship = document.getElementById("trade_run_ship").value;    
    const commoditiesData = JSON.parse(commoditiesDataElement.dataset.commodities);
    const buyPriceElement = document.getElementById("buyPrice");
    const deltaElement = document.getElementById("delta");

    
    const selectedCommodityName = event.target.value    
    let activeCommodity = []
    if (locationData) {
       activeCommodity = commoditiesData.find(commodity => commodity.name === selectedCommodityName   && commodity.location === locationData)
      if (activeCommodity) {        
        buyPriceElement.innerHTML = `${activeCommodity.sell}`
        deltaElement.setAttribute("marketSell", activeCommodity.sell);
      } else {
        buyPriceElement.innerHTML = 'null'
        deltaElement.setAttribute("marketSell", '0');
      }
    } else {
      buyPriceElement.innerHTML = ''
      
    }
    this.calculator(event);
    this.populateSellLocationSelect(); 
    if(locationData && activeCommodity && username && ship){
    //document.getElementById("traderuns_form").submit();
    }

  }

  sellLocation(){
    const commoditiesDataElement = document.getElementById("commodities-data");
    const commoditiesData = JSON.parse(commoditiesDataElement.dataset.commodities);
    const buyPriceElement = document.getElementById("sellPrice");
    const locationData = document.getElementById("trade_run_sell_location").value;
    const selectedCommodityName = document.getElementById("trade_run_buy_commodity").value;
    // const selectedCommodityName = event.target.value    
    console.log('sellLocation');
    const deltaElement = document.getElementById("delta");
    if (locationData) {
      const activeCommodity = commoditiesData.find(commodity => commodity.name === selectedCommodityName   && commodity.location === locationData)
      if (activeCommodity) {        
        buyPriceElement.innerHTML = `${activeCommodity.buy}`
        deltaElement.setAttribute("marketBuy", activeCommodity.buy);
      } else {
        buyPriceElement.innerHTML = 'null'
      }
    } else {
      buyPriceElement.innerHTML = ''
      
    }
    this.calculator(event);
  }

  createRun() {    
    const username = document.getElementById("trade_run_username").value;
    const locationData = document.getElementById("trade_run_buy_location").value;
    const ship = document.getElementById("trade_run_ship").value;
    const activeCommodity = document.getElementById("trade_run_buy_commodity").value;    
    event.target.innerHTML = "[X]";
    if(locationData && activeCommodity && username && ship){

      document.getElementById("scu_input").value = document.getElementById("sellSCU").innerHTML;
      document.getElementById("buy_price_input").value = document.getElementById("buyPrice").innerHTML;
      document.getElementById("delta_input").value = document.getElementById("delta").innerHTML;
      document.getElementById("sell_price_input").value = document.getElementById("sellPrice").innerHTML;


      document.getElementById("traderuns_form").submit();
      }else{
        let element = event.target;

        setTimeout(() => {
          element.innerHTML = "[  ]";
        }, 1000);
      }
  }
  
  addRows() {
    
    let tbody = this.tbodyTarget;
    let rowHeight = tbody.offsetHeight / this.rowCount;
    let windowHeight = window.innerHeight;
    let maxRowCount = Math.floor((windowHeight - tbody.offsetTop) / rowHeight);
    let html = '';

    for (let i = this.rowCount + 1; i <= maxRowCount; i++) {
      html += `<tr><td class="rownumber">${i}</td><td contenteditable="true"></td><td contenteditable="true"></td><td contenteditable="true"></td></tr>`;
    }

    tbody.insertAdjacentHTML('beforeend', html);
    this.rowCount = maxRowCount;
  }

  onContentChange(event){

    this.calculator(event);

  }

calculator(){
  
  let buyingPrice = parseFloat(document.getElementById("buyPrice").innerHTML)  * 100.00;
  //let sellPriceElement = parseFloat(document.getElementById("sellPrice").innerHTML)   * 100.00;
  let sellingPrice =  parseFloat(document.getElementById("sellPrice").innerHTML) * 100;
  // calculate sale price
  let sellLocation = this.sellLocationTarget.value;
  let buyLocation = this.buyLocationTarget.value;
  let selectedCommodity = this.buyCommodityTarget.value;
  let commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
  let buyCommodity = commoditiesData.find(commodity => commodity.name === selectedCommodity && commodity.location === buyLocation);
  let sellCommodity = commoditiesData.find(commodity => commodity.name === selectedCommodity && commodity.location === sellLocation);  
  let buySCUElement = parseFloat(document.getElementById("buySCU").innerHTML);
  let capitalElement = document.getElementById("capital");
  let profitElement = document.getElementById("profit");
  let incomeElement = document.getElementById("income");
  let capitalCalculation = buyingPrice * buySCUElement;
  let deltaElement = document.getElementById("delta");
  
  let marketBuy = 0;
  let marketSell = 0;
 console.log('buyCommodity', buyCommodity);
 console.log('sellCommodity:', sellCommodity);
if (sellCommodity){
  marketSell = sellCommodity.buy;
}
if (buyCommodity){
 marketBuy = buyCommodity.sell;
}

deltaElement.setAttribute("marketSell", marketSell);
deltaElement.setAttribute("marketBuy", marketBuy);


if (event.target.id === 'buyPrice'){
  console.log('buyPrice');
  if (buyCommodity){
    buyingPrice =  parseFloat(document.getElementById("sellPrice").innerHTML) * 100;
   // sellingPrice = parseFloat(buyCommodity.buy)  * 100;
    //document.getElementById("sellPrice").innerHTML = buyCommodity.buy;
    // deltaElement.setAttribute("marketBuy", marketBuy);
   //  marketBuy = sellingPrice;    
  }else{
    document.getElementById("sellPrice").innerHTML = "ERR"
  }
}else if(event.target.id === 'sellPrice'){
  console.log('sellPrice');
  if (sellCommodity){
    sellingPrice =  parseFloat(document.getElementById("sellPrice").innerHTML) * 100;
   // document.getElementById("sellPrice").innerHTML = buyCommodity.buy;
  //  deltaElement.setAttribute("marketBuy", buyCommodity.sell);
  //   marketBuy = sellingPrice;    
  }else{
    document.getElementById("sellPrice").innerHTML = "ERR"
  }
}else{
  
  document.getElementById("sellPrice").innerHTML = marketSell;
  sellingPrice = parseFloat(marketSell)  * 100;
  console.log('other', marketSell);
}

if (event.target.id === 'sellPrice'){


//sellingPrice = parseFloat(document.getElementById("sellPrice").innerHTML) * 100;
//deltaElement.setAttribute("marketBuy", sellingPrice);

}

 // let marketSell = buyPriceElement;
//  let marketBuy = parseFloat(deltaElement.getAttribute("marketBuy")) * 100;
  let sellSCUElement = parseFloat(document.getElementById("sellSCU").innerHTML);

  let incomeCalculation = sellingPrice * sellSCUElement;
 
  let profitCalculation = (incomeCalculation - capitalCalculation);
  
  let deltaCalculation = profitCalculation - (((marketSell*100)  * buySCUElement) - ((marketBuy*100)  * sellSCUElement));



  if (deltaCalculation){    
    deltaElement.innerHTML = `${Math.round(deltaCalculation)}`;
  }

  if (capitalCalculation > 0){
    capitalElement.innerHTML = `${Math.round(capitalCalculation)}`;
  }

  if (incomeCalculation > 0){
    incomeElement.innerHTML = `${Math.round(incomeCalculation)}`;
  }

  if (profitCalculation > 0){
    profitElement.innerHTML = `${Math.round(profitCalculation)}`;
  }
}



  populateCommoditySelect() {
    const location = this.buyLocationTarget.value
    
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities)
    const commodities = commoditiesData.filter(commodity => commodity.location === location)

    this.buyCommodityTarget.innerHTML = ""
    commodities.forEach(commodity => {
      const option = document.createElement("option")
      option.value = commodity.name
      option.text = commodity.name
      this.buyCommodityTarget.add(option)
    })
  }

  populateSellLocationSelect() {
    const selectedCommodity = this.buyCommodityTarget.value
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities)
    const sellLocations = commoditiesData.filter(commodity => commodity.name === selectedCommodity && commodity.buy > 0)

    this.sellLocationTarget.innerHTML = ""
    // Add the "Please Select location" option as the first choice
    const defaultOption = document.createElement("option")
    defaultOption.value = ""
    defaultOption.text = "Sell location"
    this.sellLocationTarget.add(defaultOption)

    sellLocations.forEach(sellLocation => {
      const option = document.createElement("option")
      option.value = sellLocation.location
      option.text = sellLocation.location
      this.sellLocationTarget.add(option)
    })
  }



}