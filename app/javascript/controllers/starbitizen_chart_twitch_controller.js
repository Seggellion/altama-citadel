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

    this.initializeChart();
    this.initializeCommodityChart();
    //this.tradeSessionId = this.element.dataset.tradeSessionId;

    
    fetch(`/star_bitizen_chart_twitch_data/${this.twitch_id}`)
      .then(response => response.json())
      .then(data => {
        this.updateChart(data)
        this.updateCommodityChart(data)
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

  updateCommodityChart(data) {
    // Update the labels to use commodity names
    
    this.commodityChart.data.labels = data.commodities.map(commodity => commodity.name);
  
    // Update the datasets

    this.commodityChart.data.datasets[0].data = data.commodities.map(commodity => commodity.total_profit);
  
    // Run data
    if (this.commodityChart.data.datasets[1]) {
      this.commodityChart.data.datasets[1].data = data.commodities.map(commodity => commodity.runs_count);
    } else {
      this.commodityChart.data.datasets.push({
        type: 'line',
        label: '# Runs',
        data: data.commodities.map(commodity => commodity.runs_count),
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1
      });
    }
  
    // Update chart with new data
    this.commodityChart.update();
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
    this.chart = new Chart(document.getElementById('profitsChart'), {
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
  
  initializeCommodityChart() {
    this.commodityChart = new Chart(document.getElementById('commodityChart'), {
      type: 'bar',
      data: {
        labels: [], // Initial empty labels
        datasets: [{
          label: 'Profit',
          data: [], // Initial empty data array
          backgroundColor: 'rgba(54, 162, 235, 0.2)', // Customise as needed
          borderColor: 'rgba(54, 162, 235, 1)', // Customise as needed
          borderWidth: 1,
          yAxisID: 'y',
        }, {
          type: 'line',
          label: '# Runs',
          data: [], // Initial empty data array
          backgroundColor: 'rgba(75, 192, 192, 0.2)', // Customise as needed
          borderColor: 'rgba(75, 192, 192, 1)', // Customise as needed
          borderWidth: 1,
          yAxisID: 'y1',
        }]
      },
      options: {
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Profit'
            }
          },
          y1: {
            beginAtZero: true,
            position: 'right',
            title: {
              display: true,
              text: '# Runs'
            },
            grid: {
              drawOnChartArea: false
            },
          }
        }
      }
    });
  }
  
  
  

  received(data) {
    console.log('Received data:', data);
    
    // Update the labels and data of the first chart
    this.chart.data.labels = Object.keys(data.profits);
    this.chart.data.datasets[0].data = Object.values(data.profits);
    
    // Run data for the first chart
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
  
    // Assuming data.commodities is structured correctly for the commodityChart:
    // Update the labels to use commodity names
    this.commodityChart.data.labels = data.commodities.map(commodity => commodity.name);
  
    // Update the datasets for the commodity chart
    // Profit data for the commodity chart
    this.commodityChart.data.datasets[0].data = data.commodities.map(commodity => commodity.total_profit);
  
    // Run data for the commodity chart
    if (this.commodityChart.data.datasets[1]) {
      this.commodityChart.data.datasets[1].data = data.commodities.map(commodity => commodity.runs_count);
    } else {
      this.commodityChart.data.datasets.push({
        type: 'line',
        label: '# Runs',
        data: data.commodities.map(commodity => commodity.runs_count),
        backgroundColor: 'rgba(255, 99, 132, 0.2)',
        borderColor: 'rgba(255, 99, 132, 1)',
        borderWidth: 1
      });
    }
    
    // Redraw both charts
    this.commodityChart.update();
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
