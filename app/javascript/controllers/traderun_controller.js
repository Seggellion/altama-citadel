import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "rowHeader", "tbody", "menu" ]
  activeIndex = 0;

  
  rowCount = 5; // change this to the number of rows in your table


  connect() {
    this.addRows();
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
    const shipsDataElement = document.getElementById("ships-data");
    const shipsData = JSON.parse(shipsDataElement.dataset.ships);
    const buySCUElement = document.getElementById("buySCU");
    const sellSCUElement = document.getElementById("sellSCU");
    let scusHtml = "";
    const selectedShipName = event.target.value
    if (selectedShipName) {
      const selectedShip = shipsData.find(ship => ship.model === selectedShipName)
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
    this.calculator();
  }

  buyLocation(event){
    this.calculator();
  }

  buyCommodity(){
    const commoditiesDataElement = document.getElementById("commodities-data");
    const username = document.getElementById("trade_run_username").value;
    const commoditiesData = JSON.parse(commoditiesDataElement.dataset.commodities);
    const buyPriceElement = document.getElementById("buyPrice");
    const deltaElement = document.getElementById("delta");
    const locationData = document.getElementById("trade_run_buy_location").value;
    const ship = document.getElementById("trade_run_ship").value;
    const selectedCommodityName = event.target.value    
    let activeCommodity = []
    if (locationData) {
       activeCommodity = commoditiesData.find(commodity => commodity.name === selectedCommodityName   && commodity.location === locationData)
      if (activeCommodity) {        
        buyPriceElement.innerHTML = `${activeCommodity.sell}`
        deltaElement.setAttribute("marketSell", activeCommodity.sell);
      } else {
        buyPriceElement.innerHTML = 'null'
      }
    } else {
      buyPriceElement.innerHTML = ''
      
    }
    this.calculator();
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
    this.calculator();
  }


  
  addRows() {
    const tbody = this.tbodyTarget;
    const rowHeight = tbody.offsetHeight / this.rowCount;
    const windowHeight = window.innerHeight;
    const maxRowCount = Math.floor((windowHeight - tbody.offsetTop) / rowHeight);
    let html = '';

    for (let i = this.rowCount + 1; i <= maxRowCount; i++) {
      html += `<tr><td class="rownumber">${i}</td><td contenteditable="true"></td><td contenteditable="true"></td><td contenteditable="true"></td></tr>`;
    }

    tbody.insertAdjacentHTML('beforeend', html);
    this.rowCount = maxRowCount;
  }

  onContentChange(event){
    
    this.calculator();

  }

calculator(){
  
  let buyPriceElement = parseFloat(document.getElementById("buyPrice").innerHTML)  * 100.00;
  let sellPriceElement = parseFloat(document.getElementById("sellPrice").innerHTML)   * 100.00;
  let sellSCUElement = parseFloat(document.getElementById("sellSCU").innerHTML);
  let buySCUElement = parseFloat(document.getElementById("buySCU").innerHTML);
  let capitalElement = document.getElementById("capital");
  let profitElement = document.getElementById("profit");
  let incomeElement = document.getElementById("income");
  let capitalCalculation = buyPriceElement * buySCUElement;
  let incomeCalculation = sellPriceElement * sellSCUElement;
  let profitCalculation = incomeCalculation - capitalCalculation;
  let deltaElement = document.getElementById("delta");
  let marketSell = parseFloat(deltaElement.getAttribute("marketSell")) * 100;
  let marketBuy = parseFloat(deltaElement.getAttribute("marketBuy")) * 100;

  let deltaCalculation = profitCalculation - ((marketBuy * sellSCUElement) - (marketSell * buySCUElement));
  console.log('profit:', profitCalculation);
  console.log('buySCUElement:', buySCUElement);
  if (deltaCalculation){
    
    deltaElement.innerHTML = `${deltaCalculation}`;
  }

  if (capitalCalculation > 0){
    capitalElement.innerHTML = `${capitalCalculation}`;
  }

  if (incomeCalculation > 0){
    incomeElement.innerHTML = `${incomeCalculation}`;
  }

  if (profitCalculation > 0){
    profitElement.innerHTML = `${profitCalculation}`;
  }
}


}