import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    this.initializeChart()
    this.tradeSessionId = this.element.dataset.tradeSessionId;

    fetch(`/milkrun_profits?trade_session_id=${this.tradeSessionId}`)
      .then(response => response.json())
      .then(data => {
        this.updateChart(data)
      })
      
    this.subscribeToChannel()
  }

  updateChart(data) {
    // Update the labels and data of the chart
    this.chart.data.labels = Object.keys(data);
    this.chart.data.datasets[0].data = Object.values(data);
    
    // Redraw the chart
    this.chart.update();
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
        plugins: {
          legend: {
            display: false,
          }
      },
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
    this.chart.data.labels = Object.keys(data);
    this.chart.data.datasets[0].data = Object.values(data);
  
    // Redraw the chart
    this.chart.update();
  }

  subscribeToChannel() {
    this.milkRunSubscription = createConsumer().subscriptions.create({ channel: "MilkRunProfitsChannel", trade_session_id: this.tradeSessionId }, {
        received: this.received.bind(this)
      });
  }


  connectToActionCable() {
    App.cable.subscriptions.create({ channel: "MilkRunProfitsChannel" }, {
      received: (data) => {
        // update your chart with new data
      }
    });
  }

  disconnect() {
    if (this.milkRunSubscription) {
        createConsumer().subscriptions.remove(this.milkRunSubscription)
      }
  }

}
