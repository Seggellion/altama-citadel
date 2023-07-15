import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    this.initializeChart()
    this.subscribeToChannel()
  }

  initializeChart() {
    this.chart = new Chart(this.canvasTarget, {
      type: 'bar',
      data: {
        labels: [], 
        datasets: [{
          label: 'Profit',
          data: [], 
          backgroundColor: 'rgba(75, 192, 192, 0.2)', 
          borderColor: 'rgba(75, 192, 192, 1)',
          borderWidth: 1
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });
  }
  
  

  received(data) {
    console.log('Received data:', data);
  
    // Update the labels and data of the chart
    this.chart.data.labels = Object.keys(data.profits);
    this.chart.data.datasets[0].data = Object.values(data.profits);
  
    // Redraw the chart
    this.chart.update();
  }

  subscribeToChannel() {
    this.subscription = createConsumer().subscriptions.create({ channel: "UserProfitsChannel" }, {
      received: (data) => {
        // update your chart with new data
      }
    })
  }


  connectToActionCable() {
    App.cable.subscriptions.create({ channel: "UserProfitsChannel" }, {
      received: (data) => {
        // update your chart with new data
      }
    });
  }

  disconnect() {
    // Called when the controller's context is disconnected
    // For example, when navigating between pages or removing a controller's element from the DOM
    if (this.subscription) {
      createConsumer().subscriptions.remove(this.subscription)
    }
  }

}
