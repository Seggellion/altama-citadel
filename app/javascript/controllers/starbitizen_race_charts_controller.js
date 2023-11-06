
import { createConsumer } from "@rails/actioncable"
import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);

export default class extends Controller {
  static targets = ["userRacesCanvas", "shipRacesCanvas"];

  connect() {
    
    this.initializeUserRacesChart();
    this.initializeShipRacesChart();
    
    // Fetch data when the component is connected
    this.fetchRaceData();
    
  }

  fetchRaceData() {
    // Implement the fetch call to your Rails API endpoint here
    // For example, using fetch
    fetch('/api/v1/star_bitizen_races')
      .then(response => response.json())
      .then(data => {
        this.updateUserRacesChart(data);
        this.updateShipRacesChart(data);
      })
      .catch(error => console.error("There was an error fetching the race data:", error));
  }

  initializeUserRacesChart() {
    // Initialize the user races chart here
    // Assume the canvas element has an ID of 'userRacesChart'
    this.userRacesChart = new Chart(this.userRacesCanvasTarget, {
      // ... chart configuration goes here
    });
  }

  initializeShipRacesChart() {
    // Initialize the ship races chart here
    // Assume the canvas element has an ID of 'shipRacesChart'
    this.shipRacesChart = new Chart(this.shipRacesCanvasTarget, {
      // ... chart configuration goes here
    });
  }

  updateUserRacesChart(data) {
    // Update the user races chart with new data
    // Assume that the data structure matches what the chart expects
    this.userRacesChart.data.labels = data.user_races.map(userRace => userRace.username);
    this.userRacesChart.data.datasets[0].data = data.user_races.map(userRace => userRace.race_count);
    this.userRacesChart.update();
  }

  updateShipRacesChart(data) {
    // Update the ship races chart with new data
    this.shipRacesChart.data.labels = data.ship_races.map(shipRace => shipRace.ship);
    this.shipRacesChart.data.datasets[0].data = data.ship_races.map(shipRace => shipRace.race_count);
    this.shipRacesChart.update();
  }

  // Add any other methods needed for interactivity or data processing
}
