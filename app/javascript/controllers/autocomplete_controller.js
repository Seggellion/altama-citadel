import { Controller } from "@hotwired/stimulus"
import { Autocomplete } from 'stimulus-autocomplete'

export default class extends Controller {
  static targets = ['input', 'hidden', 'results']

  connect() {
    

    new Autocomplete(this, {
        url: this.data.get('url'),
        getValue: (item) => item.username,
        onSelect: (item) => this.select(item),
      });



  }

  perform() {
    debugger;
    new Autocomplete(this, {
      url: this.data.get('url'),
      getValue: (item) => {
        console.log(item);
        return item.username;
      },
      onSelect: (item) => {
        console.log(item);
        this.select(item);
      },
    });
  }
  
  select(item) {    
    this.inputTarget.value = item.username;
    this.hiddenTarget.value = item.id;
  }
}
