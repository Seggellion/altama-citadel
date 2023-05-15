import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static targets = [ "rowHeader", "tbody", "menu","buyLocation", "buyCommodity", "commoditiesData", "sellLocation",
   "menuItem", "newTradeSession", "mainMenu","sessionMenu","streamchartMenu","existingTradeSession" ]
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
    if (event.key === "ArrowUp") {
      this.activeIndex = Math.max(0, this.activeIndex - 1);
    } else if (event.key === "ArrowDown") {
      this.activeIndex = Math.min(this.menuItemTargets.length - 1, this.activeIndex + 1);
    } else if (event.key === "Escape") {
      if (document.querySelector("#traderun_footer")) {        
        // Trigger the Rails action associated with the traderun_command_path("back")
        window.location.href = "/traderun_command.back";
        // Replace "/traderun_command/back" with the actual path generated by traderun_command_path("back") if it's different
      }
    }else if (event.key === "Enter") {
      if (this.menuItemTargets[this.activeIndex].dataset.action === "startNewTradeRun") {
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
      }else if (this.menuItemTargets[this.activeIndex].dataset.action === "existingTradeSession") {
        this.mainMenuTargets.forEach(menu => menu.classList.add("hidden"));
        document.querySelector('#greeting').classList.add('hidden');              
        this.existingTradeSessionTarget.classList.remove("hidden");
        this.fillBackground();
      }else if (this.menuItemTargets[this.activeIndex].dataset.action === "sessionStreamCharts") {
        
        this.streamchartMenuTarget.classList.remove("hidden");
        this.sessionMenuTarget.classList.add("hidden");

        
      }else{
        const activeMenuItem = this.menuItemTargets[this.activeIndex];
        const activeLink = activeMenuItem.querySelector('a');
    
        if (activeLink) {
          window.location.href = activeLink.href;
        }
      }
    }
    this.setActiveItem();
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
  
      // Get all selected commodities for this row
      const selectedCommoditiesInputs = parentTr.querySelectorAll('select[name="trade_run[buy_commodities][]"]');
  
      selectedCommoditiesInputs.forEach((input, index) => {
        const commodityName = input.value;
        const commodityData = selectedCommodities.find(commodity => commodity.name === commodityName);
  
        if (commodityData) {
          // Create new inputs for commodity buy and sell price
          const newSellInput = document.createElement('input');
          newSellInput.type = 'number';
          newSellInput.className = 'split-inputs uec';
          newSellInput.value = commodityData.buy;
          sellPriceElement.appendChild(newSellInput);
        }
      });
    } else {
      const selectedCommodity = selectedCommodities[0];
      if (selectedCommodity) {
        buyPriceElement.value = selectedCommodity.sell;
        sellPriceElement.value = selectedCommodity.buy;
      }
    }
      // Find an element that contains the row you want to calculate for
  const elementWithinRow = parentTr;

  // Call the calculator function
  this.calculator(elementWithinRow);

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
    this.calculator(event);

  }

  calculator(elementWithinRow) {
    const parentTr = elementWithinRow.closest('tr');
    const splitInput = parentTr.querySelector('.split_input');
    const isSplit = splitInput.value === 'true';

    const buySCUElement = isSplit ? this.calculateTotalSCU(parentTr) : parseFloat(document.getElementById("buySCU").innerHTML);
    const buyCommodity = this.getCommodity(this.buyLocationTarget.value, this.buyCommodityTarget.value);
    const sellCommodity = this.getCommodity(this.sellLocationTarget.value, this.buyCommodityTarget.value);

    this.clearExistingContent();

    if (isSplit) {
      this.calculateSplitCommodities(parentTr);
    } else {
      this.calculateRegularCommodities();
    }

    const marketBuy = buyCommodity ? buyCommodity.sell : 0;
    const marketSell = sellCommodity ? sellCommodity.buy : 0;
    this.setDeltaAttributes(marketSell, marketBuy);

    this.updatePriceElements(event.target.id, buyCommodity, sellCommodity, isSplit, marketSell);
}

 calculateTotalSCU(parentTr) {
    const scuElements = parentTr.querySelectorAll('.scu');
    return Array.from(scuElements).reduce((total, scuElement) => total + parseInt(scuElement.value || 0), 0);
}

 getCommodity(location, commodityName) {
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    return commoditiesData.find(commodity => commodity.name === commodityName && commodity.location === location);
}

 clearExistingContent() {
    document.getElementById("capital").innerHTML = '';
    document.getElementById("income").innerHTML = '';
    document.getElementById("profit").innerHTML = '';
}

 calculateSplitCommodities(parentTr) {
    const scuElements = parentTr.querySelectorAll('.scu');
    const uecElements = parentTr.querySelectorAll('.split-inputs.uec');
    const sellUecElements = parentTr.querySelectorAll('#sellPrice .split-inputs.uec');

    Array.from(scuElements).forEach((scuElement, i) => {
        const scuValue = parseFloat(scuElement.value || 0);
        const uecValue = parseFloat(uecElements[i].value || 0);
        const sellUecValue = parseFloat(sellUecElements[i].value || 0);

        const individualCapital = scuValue * uecValue;
        const individualIncome = scuValue * sellUecValue;
        const individualProfit = individualIncome - individualCapital;

        this.appendContentToElements(individualCapital, individualIncome, individualProfit);
    });
}

 calculateRegularCommodities() {
    const buyingPrice = parseFloat(document.getElementById("buyPrice").value) * 100.00;
    const sellingPrice = parseFloat(document.getElementById("sellPrice").value) * 100;
    const buySCUElement = parseFloat(document.getElementById("buySCU").value);

    const capitalCalculation = buyingPrice * buySCUElement;
    const incomeCalculation = sellingPrice * buySCUElement;
    const profitCalculation = incomeCalculation - capitalCalculation;

    this.appendContentToElements(capitalCalculation, incomeCalculation, profitCalculation);
}

 appendContentToElements(capital, income, profit) {
  this.appendContentToElement('capital', capital);
  this.appendContentToElement('income', income);
  this.appendContentToElement('profit', profit);
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
    const location = this.buyLocationTarget.value
    
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities)
    const commodities = commoditiesData.filter(commodity => commodity.location === location  && commodity.sell > 0)

    this.buyCommodityTarget.innerHTML = ""
    commodities.forEach(commodity => {
      const option = document.createElement("option")
      option.value = commodity.name
      option.text = commodity.name
      this.buyCommodityTarget.add(option)
    })
  }

  populateSellLocationSelect(elementWithinRow) {
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    
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
  
    // Filter out commoditiesData to include only those that have the selected names and a buy amount greater than 0
    const possibleLocations = commoditiesData.filter(commodity => selectedCommodityNames.includes(commodity.name) && commodity.buy > 0);
  
    // Generate a list of locations for each selected commodity
    const locationsForEachCommodity = selectedCommodityNames.map(name => {
      return possibleLocations.filter(location => location.name === name).map(location => location.location);
    });
    
    // Find the intersection of all these lists
    const sellLocations = locationsForEachCommodity.reduce((a, b) => a.filter(c => b.includes(c)));
  
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
      const option = document.createElement("option")
      option.value = location;
      option.text = location;
      sellLocationSelect.add(option);
    });
  }


  addCommodity(event) {
    event.preventDefault();

    const location = this.buyLocationTarget.value
    const commoditiesData = JSON.parse(this.commoditiesDataTarget.dataset.commodities);
    const buyCommodities = commoditiesData.filter(commodity => commodity.location === location  && commodity.sell > 0);
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

    const id = event.target.dataset.id;
    const commodityDiv = this.element.querySelector(`#commodity-${id}`);

    // Get the parent 'tr' of the select field
    const parentTr = event.target.closest('tr');

    if (commodityDiv) {
      commodityDiv.remove();
      // Pass the parent 'tr' to the populateSellLocationSelect function
      this.populateSellLocationSelect(parentTr);
    }
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