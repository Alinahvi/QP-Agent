import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getOUData from '@salesforce/apex/AgentGuideController.getOUData';

const Topics = [
  { 
    id: 'onboarding', 
    title: 'Onboarding', 
    blurb: 'Get new team members ramped fast.',
    icon: 'utility:user',
    subflows: [
      { 
        id: 'rampHealth', 
        title: 'Ramp Health',
        description: 'Analyze AE performance and identify areas for improvement',
        actions: [
          { 
            id: 'slowNoByOU', 
            title: 'Identify slow / no rampers', 
            description: 'List slow and no-ramp AEs in your OU.', 
            utterance: "Identify slow and no-ramp AEs in {OU} (CURRENT, group by AE, filter ramp_status in ('Slow','No Ramp')).", 
            tags: ['ramp','AE'] 
          },
          { 
            id: 'fastAmer', 
            title: 'Fast rampers in AMER by country', 
            description: 'Compare across AMER countries.', 
            utterance: "Analyze fast rampers in AMER (CURRENT, group by COUNTRY, ramp_status='Fast').", 
            tags: ['ramp','country'] 
          },
          { 
            id: 'rampByCountry', 
            title: 'Ramp analysis by country', 
            description: 'Compare ramp performance across countries in your OU.', 
            utterance: "Analyze ramp status by country in {OU} for {COUNTRY} (CURRENT, group by country, filter OU_NAME = '{OU}' and WORK_LOCATION_COUNTRY = '{COUNTRY}').", 
            tags: ['ramp','country','analysis'] 
          }
        ]
      },
      { 
        id: 'starterPlan', 
        title: 'Starter Plan',
        description: 'Create personalized enablement plans for struggling AEs',
        actions: [
          { 
            id: 'personalPlan', 
            title: 'Personalized plan per AE', 
            description: '30-day enablement plan for slow/no rampers.', 
            utterance: 'For slow/no-ramp AEs in {OU}, generate a personalized 30-day enablement plan with goals and checkpoints.', 
            tags: ['plan'] 
          }
        ]
      }
    ]
  },
  { 
    id: 'territory', 
    title: 'Territory Analysis', 
    blurb: 'Spot risks and opportunities by territory.',
    icon: 'utility:location',
    subflows: [
      { 
        id: 'risks', 
        title: 'Risks', 
        actions: [
          { 
            id: 'territoryRisk', 
            title: 'Territory risk analysis', 
            description: 'Risk by territory, OU, and AE.', 
            utterance: 'Territory Analysis: analyze risk by territory in {OU} (CURRENT, group by territory, OU, AE).', 
            tags: ['risk'] 
          }
        ]
      },
      { 
        id: 'opportunities', 
        title: 'Opportunities', 
        actions: [
          { 
            id: 'territoryOpp', 
            title: 'Territory opportunity analysis', 
            description: 'Opportunities by territory, OU, and AE.', 
            utterance: 'Territory Analysis: analyze opportunities by territory in {OU} (CURRENT, group by territory, OU, AE).', 
            tags: ['opportunity'] 
          }
        ]
      }
    ]
  },
  { 
    id: 'kpi', 
    title: 'KPI Analysis', 
    blurb: 'Compare performance by ramp, OU, and region.',
    icon: 'utility:chart',
    subflows: [
      { 
        id: 'ramp', 
        title: 'Ramp Status', 
        actions: [
          { 
            id: 'latamCalls', 
            title: 'Calls per AE (Slow, LATAM)', 
            description: 'Ramp lens on calls.', 
            utterance: 'KPI Analysis: calls per AE for slow rampers in LATAM (CURRENT, group by AE, filter ramp_status = "Slow" and region = "LATAM").', 
            tags: ['calls'] 
          },
          { 
            id: 'amerCalls', 
            title: 'Calls per AE (Slow, AMER)', 
            description: 'Ramp lens on calls.', 
            utterance: 'KPI Analysis: calls per AE for slow rampers in AMER (CURRENT, group by AE, filter ramp_status = "Slow" and region = "AMER").', 
            tags: ['calls'] 
          },
          { 
            id: 'emeaCalls', 
            title: 'Calls per AE (Slow, EMEA)', 
            description: 'Ramp lens on calls.', 
            utterance: 'KPI Analysis: calls per AE for slow rampers in EMEA (CURRENT, group by AE, filter ramp_status = "Slow" and region = "EMEA").', 
            tags: ['calls'] 
          },
          { 
            id: 'latamMeetings', 
            title: 'Meetings per AE (Slow, LATAM)', 
            description: 'Ramp lens on meetings.', 
            utterance: 'KPI Analysis: meetings per AE for slow rampers in LATAM (CURRENT, group by AE, filter ramp_status = "Slow" and region = "LATAM").', 
            tags: ['meetings'] 
          },
          { 
            id: 'amerMeetings', 
            title: 'Meetings per AE (Slow, AMER)', 
            description: 'Ramp lens on meetings.', 
            utterance: 'KPI Analysis: meetings per AE for slow rampers in AMER (CURRENT, group by AE, filter ramp_status = "Slow" and region = "AMER").', 
            tags: ['meetings'] 
          },
          { 
            id: 'emeaMeetings', 
            title: 'Meetings per AE (Slow, EMEA)', 
            description: 'Ramp lens on meetings.', 
            utterance: 'KPI Analysis: meetings per AE for slow rampers in EMEA (CURRENT, group by AE, filter ramp_status = "Slow" and region = "EMEA").', 
            tags: ['meetings'] 
          }
        ]
      },
      { 
        id: 'performance', 
        title: 'Performance', 
        actions: [
          { 
            id: 'latamPerformance', 
            title: 'Performance by AE (LATAM)', 
            description: 'Performance lens on LATAM.', 
            utterance: 'KPI Analysis: performance by AE in LATAM (CURRENT, group by AE, filter region = "LATAM").', 
            tags: ['performance'] 
          },
          { 
            id: 'amerPerformance', 
            title: 'Performance by AE (AMER)', 
            description: 'Performance lens on AMER.', 
            utterance: 'KPI Analysis: performance by AE in AMER (CURRENT, group by AE, filter region = "AMER").', 
            tags: ['performance'] 
          },
          { 
            id: 'emeaPerformance', 
            title: 'Performance by AE (EMEA)', 
            description: 'Performance lens on EMEA.', 
            utterance: 'KPI Analysis: performance by AE in EMEA (CURRENT, group by AE, filter region = "EMEA").', 
            tags: ['performance'] 
          }
        ]
      }
    ]
  },
  { 
    id: 'content', 
    title: 'Content for Enablement', 
    blurb: 'Find courses, assets, and curricula.',
    icon: 'utility:knowledge_base',
    subflows: [
      { 
        id: 'courses', 
        title: 'Courses', 
        actions: [
          { 
            id: 'courseSearch', 
            title: 'Search courses', 
            description: 'Find courses by topic.', 
            utterance: 'Content for Enablement: search courses by topic.', 
            tags: ['courses'] 
          }
        ]
      },
      { 
        id: 'assets', 
        title: 'Assets', 
        actions: [
          { 
            id: 'assetSearch', 
            title: 'Search assets', 
            description: 'Find assets by topic.', 
            utterance: 'Content for Enablement: search assets by topic.', 
            tags: ['assets'] 
          }
        ]
      },
      { 
        id: 'curricula', 
        title: 'Curricula', 
        actions: [
          { 
            id: 'curriculaSearch', 
            title: 'Search curricula', 
            description: 'Find curricula by topic.', 
            utterance: 'Content for Enablement: search curricula by topic.', 
            tags: ['curricula'] 
          }
        ]
      }
    ]
  },
  { 
    id: 'sme', 
    title: 'Subject Matter Experts', 
    blurb: 'Find the right experts fast.',
    icon: 'utility:user',
    subflows: [
      { 
        id: 'experts', 
        title: 'Experts', 
        actions: [
          { 
            id: 'expertSearch', 
            title: 'Search experts', 
            description: 'Find experts by topic.', 
            utterance: 'Subject Matter Experts: search experts by topic.', 
            tags: ['experts'] 
          }
        ]
      }
    ]
  },
  { 
    id: 'initiatives', 
    title: 'Priority Initiatives', 
    blurb: 'Define the goal and package outputs.',
    icon: 'utility:priority',
    subflows: [
      { 
        id: 'goals', 
        title: 'Goals', 
        actions: [
          { 
            id: 'goalDefinition', 
            title: 'Define goal', 
            description: 'Define the goal for the initiative.', 
            utterance: 'Priority Initiatives: define the goal for the initiative.', 
            tags: ['goals'] 
          }
        ]
      },
      { 
        id: 'outputs', 
        title: 'Outputs', 
        actions: [
          { 
            id: 'outputPackaging', 
            title: 'Package outputs', 
            description: 'Package the outputs for the initiative.', 
            utterance: 'Priority Initiatives: package the outputs for the initiative.', 
            tags: ['outputs'] 
          }
        ]
      },
      { 
        id: 'delivery', 
        title: 'Delivery', 
        actions: [
          { 
            id: 'emailDelivery', 
            title: 'Send via email service', 
            description: 'Deliver to selected AEs.', 
            utterance: 'Send the initiative packet via the agent email service to the selected AEs.', 
            tags: ['email'] 
          }
        ]
      }
    ]
  }
];

export default class QPTopicGuide extends NavigationMixin(LightningElement) {
  @track topics = Topics;
  @track showHome = true;
  @track currentTopic = null;
  @track lastUtterance = '';
  
  // Filter properties
  @track selectedOU = '';
  @track selectedCountry = '';
  @track ouOptions = [];
  @track countryOptions = [];
  @track ouData = [];

  get isCountryDisabled() {
    return !this.selectedOU;
  }

  @wire(getOUData)
  wiredOUData({ error, data }) {
    if (data) {
      console.log('OU Data loaded from Salesforce:', data);
      this.ouData = data;
      this.loadOUOptions();
    } else if (error) {
      console.error('Error loading OU data:', error);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Error',
        message: 'Failed to load OU data: ' + error.body.message,
        variant: 'error'
      }));
    }
  }

  connectedCallback() {
    console.log('QPTopicGuide component loaded with filter functionality');
    
    // Listen for utterance events
    this._handler = (event) => {
      this.lastUtterance = event.detail?.utterance || '';
    };
    window.addEventListener('agent:utterance', this._handler);
    
    // Check for topic parameter in URL
    this.checkUrlParams();
    
    // Initialize subflow states
    this.initializeSubflowStates();
  }
  
  checkUrlParams() {
    const urlParams = new URLSearchParams(window.location.search);
    const topic = urlParams.get('topic');
    console.log('Checking URL params, topic:', topic);
    
    if (topic) {
      const foundTopic = this.topics.find(t => t.id === topic);
      if (foundTopic) {
        this.currentTopic = foundTopic;
        this.showHome = false;
        console.log('Found topic, showing detail view:', foundTopic.title);
      }
    }
  }

  disconnectedCallback() {
    if (this._handler) {
      window.removeEventListener('agent:utterance', this._handler);
    }
  }

  handleTopicClick(event) {
    const topicId = event.currentTarget.dataset.topicId;
    console.log('Topic clicked:', topicId);
    
    const topic = this.topics.find(t => t.id === topicId);
    if (topic) {
      this.currentTopic = topic;
      this.showHome = false;
      this.updateUrl(topicId);
    }
  }

  updateUrl(topicId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: `/lightning/n/Agent_Guide?topic=${topicId}`
      },
      replace: true
    });
  }

  handleBackClick() {
    this.showHome = true;
    this.currentTopic = null;
    this.updateUrl('');
  }

  initializeSubflowStates() {
    // Initialize all subflows as collapsed
    setTimeout(() => {
      const subflowContents = this.template.querySelectorAll('.subflow-content');
      subflowContents.forEach(content => {
        content.classList.add('subflow-collapsed');
        content.classList.remove('subflow-expanded');
      });
    }, 100);
  }

  toggleSubflow(event) {
    const subflowId = event.currentTarget.dataset.subflowId;
    const content = this.template.querySelector(`[data-subflow-content="${subflowId}"]`);
    const icon = event.currentTarget.querySelector('.subflow-icon lightning-icon');
    
    if (content.classList.contains('subflow-expanded')) {
      // Collapse
      content.classList.remove('subflow-expanded');
      content.classList.add('subflow-collapsed');
      icon.iconName = 'utility:chevronright';
    } else {
      // Expand
      content.classList.remove('subflow-collapsed');
      content.classList.add('subflow-expanded');
      icon.iconName = 'utility:chevrondown';
    }
  }

  handleUseClick(event) {
    let utterance = event.target.dataset.utterance;
    
    // Replace placeholders with actual selected values
    if (utterance) {
      // Replace {OU} with selected OU
      if (this.selectedOU) {
        utterance = utterance.replace(/{OU}/g, this.selectedOU);
      } else {
        utterance = utterance.replace(/{OU}/g, '{OU}'); // Keep placeholder if no OU selected
      }
      
      // Replace {COUNTRY} with selected Country
      if (this.selectedCountry) {
        utterance = utterance.replace(/{COUNTRY}/g, this.selectedCountry);
      } else {
        utterance = utterance.replace(/{COUNTRY}/g, '{COUNTRY}'); // Keep placeholder if no country selected
      }
      
      // Replace {PRODUCT} with selected Product (if we add this later)
      utterance = utterance.replace(/{PRODUCT}/g, '{PRODUCT}');
    }
    
    // Dispatch utterance event
    window.dispatchEvent(new CustomEvent('agent:utterance', {
      detail: { utterance }
    }));
    
    this.dispatchEvent(new ShowToastEvent({
      title: 'Utterance queued',
      message: 'Previewed in Agent Dock with selected OU and Country values',
      variant: 'success'
    }));
  }

  async handleCopyClick(event) {
    let utterance = event.target.dataset.utterance;
    
    // Replace placeholders with actual selected values
    if (utterance) {
      // Replace {OU} with selected OU
      if (this.selectedOU) {
        utterance = utterance.replace(/{OU}/g, this.selectedOU);
      } else {
        utterance = utterance.replace(/{OU}/g, '{OU}'); // Keep placeholder if no OU selected
      }
      
      // Replace {COUNTRY} with selected Country
      if (this.selectedCountry) {
        utterance = utterance.replace(/{COUNTRY}/g, this.selectedCountry);
      } else {
        utterance = utterance.replace(/{COUNTRY}/g, '{COUNTRY}'); // Keep placeholder if no country selected
      }
      
      // Replace {PRODUCT} with selected Product (if we add this later)
      utterance = utterance.replace(/{PRODUCT}/g, '{PRODUCT}');
    }
    
    try {
      await navigator.clipboard.writeText(utterance);
      this.dispatchEvent(new ShowToastEvent({
        title: 'Copied to clipboard',
        message: 'Utterance copied with selected OU and Country values',
        variant: 'success'
      }));
    } catch (err) {
      this.dispatchEvent(new ShowToastEvent({
        title: 'Copy failed',
        message: 'Failed to copy utterance to clipboard',
        variant: 'error'
      }));
    }
  }

  // Filter methods
  loadOUOptions() {
    if (this.ouData && this.ouData.length > 0) {
      this.ouOptions = this.ouData.map(ou => ({
        label: ou.ouName,
        value: ou.ouName
      }));
      console.log('Loaded OU options from Salesforce:', this.ouOptions);
    }
  }

  handleOUChange(event) {
    this.selectedOU = event.detail.value;
    this.selectedCountry = ''; // Reset country when OU changes
    this.loadCountryData();
    console.log('OU selected:', this.selectedOU);
  }

  loadCountryData() {
    if (!this.selectedOU || !this.ouData || this.ouData.length === 0) {
      this.countryOptions = [];
      return;
    }
    
    // Find the selected OU data
    const selectedOUData = this.ouData.find(ou => ou.ouName === this.selectedOU);
    if (selectedOUData && selectedOUData.countries) {
      this.countryOptions = selectedOUData.countries.map(country => ({
        label: country,
        value: country
      }));
      console.log('Loaded country options for OU', this.selectedOU, ':', this.countryOptions);
    } else {
      this.countryOptions = [];
      console.log('No countries found for OU:', this.selectedOU);
    }
  }

  handleCountryChange(event) {
    this.selectedCountry = event.detail.value;
    console.log('Country selected:', this.selectedCountry);
  }

  // Add keyboard navigation support
  handleKeyDown(event) {
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault();
      if (event.target.classList.contains('topic-card')) {
        this.handleTopicClick(event);
      } else if (event.target.classList.contains('subflow-header')) {
        this.toggleSubflow(event);
      }
    }
  }
}