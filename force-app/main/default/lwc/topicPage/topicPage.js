import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { Topics } from 'c/guideData';

export default class TopicPage extends NavigationMixin(LightningElement) {
  @api filter = '';
  @api topicId = '';
  @track topic = null;

  connectedCallback() {
    this.findTopic();
  }

  renderedCallback() {
    this.findTopic();
  }

  findTopic() {
    if (this.topicId) {
      this.topic = Topics.find(t => t.id === this.topicId) || null;
    }
  }

  get filteredSubflows() {
    if (!this.topic || !this.filter) {
      return this.topic ? this.topic.subflows : [];
    }
    
    const filterLower = this.filter.toLowerCase();
    return this.topic.subflows.filter(subflow => 
      subflow.title.toLowerCase().includes(filterLower) ||
      subflow.description.toLowerCase().includes(filterLower) ||
      subflow.actions.some(action =>
        action.title.toLowerCase().includes(filterLower) ||
        action.description.toLowerCase().includes(filterLower)
      )
    );
  }

  handleBack() {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: ''
      }
    });
  }
}


