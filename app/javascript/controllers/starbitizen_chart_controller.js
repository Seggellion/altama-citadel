import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    this.initializeChart()
    this.tradeSessionId = this.element.dataset.tradeSessionId;

    fetch(`/star_bitizen_runs_data`)
      .then(response => response.json())
      .then(data => {
        this.updateChart(data)
      })
      
    this.subscribeToChannel()
  }

  updateChart(data) {
    // Update the labels and data of the chart
    this.chart.data.labels = Object.keys(data.profits);
    this.chart.data.datasets[0].data = Object.values(data.profits); // Profit data
    
    // Run data
    if (this.chart.data.datasets[1]) {
      this.chart.data.datasets[1].data = Object.values(data.runs);
    } else {
      this.chart.data.datasets.push({
        type: 'line',
        label: '# Runs',
        data: Object.values(data.runs),
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1
      });
    }
    
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
          borderWidth: 1,
          yAxisID: 'y',
        }, {
          type: 'line',
          label: '# Runs',
          data: [],
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)',
          borderWidth: 1,
          yAxisID: 'y1',
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
            beginAtZero: true,
            position: 'left',
            title: {
              display: true,
              text: 'Profit'
            },
          },
          y1: {
            beginAtZero: true,
            position: 'right',
            title: {
              display: true,
              text: '# Runs'
            },
            // this is an optional customization that makes the right scale gridlines invisible
            grid: {
              drawOnChartArea: false, 
            },
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
    
    // Run data
    if (this.chart.data.datasets[1]) {
      this.chart.data.datasets[1].data = Object.values(data.runs);
    } else {
      this.chart.data.datasets.push({
        type: 'line',
        label: '# Runs',
        data: Object.values(data.runs),
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1
      });
    }
    
    // Redraw the chart
    this.chart.update();
  }
  

  subscribeToChannel() {
    this.StarBitizenSubscription = createConsumer().subscriptions.create({ channel: "StarBitizenChannel", trade_session_id: this.tradeSessionId }, {
        received: this.received.bind(this)
      });
  }


  connectToActionCable() {
    App.cable.subscriptions.create({ channel: "StarBitizenChannel" }, {
      received: (data) => {
        // update your chart with new data
      }
    });
  }

  disconnect() {
    if (this.StarBitizenSubscription) {
        createConsumer().subscriptions.remove(this.StarBitizenSubscription)
      }
  }

}
