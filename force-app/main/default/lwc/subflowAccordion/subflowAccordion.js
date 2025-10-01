import { LightningElement, api, track } from 'lwc';

export default class SubflowAccordion extends LightningElement {
  @api subflow;
  @api filter = '';
  @track isOpen = false;

  get filteredActions() {
    if (!this.subflow || !this.filter) {
      return this.subflow ? this.subflow.actions : [];
    }
    
    const filterLower = this.filter.toLowerCase();
    return this.subflow.actions.filter(action =>
      action.title.toLowerCase().includes(filterLower) ||
      action.description.toLowerCase().includes(filterLower)
    );
  }

  handleToggle() {
    this.isOpen = !this.isOpen;
    const accordionContent = this.template.querySelector('.slds-accordion__content');
    const accordionButton = this.template.querySelector('.slds-accordion__summary-action');
    const accordionIcon = this.template.querySelector('.accordion-icon');
    
    if (this.isOpen) {
      accordionContent.classList.remove('slds-is-collapsed');
      accordionButton.setAttribute('aria-expanded', 'true');
      accordionIcon.classList.add('slds-accordion__summary-action-icon');
      accordionIcon.classList.remove('slds-button__icon_left');
    } else {
      accordionContent.classList.add('slds-is-collapsed');
      accordionButton.setAttribute('aria-expanded', 'false');
      accordionIcon.classList.remove('slds-accordion__summary-action-icon');
      accordionIcon.classList.add('slds-button__icon_left');
    }
  }
}


