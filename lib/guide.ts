export type LeafAction = {
  id: string;
  title: string;
  description: string;
  utterance: string;        // what we'll send to the agent
  tags?: string[];
};

export type SubFlow = {
  id: string;
  title: string;
  description?: string;
  actions: LeafAction[];
};

export type Topic = {
  id: 'onboarding'|'territory'|'kpi'|'content'|'sme'|'priority';
  title: string;
  blurb: string;
  subflows: SubFlow[];
};

export const guideData: Topic[] = [
  {
    id: 'onboarding',
    title: 'Onboarding',
    blurb: 'Get new team members up to speed with personalized enablement plans and ramp analysis.',
    subflows: [
      {
        id: 'ramp-health',
        title: 'Ramp Health',
        description: 'Analyze AE performance and identify areas for improvement',
        actions: [
          {
            id: 'identify-slow-rampers',
            title: 'Identify slow/no rampers for my OU',
            description: 'Find AEs who need additional support to reach productivity',
            utterance: 'Identify slow and no-ramp AEs in {OU} (CURRENT, group by AE, filter ramp_status in (\'Slow\',\'No Ramp\')).',
            tags: ['Analysis', 'Ramp Status']
          },
          {
            id: 'fast-rampers-amer',
            title: 'Fast rampers in AMER by country',
            description: 'Analyze top performers in the Americas region',
            utterance: 'Analyze fast rampers in AMER (CURRENT, group by COUNTRY, ramp_status=\'Fast\').',
            tags: ['Analysis', 'Performance']
          }
        ]
      },
      {
        id: 'starter-plan',
        title: 'Starter Plan',
        description: 'Create personalized enablement plans for struggling AEs',
        actions: [
          {
            id: 'personalized-enablement',
            title: 'Personalized enablement plan per AE (slow/no rampers)',
            description: 'Generate a comprehensive 30-day plan with goals and checkpoints',
            utterance: 'For slow/no-ramp AEs in {OU}, generate a personalized 30-day enablement plan with goals and checkpoints.',
            tags: ['Planning', 'Enablement']
          }
        ]
      },
      {
        id: 'quick-wins',
        title: 'Quick Wins',
        description: 'Identify immediate opportunities for struggling AEs',
        actions: [
          {
            id: 'open-pipe-product',
            title: 'Open pipe on most important product per AE',
            description: 'Show pipeline opportunities by product with stage and AE score',
            utterance: 'For slow/no-ramp AEs in {OU}, show open pipe by {PRODUCT} with stage, owner, AE score.',
            tags: ['Pipeline', 'Opportunity']
          }
        ]
      }
    ]
  },
  {
    id: 'territory',
    title: 'Territory Analysis',
    blurb: 'Analyze territory performance, pipeline health, and identify growth opportunities.',
    subflows: [
      {
        id: 'open-pipe',
        title: 'Open Pipe',
        description: 'Analyze current pipeline health and identify bottlenecks',
        actions: [
          {
            id: 'biggest-open-pipe',
            title: 'Biggest open pipe by product',
            description: 'Identify which product has the largest pipeline value',
            utterance: 'Open Pipe Analysis: which product has the largest open pipe in {OU}? Include counts, ACV, and stage breakdown.',
            tags: ['Pipeline', 'Analysis']
          },
          {
            id: 'pipeline-stagnation',
            title: 'Pipeline stagnation stage',
            description: 'Find where deals are getting stuck in the pipeline',
            utterance: 'Open Pipe Analysis: which stage has the highest pipeline stagnation in {OU}?',
            tags: ['Pipeline', 'Bottlenecks']
          }
        ]
      },
      {
        id: 'pipe-gen',
        title: 'Pipe Gen (Renewal / Upsell / Cross-sell)',
        description: 'Identify opportunities for pipeline generation across different strategies',
        actions: [
          {
            id: 'top-product-renewal',
            title: 'Top product for renewal',
            description: 'Find the best product for driving renewals with opportunity links',
            utterance: 'Pipe Generation: recommend top product for renewal in {OU}; include opportunity links and likelihood (avg AE score).',
            tags: ['Renewal', 'Recommendation']
          },
          {
            id: 'top-product-upsell',
            title: 'Top product for upsell',
            description: 'Identify the best product for expanding existing accounts',
            utterance: 'Pipe Generation: recommend top product for upsell in {OU}; include target accounts and rationale.',
            tags: ['Upsell', 'Recommendation']
          },
          {
            id: 'top-product-cross-sell',
            title: 'Top product for cross-sell',
            description: 'Find the best product for cross-selling to new customer segments',
            utterance: 'Pipe Generation: recommend top product for cross-sell in {OU}; include target accounts and rationale.',
            tags: ['Cross-sell', 'Recommendation']
          }
        ]
      },
      {
        id: 'plans',
        title: 'Plans',
        description: 'Create strategic enablement plans based on analysis',
        actions: [
          {
            id: 'product-enablement-plan',
            title: 'Personalized product enablement plan per AE',
            description: 'Create customized enablement plans based on pipeline and gap analysis',
            utterance: 'Create a product enablement plan per AE in {OU} based on open pipe and gap analysis.',
            tags: ['Planning', 'Enablement']
          }
        ]
      }
    ]
  },
  {
    id: 'kpi',
    title: 'KPI Analysis',
    blurb: 'Analyze key performance indicators, ramp status, and regional performance metrics.',
    subflows: [
      {
        id: 'ramp-status',
        title: 'Ramp Status',
        description: 'Track AE performance metrics and ramp progress',
        actions: [
          {
            id: 'calls-per-ae-latam',
            title: 'Calls per AE (slow rampers LATAM)',
            description: 'Analyze call activity for struggling AEs in Latin America',
            utterance: 'KPI: CALLS CURRENT grouped by AE where ramp_status=\'Slow\' and country in (\'Brazil\',\'Argentina\',\'Chile\',\'Mexico\',\'Colombia\').',
            tags: ['KPI', 'Calls', 'LATAM']
          }
        ]
      },
      {
        id: 'regional-ou',
        title: 'Regional / OU',
        description: 'Compare performance across regions and operating units',
        actions: [
          {
            id: 'country-comparison-calls',
            title: 'Country comparison (calls)',
            description: 'Compare call activity across countries in your OU',
            utterance: 'KPI: CALLS CURRENT grouped by COUNTRY in {OU}.',
            tags: ['KPI', 'Comparison', 'Calls']
          },
          {
            id: 'growth-factors',
            title: 'Growth factors (top 5)',
            description: 'Identify the most common factors driving growth',
            utterance: 'KPI: top 5 Growth Factors by frequency in {OU}.',
            tags: ['KPI', 'Growth', 'Analysis']
          }
        ]
      }
    ]
  },
  {
    id: 'content',
    title: 'Finding Content for Enablement',
    blurb: 'Discover and organize training materials, demos, and educational content.',
    subflows: [
      {
        id: 'act-default',
        title: 'ACT Default',
        description: 'Search through ACT (Academy Content Training) resources',
        actions: [
          {
            id: 'search-act-content',
            title: 'Search ACT content',
            description: 'Find relevant courses, assets, and curriculum materials',
            utterance: 'Search ACT for "{QUERY}" across Course, Asset, Curriculum.',
            tags: ['Search', 'ACT', 'Content']
          }
        ]
      },
      {
        id: 'consensus-explicit',
        title: 'Consensus (explicit)',
        description: 'Access Consensus demo content and materials',
        actions: [
          {
            id: 'consensus-demo-content',
            title: 'Consensus demo content',
            description: 'Find the best demo content for specific products',
            utterance: 'Consensus: search demo content for "{PRODUCT}" and return top 5 with links.',
            tags: ['Demo', 'Consensus', 'Content']
          }
        ]
      },
      {
        id: 'apm',
        title: 'APM',
        description: 'Manage APM (Academy Program Management) nominations and tracking',
        actions: [
          {
            id: 'nominate-3-year-apm',
            title: 'Nominate 3-year APM',
            description: 'Create APM nominations with completion tracking',
            utterance: 'Create APM nomination for "{OFFERING}" (start {START}, end {END}); include real completion stats.',
            tags: ['APM', 'Nomination', 'Tracking']
          }
        ]
      }
    ]
  },
  {
    id: 'sme',
    title: 'Subject Matter Experts',
    blurb: 'Connect with the right experts for your enablement needs and product knowledge.',
    subflows: [
      {
        id: 'find-smes',
        title: 'Find SMEs',
        description: 'Locate subject matter experts by various criteria',
        actions: [
          {
            id: 'smes-by-product',
            title: 'By product',
            description: 'Find experts for specific products ranked by ACV and Academy status',
            utterance: 'Find SMEs for product "{PRODUCT}" (top by ACV, include Academy flag).',
            tags: ['SME', 'Product', 'Expertise']
          },
          {
            id: 'smes-by-ou',
            title: 'By OU',
            description: 'Find experts within your operating unit ranked by performance',
            utterance: 'Find SMEs in {OU} (rank by AE rank and total ACV).',
            tags: ['SME', 'OU', 'Performance']
          },
          {
            id: 'academy-members-only',
            title: 'Academy members only',
            description: 'Find only Academy-certified experts for specific products',
            utterance: 'Find SMEs for "{PRODUCT}" who are Academy members only.',
            tags: ['SME', 'Academy', 'Certified']
          }
        ]
      }
    ]
  },
  {
    id: 'priority',
    title: 'Priority Initiatives',
    blurb: 'Set and execute on priority goals with targeted AE lists and initiative packets.',
    subflows: [
      {
        id: 'goal-selection',
        title: 'Goal Selection',
        description: 'Choose and set priority goals for your team',
        actions: [
          {
            id: 'choose-goal',
            title: 'Choose goal',
            description: 'Set a priority goal for your team focus',
            utterance: 'Set priority goal to {GOAL} (Open Pipe | Renewal | Upsell | Cross-sell).',
            tags: ['Goal', 'Priority', 'Strategy']
          }
        ]
      },
      {
        id: 'outputs',
        title: 'Outputs',
        description: 'Generate targeted outputs and communications for your initiatives',
        actions: [
          {
            id: 'ae-email-list',
            title: 'AE email list',
            description: 'Generate a targeted list of AEs aligned to your goal',
            utterance: 'Generate AE email list for {OU} aligned to {GOAL}.',
            tags: ['Communication', 'Targeting', 'List']
          },
          {
            id: 'initiative-packet',
            title: 'Initiative packet',
            description: 'Create a comprehensive packet with opportunities and TSP prompts',
            utterance: 'Create initiative packet with opportunity links, customer names, $ amounts, and TSP prompts.',
            tags: ['Packet', 'Opportunities', 'TSP']
          },
          {
            id: 'send-via-email',
            title: 'Send via email service',
            description: 'Distribute the initiative packet to selected AEs',
            utterance: 'Send the initiative packet via the agent email service to the selected AEs.',
            tags: ['Email', 'Distribution', 'Communication']
          }
        ]
      }
    ]
  }
];

export function getTopicById(id: string): Topic | undefined {
  return guideData.find(topic => topic.id === id);
}

export function getAllTopics(): Topic[] {
  return guideData;
}
