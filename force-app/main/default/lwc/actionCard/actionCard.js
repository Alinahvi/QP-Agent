import { LightningElement, api, track } from 'lwc';

export default class ActionCard extends LightningElement {
  @api action;
  @track showModal = false;

  handleLearnMore() {
    this.showModal = true;
  }

  handleCloseModal() {
    this.showModal = false;
  }
}


