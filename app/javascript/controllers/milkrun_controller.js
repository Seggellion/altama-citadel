import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["commodity", "location", "buyScu", "buyPrice", "capital", "sellScu", "sellPrice", "profitPerScu", "commoditiesData", "commoditySelector", "formType", "milkRunData"]

  // static targets = ["commodity", "location", "profit", "scu", "sellPrice", "profitPerScu", "commoditiesData", "commoditySelector"]
//  static targets = ["ship", "location", "commodity", "buyScu", "buyPrice", "capital", "locationsData", "shipsData", "commoditiesData"]

  connect() {

    let commodities = document.getElementById('commodities-data').dataset.commodities;
    this.commodities = JSON.parse(commodities);
    this.locationsData = JSON.parse(document.getElementById('locations-data').dataset.locations);
    this.commoditiesData  = document.getElementById('commodities-data').dataset.commodities;
     
    this.milk_runsData = JSON.parse(document.getElementById('milkruns-data').dataset.milkRuns);

  }
  
  selectCommodity(event) {
    
    const selectedCommodity = this.commodities.find(c => c.id == event.target.value);
    
debugger;
    const form = event.target.closest('form');
    this.formType = form.querySelector('[data-milkrun-target="formType"]').value;
    this.updateLocations(selectedCommodity);
    
    
  }
  
  
  updateLocations(selectedCommodity) {
    let validLocations;
   debugger;
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
    this.sellPriceTarget.value = selectedCommodity ? selectedCommodity.sell : '';
    this.updateProfitPerScu(event);
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
        const profitPerScu = selectedCommodity.sell - buyCommodity.buy_commodity_price;
        debugger;
        this.profitPerScuTarget.textContent = profitPerScu.toFixed(2);
      } else {
        this.profitPerScuTarget.textContent = 'N/A';
      }
    } else {
      this.profitPerScuTarget.textContent = 'N/A';
    }
  }
  


  locationChanged(event) {
    const locationName = event.target.value
    console.log('locationName', locationName);
    const options = this.commodities
      .filter(commodity => commodity.location == locationName && commodity.sell > 0)
      .map(commodity => `<option value="${commodity.name}">${commodity.name}</option>`)

    this.commoditySelectorTarget.innerHTML = options.join("")
  }



  populateCommodityPrice(event) {
    
    const commodityId = event.target.value
    
    const locationData = document.getElementById("milk_run_buy_location").value;
    
    const commoditiesData = JSON.parse(document.getElementById('commodities-data').dataset.commodities);
    let filteredCommodities = commoditiesData.filter(commodity => commodity.name === commodityId && commodity.location === locationData);
  //  const commodity = this.commodities.find(commodity => commodity.id == commodityId)
    
    document.querySelector('#milk_run_buy_commodity_price').value = filteredCommodities[0].sell
    
    document.querySelector('#buy_commodity_id').value = filteredCommodities[0].id
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
  }
  
  
}
