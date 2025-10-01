import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class AgentGuideApp extends LightningElement {
  @track filter = '';
  @track topicId = '';
  @track isHome = true;

  @wire(CurrentPageReference)
  pageRef;

  connectedCallback() {
    this.updateFromUrl();
  }

  renderedCallback() {
    this.updateFromUrl();
  }

  updateFromUrl() {
    if (this.pageRef && this.pageRef.state) {
      const topic = this.pageRef.state.topic;
      if (topic) {
        this.topicId = topic;
        this.isHome = false;
      } else {
        this.topicId = '';
        this.isHome = true;
      }
    }
  }

  handleFilter(event) {
    this.filter = event.target.value;
  }
}


