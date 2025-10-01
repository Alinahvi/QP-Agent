explain th eproblem in details and also mention import { LightningElement, track } from 'lwc';

const Topics = [
    { 
        id: 'onboarding', 
        title: 'Onboarding', 
        blurb: 'Get new team members ramped fast.',
        icon: 'utility:user'
    },
    { 
        id: 'territory', 
        title: 'Territory Analysis', 
        blurb: 'Spot risks and opportunities by territory.',
        icon: 'utility:location'
    },
    { 
        id: 'kpi', 
        title: 'KPI Analysis', 
        blurb: 'Compare performance by ramp, OU, and region.',
        icon: 'utility:chart'
    },
    { 
        id: 'content', 
        title: 'Content for Enablement', 
        blurb: 'Find courses, assets, and curricula.',
        icon: 'utility:knowledge_base'
    },
    { 
        id: 'sme', 
        title: 'Subject Matter Experts', 
        blurb: 'Find the right experts fast.',
        icon: 'utility:user'
    },
    { 
        id: 'initiatives', 
        title: 'Priority Initiatives', 
        blurb: 'Define the goal and package outputs.',
        icon: 'utility:priority'
    }
];

export default class AgentGuideV2 extends LightningElement {
    showBuilder = false;
    selectedTopic = null;
    @track lastUtterance = '';
    @track messages = [];
    @track topics = Topics;

    handleTopicClick(event) {
        const topicId = event.currentTarget.dataset.topicId;
        const topic = this.topics.find(t => t.id === topicId);
        if (topic) {
            this.selectedTopic = topic;
            this.showBuilder = true;
            this.addMessage(`Selected topic: ${topic.title}`);
        }
    }

    handleBackClick() {
        this.showBuilder = false;
        this.selectedTopic = null;
        this.addMessage('Returned to topic selection');
    }

    addMessage(text) {
        const timestamp = new Date().toLocaleTimeString();
        this.messages = [{ id: `${Date.now()}-${Math.random()}`, text: `[${timestamp}] ${text}` }, ...this.messages];
    }
}
