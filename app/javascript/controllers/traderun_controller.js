import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "entry","field","rowHeader", "tbody", "menu","buyLocation", "buyCommodity", "commoditiesData", "sellLocation",
   "menuItem", "newTradeSession", "mainMenu","sessionMenu","streamchartMenu","existingTradeSession", "commoditiesTradeRun","ScoreBoard" ]
  activeIndex = 0;

  
  rowCount = 5; // change this to the number of rows in your table


  connect() {
    //this.addRows();
    window.addEventListener('resize', this.addRows.bind(this));
    
    this.activeIndex = 0;
    this.setActiveItem();
    document.addEventListener("keydown", this.handleKeydown.bind(this));

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



    this.updateTraderunFooterVisibility();
    this.observeDOMChanges();


    document.addEventListener("keydown", function(event) {
      // Check if the key pressed was the "enter" key
      
      if (event.key === '/') {
        document.querySelector('#traderun-menu').classList.toggle('hidden');
      }
    });
  }


  // Function added to hide the greeting

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }
  }


  async loadCommodities(event) {
    let locationName= event.target.value;
    let encodedLocationName = encodeURIComponent(locationName);
    let response = await fetch(`/commodities_by_location?location=${encodedLocationName}`);
    let commodities = await response.json();

    let commoditySelect = document.getElementById("commodity-select");
    commoditySelect.innerHTML = "";  // Clear existing options

    commodities.forEach((commodity) => {
      let option = new Option(commodity.name, commodity.name);
      commoditySelect.options.add(option);
    });
  }


  updateTraderunFooterVisibility() {
    var greetingElement = document.querySelector('#greeting');
    var traderunFooterElement = document.querySelector('#traderun_footer');
    var isGreetingHidden = greetingElement && greetingElement.classList.contains('hidden');

    if (!isGreetingHidden && traderunFooterElement) {
      traderunFooterElement.style.display = 'none';
    } else if (traderunFooterElement) {
      traderunFooterElement.style.display = '';
    }
  }

  observeDOMChanges() {
    this.observer = new MutationObserver((mutations) => {
      this.updateTraderunFooterVisibility();
    });

    var config = {
      attributes: true,
      childList: true,
      subtree: true,
      attributeFilter: ['class']
    };

    this.observer.observe(document.body, config);
  }

  // end of greeting function


  handleKeydown(event) {
    switch (event.key) {
        case "ArrowUp":
            this.activeIndex = Math.max(0, this.activeIndex - 1);
            break;
        case "ArrowDown":
            this.activeIndex = Math.min(this.menuItemTargets.length - 1, this.activeIndex + 1);
            break;
        case "Escape":
            this.handleEscapeKey();
            break;
        case "Enter":
            this.handleEnterKey();
            break;
    }
    this.setActiveItem();
}

handleEscapeKey() {
    if (document.querySelector("#traderun_footer")) {
        console.log('escape pressed');
        // Select the parent element
        const container = document.querySelector('.traderun-container');

// Select all direct children of #traderun except #traderun_footer
// const elementsToRemove = traderun.querySelectorAll(':scope > *:not(#traderun_footer)');
const elementsToRemove = container.querySelectorAll(':scope > *:not(#traderun_footer)');

// Loop through the NodeList and remove each element
elementsToRemove.forEach(element => {
    element.remove();
});
  //      window.location.href = "/traderun_command.back?timestamp=" + new Date().getTime();
        window.location.assign("/traderun_command.back?timestamp=" + new Date().getTime());

//        window.location.href = "/traderun_command.back";
    }
}

handleEnterKey() {
    const action = this.menuItemTargets[this.activeIndex].dataset.action;
    switch (action) {
        case "startNewTradeRun":
            this.startNewTradeRun();
            break;
        case "existingTradeSession":
            this.existingTradeSession();
            break;
        case "commoditiesTradeRun":
            this.commoditiesTradeRun();
            break;
        case "StarBitizenRuns":
            this.starBitizenRuns();
            break;
        case "Scoreboard":
            this.scoreboard();
            break;
        case "sessionStreamCharts":
            this.sessionStreamCharts();
            break;
        default:
            this.defaultEnterKeyAction();
            break;
    }
}

startNewTradeRun() {
    this.mainMenuTargets.forEach(menu => menu.classList.add("hidden"));
    document.querySelector('#greeting').classList.add('hidden');
    this.newTradeSessionTarget.classList.remove("hidden");
    this.fillBackground();
    const inputField = document.querySelector('#trade_session_session_date');
    if (inputField) {
        setTimeout(() => {
            inputField.focus();
        }, 1000);
    }
}

existingTradeSession() {
    this.mainMenuTargets.forEach(menu => menu.classList.add("hidden"));
    document.querySelector('#greeting').classList.add('hidden');
    this.existingTradeSessionTarget.classList.remove("hidden");
    this.fillBackground();
}

commoditiesTradeRun() {
    this.mainMenuTargets.forEach(menu => menu.classList.add("hidden"));
    document.querySelector('#greeting').classList.add('hidden');
    this.commoditiesTradeRunTarget.classList.remove("hidden");
    this.fillBackground();
}

starBitizenRuns() {
    this.mainMenuTargets.forEach(menu => menu.classList.add("hidden"));
    document.querySelector('#greeting').classList.add('hidden');
    this.commoditiesTradeRunTarget.classList.add("hidden");
    window.location.href = '/star_bitizen_chart';
}

scoreboard() {
    this.mainMenuTargets.forEach(menu => menu.classList.add("hidden"));
    document.querySelector('#greeting').classList.add('hidden');
    this.ScoreBoardTarget.classList.remove("hidden");
    this.fillBackground();
    const inputField = document.querySelector('#scoreboard_input_field');  // Assuming the ID of the input field related to scoreboard
    if (inputField) {
        setTimeout(() => {
            inputField.focus();
        }, 1000);
    }
}

sessionStreamCharts() {
    this.streamchartMenuTarget.classList.remove("hidden");
    this.sessionMenuTarget.classList.add("hidden");
}

defaultEnterKeyAction() {
    const activeMenuItem = this.menuItemTargets[this.activeIndex];
    const activeLink = activeMenuItem.querySelector('a');
    if (activeLink) {
        if (activeMenuItem.dataset.newwindow) {
            window.open(activeLink.href, '_blank');
        } else {
            window.location.href = activeLink.href;
        }
    }
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


  setActiveItem() {
    this.menuItemTargets.forEach((item, index) => {
      item.classList.toggle("active", index === this.activeIndex);
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
    
   this.calculator(event.target);
  }

  buyLocation(){
    this.populateCommoditySelect();
    this.calculator(event.target);
  }

  buyCommodity(event){
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
        // Filter by name and location
        let filteredCommodities = commoditiesData.filter(commodity => commodity.name === selectedCommodityName && commodity.location === locationData);
       
        // Sort by updated_at in descending order
        filteredCommodities.sort((a, b) => {
            const dateA = new Date(a.updated_at), dateB = new Date(b.updated_at);
            return dateB - dateA;
        });
    
        // Set activeCommodity to the first element in the sorted array
        activeCommodity = filteredCommodities[0];
    
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

    this.calculator(event.target);
    this.populateSellLocationSelect(event.target); 
    if(locationData && activeCommodity && username && ship){
    //document.getElementById("traderuns_form").submit();
    }
    
  }

  sellLocation(event) {
    const selectedLocation = event.target.value;
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    const selectedCommodities = commoditiesData.filter(commodity => commodity.location === selectedLocation && commodity.buy > 0);
  
    // Check if createSplit is toggled
    const parentTr = event.target.closest('tr');
    const splitInput = parentTr.querySelector('.split_input');
    const isSplit = splitInput.value === 'true';
  
    const buyPriceElement = parentTr.querySelector('#buyPrice');
    const sellPriceElement = parentTr.querySelector('#sellPrice');
  
    // Clear the previous sell price inputs
    sellPriceElement.innerHTML = '';
  
    if (isSplit) {
      // Clear existing buy price content
      buyPriceElement.innerHTML = '';
      document.getElementById("prof_scu").innerHTML = '';
      // Get all selected commodities for this row
      const selectedCommoditiesInputs = parentTr.querySelectorAll('select[name="trade_run[buy_commodities][]"]');
  
      // Create an array to store the commodity data
      const commoditiesArray = [];
  
      selectedCommoditiesInputs.forEach((input, index) => {
        const commodityName = input.value;
        const commodityData = selectedCommodities
        .filter(commodity => commodity.name === commodityName)
        .sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at))[0];

        if (commodityData) {
          // Create new inputs for commodity buy and sell price
          const newSellInput = document.createElement('input');
          newSellInput.type = 'number';
          newSellInput.className = 'split-inputs uec';
          newSellInput.value = commodityData.buy;
          sellPriceElement.appendChild(newSellInput);
          const commodityBuyPrice = document.querySelector(`[data-commodity="${commodityData.name}"] .uec`).value;
          
          // Push the commodity data to the array          
          commoditiesArray.push({
            commodity_id: commodityData.id,
            commodity_buy: commodityBuyPrice,
            commodity_sell: commodityData.buy,
            scu: parentTr.querySelector('.scu').value
          });
        }
      });

      // Get the split_cmdty_json element
      const splitCmdtyJson = document.getElementById('split_cmdty_json');
  
      // Set the value to the stringified array
      splitCmdtyJson.value = JSON.stringify(commoditiesArray);
      
    } else {
      const selectedCommodity = selectedCommodities[0];
      if (selectedCommodity) {
        buyPriceElement.value = selectedCommodity.sell;
        sellPriceElement.value = selectedCommodity.buy;
        sellPriceElement.innerHTML = selectedCommodity.buy;
      }
    }
    // Find an element that contains the row you want to calculate for
    const elementWithinRow = parentTr;
  
    // Call the calculator function
    this.calculator(elementWithinRow);
  }

  createRun(event) {    
    const username = document.getElementById("trade_run_username").value;
    const locationData = document.getElementById("trade_run_buy_location").value;
    const ship = document.getElementById("trade_run_ship").value;
    const parentTr = event.target.closest('tr');
    
    let profit = "0";
    let scu = "0";
    const activeCommodity = document.getElementById("trade_run_buy_commodity").value;   
    const splitInput = parentTr.querySelector('.split_input');
    const isSplit = splitInput.value === 'true';
    
    if (isSplit) {
      profit = this.calculateTotalProfit(parentTr);
      scu = this.calculateTotalSCU(parentTr);
      
      document.getElementById("sell_price_input").value = 0;
    }else{
      profit = document.querySelector("#profit div").innerHTML;
      scu =  document.getElementById("sellSCU").innerHTML
      document.getElementById("sell_price_input").value = document.getElementById("sellPrice").innerHTML;
    }
    event.target.innerHTML = "[X]";
    
    if(locationData && activeCommodity && username && ship){
      
      document.getElementById("scu_input").value = scu;
      document.getElementById("buy_price_input").value = document.getElementById("buyPrice").innerHTML;
      document.getElementById("delta_input").value = document.getElementById("delta").innerHTML;
      document.getElementById("profit_input").value = profit;

      document.getElementById("traderuns_form").submit();
      }else{
        let element = event.target;

        setTimeout(() => {
          element.innerHTML = "[  ]";
        }, 1000);
      }
  }

  createSplit() {
    const username = document.getElementById("trade_run_username").value;
    const locationData = document.getElementById("trade_run_buy_location").value;
    const ship = document.getElementById("trade_run_ship").value;
    // Find the parent row
    const parentTr = event.target.closest('tr');
  
    // Check if createSplit is toggled
    const splitInput = parentTr.querySelector('.split_input');
    const commodityElement = parentTr.querySelector("#trade_run_buy_commodity");
    const splitContainer = parentTr.querySelector(".split-container");
  
    if (event.target.innerHTML.trim() === "[X]") {
      event.target.innerHTML = "[  ]";
      splitInput.value = "false";
      if (commodityElement) {
        commodityElement.classList.remove('hidden'); // show
      }
      if (splitContainer) {
        splitContainer.classList.add('hidden'); // hide
      }
    } else if (locationData && username && ship) {
      event.target.innerHTML = "[X]";
      splitInput.value = "true";
      if (commodityElement) {
        commodityElement.classList.add('hidden');  // hide
      }
      if (splitContainer) {
        splitContainer.classList.remove('hidden'); // show
      }
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
console.log('oncontentchange');
    this.calculator(event.target);

  }

  calculator(elementWithinRow) {
    const parentTr = elementWithinRow.closest('tr');
    const splitInput = parentTr.querySelector('.split_input');
    const isSplit = splitInput.value === 'true';

    const buySCUElement = isSplit ? this.calculateTotalSCU(parentTr) : parseFloat(document.getElementById("buySCU").innerHTML);
    const buyCommodity = this.getCommodity(this.buyLocationTarget.value, this.buyCommodityTarget.value);
    const sellCommodity = this.getCommodity(this.sellLocationTarget.value, this.buyCommodityTarget.value);

    this.clearExistingContent();

    const marketBuy = buyCommodity ? buyCommodity.sell : 0;
    const marketSell = sellCommodity ? sellCommodity.buy : 0;
    
    this.setDeltaAttributes(marketSell, marketBuy);
if (elementWithinRow.id !== "sellPrice"){
    this.updatePriceElements(event.target.id, buyCommodity, sellCommodity, isSplit, marketSell);
  }
    if (isSplit) {
      this.calculateSplitCommodities(parentTr);
    } else {
      this.calculateRegularCommodities();
    }

}

calculateTotalProfit(parentTr) {
  const profitDivs = parentTr.querySelectorAll('#profit div');
  return Array.from(profitDivs).reduce((total, div) => total + parseInt(div.innerHTML || 0), 0);
}

calculateTotalSCU(parentTr) {
  const scuElements = parentTr.querySelectorAll('.scu');
  return Array.from(scuElements).reduce((total, scuElement) => total + parseInt(scuElement.value || 0), 0);
}

calculateProfitPerSCU(parentTr) {
  
  const totalProfit = this.calculateTotalProfit(parentTr);
  const totalSCU = this.calculateTotalSCU(parentTr);
  
  // To avoid division by zero
  if (totalSCU === 0) {
    return 0;
  }

  return totalProfit / totalSCU;
}

updateLocation(event){
  const url = this.data.get('url');
  const id = event.target.dataset.id;
  const name = event.target.name;
  const value = event.target.value;
  const data = { "trade_run": {} };
  data["trade_run"][name] = value;

  fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-CSRF-Token': document.querySelector('[name=csrf-token]').content
    },
    body: JSON.stringify(data)
  }).then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json(); // this line parses the JSON response into a JavaScript object
  }).then(data => {
    console.log("Fetched data: ", data); // log the data
    if (data && data.status === 'ok') {
     
      const sellPriceElement = event.target.closest('tr').querySelector('#sell_price');
      if (sellPriceElement) {
        
        sellPriceElement.value = data.buy_price; 
        
        event.target.parentElement.innerHTML = value;
        
       
      }
    }
  })
}

getCommodity(location, commodityName) {
  const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
  
  // Filter by name and location
  const filteredCommodities = commoditiesData.filter(commodity => commodity.name === commodityName && commodity.location === location);

  // Sort by updated_at in descending order
  filteredCommodities.sort((a, b) => {
      const dateA = new Date(a.updated_at), dateB = new Date(b.updated_at);
      return dateB - dateA;
  });

  // Return the first element in the sorted array
  return filteredCommodities[0];
}

 clearExistingContent() {  
    document.getElementById("capital").innerHTML = '';
    document.getElementById("income").innerHTML = '';
    document.getElementById("profit").innerHTML = '';
    document.getElementById("prof_scu").innerHTML = '';
}

 calculateSplitCommodities(parentTr) {
    const scuElements = parentTr.querySelectorAll('.scu');
    const uecElements = parentTr.querySelectorAll('.split-inputs.uec');
    const sellUecElements = parentTr.querySelectorAll('#sellPrice .split-inputs.uec');

    let totalProfit = 0;
    let totalScu = 0;

    Array.from(scuElements).forEach((scuElement, i) => {
        const scuValue = parseFloat(scuElement.value || 0);
        const uecValue = parseFloat(uecElements[i].value || 0);
        const sellUecValue = parseFloat(sellUecElements[i].value || 0);

        const individualCapital = scuValue * uecValue;
        const individualIncome = scuValue * sellUecValue;
        const individualProfit = individualIncome - individualCapital;
        totalProfit += individualProfit;
        totalScu += scuValue;

        this.appendContentToElements(individualCapital, individualIncome, individualProfit);
    });
    const totalProfitPerScu = totalScu ? totalProfit / totalScu : 0;
    
    this.appendContentToElement('prof_scu', totalProfitPerScu);
}

 calculateRegularCommodities() {
    let buyingPrice = parseFloat(document.getElementById("buyPrice").innerHTML);
    let sellingPrice = parseFloat(document.getElementById("sellPrice").innerHTML);
    let buySCUElement = parseFloat(document.getElementById("buySCU").innerHTML);
    
    let capitalCalculation = buyingPrice * buySCUElement;
    let incomeCalculation = sellingPrice * buySCUElement;
    let profitCalculation = incomeCalculation - capitalCalculation;
    let profit_scu = profitCalculation / buySCUElement;
    this.appendContentToElements(capitalCalculation, incomeCalculation, profitCalculation, profit_scu);
}

 appendContentToElements(capital, income, profit, profit_scu) {
  this.appendContentToElement('capital', capital);
  this.appendContentToElement('income', income);
  this.appendContentToElement('profit', profit);
if (profit_scu){
  this.appendContentToElement('prof_scu', profit_scu);
}
}

 appendContentToElement(elementId, value) {
    const element = document.getElementById(elementId);
    const div = document.createElement('div');
    div.textContent = `${Math.round(value)}`;
    element.appendChild(div);
}

 setDeltaAttributes(marketSell, marketBuy) {
  const deltaElement = document.getElementById("delta");
  deltaElement.setAttribute("marketSell", marketSell);
  deltaElement.setAttribute("marketBuy", marketBuy);
}

 updatePriceElements(targetId, buyCommodity, sellCommodity, isSplit, marketSell) {
  if (targetId === 'buyPrice') {
    this.updateBuyPrice(buyCommodity);
  } else if (targetId === 'sellPrice') {
    this.updateSellPrice(sellCommodity);
  } else if (!isSplit) {
    console.log('marketSell', marketSell);
      document.getElementById("sellPrice").innerHTML = marketSell;
  }
}

 updateBuyPrice(buyCommodity) {
  if (buyCommodity) {
      document.getElementById("sellPrice").innerHTML = buyCommodity.buy;
  } else {
      document.getElementById("sellPrice").innerHTML = "ERR";
  }
}

 updateSellPrice(sellCommodity) {
  if (sellCommodity) {
      document.getElementById("sellPrice").innerHTML = sellCommodity.buy;
  } else {
      document.getElementById("sellPrice").innerHTML = "ERR";
  }
}

populateCommoditySelect() {
  const location = this.buyLocationTarget.value;

  const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
  const commodities = commoditiesData.filter(commodity => commodity.location === location && commodity.sell > 0);

  // Sort commodities by updated_at in descending order
  commodities.sort((a, b) => {
    const dateA = new Date(a.updated_at), dateB = new Date(b.updated_at);
    return dateB - dateA;
  });

  // Reduce to unique commodities
  const uniqueCommodities = commodities.reduce((acc, current) => {
    const x = acc.find(item => item.name === current.name);
    if (!x) {
      return acc.concat([current]);
    } else {
      return acc;
    }
  }, []);

  this.buyCommodityTarget.innerHTML = "";
  uniqueCommodities.forEach(commodity => {
    const option = document.createElement("option");
    option.value = commodity.name;
    option.text = commodity.name;
    this.buyCommodityTarget.add(option);
  });
}

populateSellLocationSelect(elementWithinRow) {
  this.fetchLocationsAndPopulate(elementWithinRow)
    .catch(error => console.error('Error:', error));
}


async fetchLocationsAndPopulate(elementWithinRow) {
  const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
 
  // Fetch locations data from the API
  const locationsData = JSON.parse(document.getElementById('locations-data').dataset.locations);


  // Find the parent row
  const parentTr = elementWithinRow.closest('tr');
 

  // Check if createSplit is toggled
  const splitInput = parentTr.querySelector('.split_input');
  const isSplit = splitInput.value === 'true';
  
  let selectedCommodityNames;

  if (isSplit) {
    // Get the selected commodities from all .split-commodity select fields within the row
    const commoditySelects = parentTr.querySelectorAll('.split-commodity select');
    selectedCommodityNames = Array.from(commoditySelects).map(select => select.value);
  } else {
    selectedCommodityNames = [this.buyCommodityTarget.value];
  }

  // Create an empty array to store the latest commodities
  let latestCommodities = [];

  // Iterate over each selected commodity
  for(let name of selectedCommodityNames) {
    // Filter commodities by the selected name
    let sameNameCommodities = commoditiesData.filter(commodity => commodity.name === name && commodity.buy > 0);
    
    // Iterate over each unique location of the sameNameCommodities
    for(let location of [...new Set(sameNameCommodities.map(commodity => commodity.location))]) {
      // Filter commodities by location
      let sameLocationCommodities = sameNameCommodities.filter(commodity => commodity.location === location);

      // Sort commodities by updated_at in descending order
      sameLocationCommodities.sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));

      // Push the most recent commodity to the latestCommodities array
      latestCommodities.push(sameLocationCommodities[0]);
    }
  }

  // Generate a list of unique locations
  const sellLocations = [...new Set(latestCommodities.map(commodity => commodity.location))];

  // Clear the current sell location options
  const sellLocationSelect = parentTr.querySelector('[data-traderun-target="sellLocation"]');
  sellLocationSelect.innerHTML = "";

  // Add the "Please Select location" option as the first choice
  const defaultOption = document.createElement("option")
  defaultOption.value = ""
  defaultOption.text = "Sell location"
  sellLocationSelect.add(defaultOption)
  
  // Add unique locations to the select field
  sellLocations.forEach(location => {
//    const locationData = locationsData.data.find(loc => loc.attributes.name === location);
const locationData = locationsData.find(loc => loc.name === location);

if(locationData) {
  const parent = locationData.parent;
  const option = document.createElement("option");
  option.value = location;
  option.text = `${parent ? parent + ' - ' : ''}${location}`;
  sellLocationSelect.add(option);
} else {
  console.log(`Location ${location} not found in locationsData`);
}
  });
}

  addCommodity(event) {
    event.preventDefault();

    const location = this.buyLocationTarget.value
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    
    // Use helper function to get latest commodities
    const buyCommodities = this.getLatestCommodities(commoditiesData, location);
    const existingSelects = this.element.querySelectorAll('.split-container select');

    if (existingSelects.length < buyCommodities.length) {
      const id = new Date().getTime();
      const wrapper = document.createElement('div');
      wrapper.innerHTML = this.selectField(id, buyCommodities).trim();

      this.element.querySelector('.split-container').appendChild(wrapper.firstChild);
    } else {
      alert('You have added all available commodities. No more can be added.')
    }
  }

  getLatestCommodities(commoditiesData, location) {
    let sameLocationCommodities = commoditiesData.filter(commodity => commodity.location === location && commodity.sell > 0);
    
    // Get unique names of commodities at this location
    let uniqueNames = [...new Set(sameLocationCommodities.map(commodity => commodity.name))];
    
    // Create an empty array to store the latest commodities
    let latestCommodities = [];

    for(let name of uniqueNames) {
      // Filter commodities by name
      let sameNameCommodities = sameLocationCommodities.filter(commodity => commodity.name === name);
      // Sort commodities by updated_at in descending order
      sameNameCommodities.sort((a, b) => new Date(b.updated_at) - new Date(a.updated_at));

      // Push the most recent commodity to the latestCommodities array
      latestCommodities.push(sameNameCommodities[0]);
    }

    return latestCommodities;
  }

  selectField(id, buyCommodities) {
    const selectedCommodities = Array.from(this.element.querySelectorAll('.split-container select')).map(select => select.value);
    const commodities = buyCommodities.filter(commodity => !selectedCommodities.includes(commodity.name));

    let options = commodities.map(commodity => 
      `<option value="${commodity.name}">${commodity.name}</option>`
    ).join('');

    return `
    <div class="split-commodity" id="commodity-${id}">
      <select name="trade_run[buy_commodities][]"  data-action="change->traderun#updateUec">
        ${options}
      </select>
      <input type="number" class="split-inputs uec" data-action="input->traderun#onUecChange" />
      <input type="number" class="split-inputs scu" data-action="input->traderun#validateScu"/>
      <span class="remove-commodity" data-action="click->traderun#removeCommodity" data-id="${id}">X</span>
    </div>
    `;
  }

  updateUec(event) {
    const commodityName = event.target.value;
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    const selectedCommodity = commoditiesData.find(commodity => commodity.name === commodityName && commodity.sell > 0);

    const parentDiv = event.target.parentElement;
    const uecDiv = parentDiv.querySelector('.uec');

    // Check if createSplit is toggled
    const parentTr = event.target.closest('tr');
    const splitInput = parentTr.querySelector('.split_input');
    const isSplit = splitInput.value === 'true';

    const sellPriceElement = parentTr.querySelector('#sellPrice');
    
    if (selectedCommodity) {
        uecDiv.value = selectedCommodity.sell;

        if (isSplit) {
            // Create a new hidden input for the commodity id
            const hiddenInput = document.createElement('input');
            hiddenInput.type = 'hidden';
            hiddenInput.id = "trade_run[commodity-" + selectedCommodity.id + "-sell]";
            hiddenInput.name = hiddenInput.id;
            
            hiddenInput.value = selectedCommodity.sell;            
            
            event.target.parentElement.setAttribute("id", `commodity-${selectedCommodity.id}`);
            event.target.parentElement.setAttribute("data-commodity", selectedCommodity.name);
            parentTr.appendChild(hiddenInput);

            // Clear existing sell price content
            sellPriceElement.innerHTML = '';

            // Create new input for commodity sell price
            const newInput = document.createElement('input');
            newInput.type = 'number';
            newInput.className = 'split-inputs uec';
            newInput.value = selectedCommodity.sell;
            sellPriceElement.appendChild(newInput);
        } else {
            // If not split, just show the sell price as text
            sellPriceElement.textContent = selectedCommodity.sell;
        }

        this.populateSellLocationSelect(event.target); 
    }
}



update(event) {
  const url = this.data.get('url');
  const id = event.target.dataset.id;
  const name = event.target.name;
  const value = event.target.value;
  const data = { "trade_run": {} };
  data["trade_run"][name] = value;
  
  fetch(url, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-CSRF-Token': document.querySelector('[name=csrf-token]').content
    },
    body: JSON.stringify(data)
  }).then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }
    return response.json(); // this line parses the JSON response into a JavaScript object
  }).then(data => {
    console.log("Fetched data: ", data); // log the data
    if (data && data.status === 'ok') {
      const profitElement = document.getElementById(`trade_run_profit_${id}`);
      if (profitElement) {
        profitElement.textContent = data.profit; // profit should be returned by server
      }
    }
  }).catch(error => {
    console.error('There has been a problem with your fetch operation:', error);
  });
}



removeEntry(event) {
  this.entryTarget.remove();
}

  validateScu(event) {
    // Ensure the input is a number
    
    const input = event.target.value;
   
    if (isNaN(input) || input < 0) {
      event.target.innerText = '';
      return;
    }
  
    // Calculate the total SCU used by other elements
    
    const parentTr = event.target.closest('tr');    
    const scuElements = parentTr.querySelectorAll('.scu');
    let totalScuUsed = 0;
    
    scuElements.forEach(scuElement => {
      if (scuElement !== event.target && scuElement.value !== '') {        
        totalScuUsed += parseInt(scuElement.value);
      }
    });
  
    // Get the maximum SCU from #buySCU
    const maxScu = parseInt(document.getElementById('buySCU').innerText);
    console.log('maxScu', maxScu);
    console.log('totalScuUsed', totalScuUsed);
    console.log('parseint', parseInt(input));
    // Check if the input exceeds the available SCU
    if (parseInt(input) > maxScu || totalScuUsed + parseInt(input) > maxScu) {
      event.preventDefault(); // Try to prevent the input event
      event.target.value = '';
    }
    this.calculator(event.target);
  }

  removeCommodity(event) {
    event.preventDefault();
  
    // Get commodityId from the element to be removed
    const commodityIdElement = event.target.parentElement.id;
    const commodityId = commodityIdElement.match(/\d+/g).map(Number);

    const parentTr = event.target.closest('tr');
  
    // Remove the commodity div and its related hidden input fields
    const commodityDiv = parentTr.querySelector(`#commodity-${commodityId}`);
    const hiddenInputField = parentTr.querySelector(`input[name="trade_run[commodity-${commodityId}-sell]"]`);
    //const hiddenInputField = parentTr.querySelector(`input[name="commodity-${commodityId}"]`);
  
    if (commodityDiv) {
      commodityDiv.remove();
    }
    
    if (hiddenInputField) {
      hiddenInputField.remove();
    }
  
    // Pass the parent 'tr' to the populateSellLocationSelect function
    this.populateSellLocationSelect(parentTr);
  }

  

/*

  addCommodity(event) {
    event.preventDefault();

    const id = new Date().getTime();
    const wrapper = document.createElement('div');
    wrapper.innerHTML = this.selectField(id).trim();

    this.element.querySelector('.split-container').appendChild(wrapper.firstChild);
  }

  selectField(id) {
    const commodities = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    const selectedCommodities = Array.from(this.element.querySelectorAll('.split-container select')).map(select => select.value);
    const availableCommodities = commodities.filter(commodity => !selectedCommodities.includes(commodity));

    let options = availableCommodities.map(commodity => 
      `<option value="${commodity}">${commodity}</option>`
    ).join('');

    return `
      <select name="trade_run[buy_commodities][]">
        ${options}
      </select>
    `;
  }


*/



}