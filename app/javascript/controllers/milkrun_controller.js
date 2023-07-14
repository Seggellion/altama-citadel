import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["commodity", "location", "buyScu", "buyPrice", "capital", "sellScu", "profit", "sellPrice", "profitPerScu", "commoditiesData", "commoditySelector", "formType",
   "milkRunData","commodityField", "locationField", "sellScuField", "sellPriceField", "profitPerScuField", "formTypeField", "SellIdField", "BuyIdField", "buyCommoditySelector",
  "BuyCommodityIdField", "BuyCommodityPriceField", "buyLocationField", "buyLocationSelector", "userIdSelector", "userIdField", "buyCommodityField","buyScuField",
"buyShipSelector","shipIdField","profitField"]

  // static targets = ["commodity", "location", "profit", "scu", "sellPrice", "profitPerScu", "commoditiesData", "commoditySelector"]
//  static targets = ["ship", "location", "commodity", "buyScu", "buyPrice", "capital", "locationsData", "shipsData", "commoditiesData"]

  connect() {

    let commodities = document.getElementById('commodities-data').dataset.commodities;
    
    this.commodities = JSON.parse(commodities);
    this.locationsData = JSON.parse(document.getElementById('locations-data').dataset.locations);
    this.commoditiesData  = document.getElementById('commodities-data').dataset.commodities;
    this.shipsData = JSON.parse(document.getElementById('ships-data').dataset.ships);
    this.milk_runsData = JSON.parse(document.getElementById('milkruns-data').dataset.milkRuns);

  }
  
  selectCommodity(event) {
    const selectedCommodityId = event.target.value;
    
    const selectedCommodity = this.commodities.find(c => c.id == selectedCommodityId);
    
    let trElement = event.target.closest('tr')
    if(trElement){
      this.formType =   trElement.dataset.form_type
    }
   
    this.updateMaxScu(event);
    this.updateLocations(selectedCommodity);
    
  }

  updateMaxScu(event){
    const selectedCommodityId = event.target.value;
    const selectedCommodity = this.commodities.find(c => c.id == selectedCommodityId);    
    
    const buyCommodityScu = this.milk_runsData.find(m => m.commodity_name == selectedCommodity.name).buy_commodity_scu
    
    this.sellScuTarget.max = buyCommodityScu;
    debugger;
    this.sellScuTarget.addEventListener('input', (e) => {
      if (e.target.value > buyCommodityScu) {
        e.target.value = buyCommodityScu;
      }
    });
  }
  
  
  updateLocations(selectedCommodity) {
    let validLocations;
   
   // FORM TYPE IS invalid!
    if (this.formType === 'buy') {
      validLocations = this.commodities
        .filter(c => c.name == selectedCommodity.name && c.sell > 0)
        .map(c => {
          const locationData = this.locationsData.find(l => l.name == c.location);
          return {
            name: `${locationData.parent} | ${c.location}`,
            id: c.id
          };
        });
    } else {  // assume 'sell' if not 'buy'
      
      validLocations = this.commodities
        .filter(c => c.name == selectedCommodity.name && c.buy > 0)
        .map(c => {
          const locationData = this.locationsData.find(l => l.name == c.location);
          return {
            name: `${locationData.parent} | ${c.location}`,
            id: c.id
          };
        });
    }
    
    this.updateSelectOptions(this.locationTarget, validLocations);    
  }
  
  
  updateSelectOptions(selectElement, optionsArray) {    
    selectElement.innerHTML = optionsArray.map(option => 
      `<option value='${JSON.stringify(option)}'>${option.name}</option>`).join('');
  }
  

  selectBuyLocation(event) {
    const selectedLocation = event.target.value;
    const commodityId = this.commodityTarget.value;

   ///  JUST TRYING TO SOLVE FOR PROFIT PER SCU
   
  // const selectedOptionValue = JSON.parse(event.target.value);
   
  // const commodityId = selectedOptionValue.id;   
 //  let locationParts = selectedOptionValue.name.split(" | ");
  // const locationName = locationParts.pop().trim();
    // find the selected commodity by name and location
    const selectedCommodity = this.commodities.find(c => c.name == commodityName && c.location == selectedLocation);
   const commodityName = this.commodities.find(c => c.id == commodityId).name
 //  const selectedCommodity = this.commodities.find(c => c.name == commodityName && c.location == locationName);
    // populate sell_commodity_price field with selected commodity's sell price
    this.buyPriceTarget.value = selectedCommodity ? selectedCommodity.buy : '';
    
    this.buyIdFieldTarget.value = selectedCommodity.id
  
    this.updateHiddenBuyFields();
  }

  selectLocation(event) {
    //const selectedLocation = event.target.value;
    //const commodityId = this.commodityTarget.value;

   ///  JUST TRYING TO SOLVE FOR PROFIT PER SCU
   
   const selectedOptionValue = JSON.parse(event.target.value);
   
   const commodityId = selectedOptionValue.id;   
   let locationParts = selectedOptionValue.name.split(" | ");
   const locationName = locationParts.pop().trim();
   
    // find the selected commodity by name and location
   // const selectedCommodity = this.commodities.find(c => c.name == commodityName && c.location == selectedLocation);
   const commodityName = this.commodities.find(c => c.id == commodityId).name
   const selectedCommodity = this.commodities.find(c => c.name == commodityName && c.location == locationName);
    // populate sell_commodity_price field with selected commodity's sell price
    this.sellPriceTarget.value = selectedCommodity ? selectedCommodity.buy : '';
    
    this.SellIdFieldTarget.value = selectedCommodity.id
    
    this.updateProfitPerScu(event);
    this.updateHiddenFields();
    
  }


  updateProfitPerScu(event) {
    //const selectedCommodityId = this.commodityTarget.value;
    const selectedOptionValue = JSON.parse(event.target.value);
    const selectedCommodityId = selectedOptionValue.id;
    
    // I don't believe this should be selecting a commodity and instead a location ^^
    const selectedCommodity = this.commodities.find(c => c.id == selectedCommodityId);
    
    if (selectedCommodity) {
      
      const buyCommodity = this.milk_runsData.find(m => m.commodity_name == selectedCommodity.name);
      
      if (buyCommodity) {
        const profitPerScu = selectedCommodity.buy - buyCommodity.buy_commodity_price;
        
        this.profitPerScuTarget.value = profitPerScu.toFixed(2);
      } else {
        this.profitPerScuTarget.textContent = 'N/A';
      }
    } else {
      this.profitPerScuTarget.textContent = 'N/A';
    }
    
    this.updateHiddenFields();
  }
  
  updateProfit(event){
    
    let sellScu = this.sellScuTarget.value;
    let sellPrice = this.sellPriceTarget.value;
    let buyCommodityId = this.commodityTarget.value;
    
    //const buyCommodityName = this.commodities.find(c => c.id == buyCommodityId).name;
    // You may want to add some error handling here in case the commodity name is not found
    
    let buyCommodityPrice = this.milk_runsData.find(m => m.buy_commodity_id == buyCommodityId).buy_commodity_price;
    
    let profitPerScu = sellPrice - buyCommodityPrice;
    let totalProfit = profitPerScu * sellScu;

    this.profitTarget.value = totalProfit;
    this.updateHiddenFields();
  }


  locationChanged(event) {
    const locationName = event.target.value
    console.log('locationName', locationName);
    
    const options = this.commodities
      .filter(commodity => commodity.location == locationName && commodity.sell > 0)
      .map(commodity => `<option value="${commodity.name}">${commodity.name}</option>`)

    this.buyCommoditySelectorTarget.innerHTML = options.join("")
    this.updateHiddenBuyFields();
  }

  shipChanged(event){

const selectedShipId = event.target.value;

const selectedShipScu = this.shipsData.find(c => c.id == selectedShipId).scu;
    this.buyScuTarget.max = selectedShipScu;
    this.buyScuTarget.addEventListener('input', (e) => {
      if (e.target.value > selectedShipScu) {
        e.target.value = selectedShipScu;
      }
    });

    this.updateHiddenBuyFields();
  }

  populateCommodityPrice(event) {
    
    const commodityId = event.target.value
    
    const locationData = this.buyLocationSelectorTarget.value;
    
    const commoditiesData = JSON.parse(document.getElementById('commodities-data').dataset.commodities);
    let filteredCommodities = commoditiesData.filter(commodity => commodity.name === commodityId && commodity.location === locationData);
  //  const commodity = this.commodities.find(commodity => commodity.id == commodityId)
    
    this.buyPriceTarget.value = filteredCommodities[0].sell
    
    this.BuyCommodityIdFieldTarget.value = filteredCommodities[0].id
    this.updateHiddenBuyFields();
  }
  handleSell(event) {
    event.preventDefault()
    
    const formData = new FormData(event.target)
    const profit = parseFloat(formData.get('profit'))
    const scu = parseFloat(formData.get('sell_commodity_scu'))
  
    const profitPerScu = profit / scu
    formData.set('profit_per_scu', profitPerScu)
    
    // Continue with the form submission...
  }

  populateLocations(event) {
    const commodityId = event.target.value
    const locations = this.commodities
      .filter(commodity => commodity.name == commodityId)
      .map(commodity => `<option value="${commodity.location_id}">${commodity.location_name}</option>`)
  
    this.locationSelectorTarget.innerHTML = locations.join("")
  }
  
  calculateCapital() {
    const buyPrice = parseFloat(this.buyPriceTarget.value) || 0;
    const buyScu = parseFloat(this.buyScuTarget.value) || 0;
  
    this.capitalTarget.textContent = (buyPrice * buyScu).toFixed(2);
    this.updateHiddenBuyFields();
  }
  
  updateHiddenBuyFields() {
    this.shipIdFieldTarget.value = this.buyShipSelectorTarget.value;
    
    this.buyCommodityFieldTarget.value = this.buyCommoditySelectorTarget.value;   
    
    if (this.hasUserIdFieldTarget) {
      this.userIdFieldTarget.value = this.userIdSelectorTarget.value;    
    }
    
    //this.BuyCommodityIdFieldTarget.value = this.commodityTarget.value;
    this.BuyCommodityPriceFieldTarget.value = this.buyPriceTarget.value;
    this.buyLocationFieldTarget.value = this.buyLocationSelectorTarget.value;
    this.buyScuFieldTarget.value = this.buyScuTarget.value;
    
  }

  updateHiddenFields() {
    
    this.commodityFieldTarget.value = this.commodityTarget.value;    
    this.BuyIdFieldTarget.value = this.commodityTarget.value;
    this.locationFieldTarget.value = this.locationTarget.value;
    this.sellScuFieldTarget.value = this.sellScuTarget.value;
    this.sellPriceFieldTarget.value = this.sellPriceTarget.value;
    
    this.profitFieldTarget.value = this.profitTarget.value;
    //this.profitPerScuFieldTarget.value = this.profitPerScuTarget.value;
    this.formTypeFieldTarget.value = this.formTypeTarget.value;
    
  }

  
}
