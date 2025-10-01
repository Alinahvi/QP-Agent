import { LightningElement, api } from 'lwc';

export default class ActionModal extends LightningElement {
  @api action;

  handleClose() {
    const closeEvent = new CustomEvent('close');
    this.dispatchEvent(closeEvent);
  }
}


