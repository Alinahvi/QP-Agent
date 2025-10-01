import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { Topics } from 'c/guideData';

export default class TopicHome extends NavigationMixin(LightningElement) {
  @api filter = '';
  @track topics = Topics;

  get filteredTopics() {
    if (!this.filter) {
      return this.topics;
    }
    
    const filterLower = this.filter.toLowerCase();
    return this.topics.filter(topic => 
      topic.title.toLowerCase().includes(filterLower) ||
      topic.blurb.toLowerCase().includes(filterLower) ||
      topic.subflows.some(subflow => 
        subflow.title.toLowerCase().includes(filterLower) ||
        subflow.description.toLowerCase().includes(filterLower) ||
        subflow.actions.some(action =>
          action.title.toLowerCase().includes(filterLower) ||
          action.description.toLowerCase().includes(filterLower)
        )
      )
    );
  }

  handleOpenTopic(event) {
    const topicId = event.target.dataset.topicId;
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: `?topic=${topicId}`
      }
    });
  }
}


