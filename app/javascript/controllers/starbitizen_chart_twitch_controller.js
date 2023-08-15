import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from 'chart.js';
Chart.register(...registerables);
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static targets = ["canvas"];

  connect() {
    this.twitch_id = this.element.dataset.twitch_id;
    this.fontColor = this.element.dataset.font_color;
    this.accentColor = this.element.dataset.accent_color;

    this.initializeChart()
    //this.tradeSessionId = this.element.dataset.tradeSessionId;

    
    fetch(`/star_bitizen_chart_twitch_data/${this.twitch_id}`)
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
  

  setFontColor(alpha) {
    return this.hexToRgba(this.fontColor, alpha);
  }
  setAccentColor(alpha) {
    return this.hexToRgba(this.accentColor, alpha);
  }

  hexToRgba(hex, alpha) {
    
    let r = parseInt(hex.slice(1, 3), 16),
        g = parseInt(hex.slice(3, 5), 16),
        b = parseInt(hex.slice(5, 7), 16);

    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
  }

  initializeChart() {
    this.chart = new Chart(this.canvasTarget, {
      type: 'bar',
      data: {
        labels: [],
        datasets: [{
          label: 'Profit',
          data: [],
          color: `${this.setFontColor(1)}`,
          backgroundColor: `${this.setAccentColor(0.2)}`,
          borderColor: `${this.setAccentColor(1)}`,
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
              text: 'Profit',
              color: `${this.setFontColor(1)}`
            },
            ticks: {
              color: `${this.setFontColor(1)}`
            },
            grid:{
              borderColor: `${this.setFontColor(0.4)}`, 
              color: `${this.setFontColor(0.4)}`
            }
          },
          y1: {
            beginAtZero: true,
            position: 'right',
            title: {
              display: true,
              text: '# Runs',
              color: `${this.setFontColor(1)}`
            },
            ticks: {
              color: `${this.setFontColor(1)}`
            },
            grid: {
              drawOnChartArea: false, 
              borderColor: `${this.setFontColor(0.4)}`, 
              color: `${this.setFontColor(0.4)}`
            },
          },
          x: {
            ticks: {
              color: `${this.setFontColor(1)}`,
              autoSkip: false,
              maxRotation: 90,
              minRotation: 90
            },
            grid:{
              borderColor: `${this.setFontColor(0.4)}`, 
              color: `${this.setFontColor(0.4)}`
            }
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
    
    this.StarBitizenSubscription = createConsumer().subscriptions.create({ channel: "StarBitizenTwitchChannel", twitch_id: this.twitch_id }, {
        received: this.received.bind(this)
      });
  }


  connectToActionCable() {
    App.cable.subscriptions.create({ channel: "StarBitizenTwitchChannel" }, {
      received: (data) => {
        // update your chart with new data
      }
    });
  }

  disconnect() {
    if (this.StarBitizenSubscription) {
        createConsumer().subscriptions.remove(this.StarBitizenTwitchSubscription)
      }
  }

}
