import { LightningElement } from 'lwc';

export const Topics = [
  {
    id: 'onboarding',
    title: 'Onboarding',
    blurb: 'Get new team members to productivity faster.',
    subflows: [
      {
        id: 'rampHealth',
        title: 'Ramp Health',
        description: 'Identify and support slow/no-ramp AEs.',
        actions: [
          { id: 'slowNoByOU', title: 'Slow / No Ramp by OU', description: 'List slow/no-ramp AEs for a selected OU with summary KPIs.' },
          { id: 'fastAmer', title: 'Fast Rampers in AMER', description: 'Compare fast rampers by country within AMER.' }
        ]
      },
      {
        id: 'starterPlan',
        title: 'Starter Plans',
        description: 'Blueprints to accelerate ramp.',
        actions: [
          { id: 'personalPlan', title: 'Personalized 30-day plan', description: 'Template plan with goals, checkpoints, and reviews.' }
        ]
      },
      {
        id: 'quickWins',
        title: 'Quick Wins',
        description: 'Find immediate opportunities to act on.',
        actions: [
          { id: 'openPipeImportant', title: 'Open Pipe by Priority Product', description: 'Focus rampers on the single most impactful product.' }
        ]
      }
    ]
  },
  {
    id: 'territory',
    title: 'Territory Analysis',
    blurb: 'Spot risk and opportunity across your book.',
    subflows: [
      {
        id: 'openPipe',
        title: 'Open Pipe',
        description: 'Understand current pipeline distribution.',
        actions: [
          { id: 'biggestProduct', title: 'Largest Pipe by Product', description: 'See which product drives the most pipe in your OU.' },
          { id: 'stagnation', title: 'Where Deals Stall', description: 'Find stages with the highest stagnation.' }
        ]
      },
      {
        id: 'pipeGen',
        title: 'Pipeline Generation',
        description: 'Targeted generation levers.',
        actions: [
          { id: 'renewal', title: 'Renewal Targets', description: 'Accounts and links for renewals likely to close.' },
          { id: 'upsell', title: 'Upsell Targets', description: 'Expansion paths within existing customers.' },
          { id: 'cross', title: 'Cross-sell Targets', description: 'Adjacent product motions by fit.' }
        ]
      },
      {
        id: 'plans',
        title: 'Enablement Plans',
        description: 'Plan templates tied to pipe gaps.',
        actions: [
          { id: 'productPlan', title: 'Per-AE Product Plan', description: 'Per-AE plan based on opportunity and gaps.' }
        ]
      }
    ]
  },
  {
    id: 'kpi',
    title: 'KPI Analysis',
    blurb: 'Compare performance by ramp, OU, and region.',
    subflows: [
      {
        id: 'ramp',
        title: 'Ramp Status',
        description: 'Analyze performance by ramp category.',
        actions: [
          { id: 'latamCalls', title: 'Calls per AE (Slow, LATAM)', description: 'Current-quarter calls per AE for slow rampers in LATAM countries.' }
        ]
      },
      {
        id: 'regional',
        title: 'Regional / OU',
        description: 'Roll-ups by geography and unit.',
        actions: [
          { id: 'countryCompare', title: 'Country Comparison (Calls)', description: 'Average calls by country within an OU.' },
          { id: 'growthTop5', title: 'Top 5 Growth Factors', description: 'Most frequent growth factors observed.' }
        ]
      }
    ]
  },
  {
    id: 'content',
    title: 'Content for Enablement',
    blurb: 'Find courses, assets, and curricula.',
    subflows: [
      {
        id: 'act',
        title: 'ACT Catalog',
        description: 'Search internal enablement catalog.',
        actions: [
          { id: 'searchAct', title: 'Search ACT', description: 'Look up Courses, Assets, and Curricula.' }
        ]
      },
      {
        id: 'consensus',
        title: 'Consensus',
        description: 'Demo content and flows.',
        actions: [
          { id: 'demoContent', title: 'Top Demo Content', description: 'Popular demo content by product with links.' }
        ]
      },
      {
        id: 'apm',
        title: 'APM',
        description: 'Nomination workflows.',
        actions: [
          { id: 'apm3yr', title: '3-Year APM Nomination', description: 'Create a nomination with real completion stats.' }
        ]
      }
    ]
  },
  {
    id: 'sme',
    title: 'Subject Matter Experts',
    blurb: 'Find the right experts fast.',
    subflows: [
      {
        id: 'find',
        title: 'Find SMEs',
        description: 'Search by product or OU; Academy filter.',
        actions: [
          { id: 'byProduct', title: 'By Product', description: 'Top SMEs by ACV; Academy flag shown.' },
          { id: 'byOU', title: 'By OU', description: 'Rank SMEs by AE rank and ACV.' },
          { id: 'academyOnly', title: 'Academy Members Only', description: 'Filter results to Academy members.' }
        ]
      }
    ]
  },
  {
    id: 'priority',
    title: 'Priority Initiatives',
    blurb: 'Clarify the goal & package outputs.',
    subflows: [
      {
        id: 'goal',
        title: 'Choose Goal',
        description: 'Open Pipe | Renewal | Upsell | Cross-sell.',
        actions: [
          { id: 'chooseGoal', title: 'Select the Primary Goal', description: 'Pick your initiative type to tailor recommendations.' }
        ]
      },
      {
        id: 'outputs',
        title: 'Outputs',
        description: 'Artifacts aligned to the chosen goal.',
        actions: [
          { id: 'aeEmails', title: 'AE Email List', description: 'Generate emails aligned to the initiative.' },
          { id: 'packet', title: 'Initiative Packet', description: 'Opp links, customers, amounts, and TSP prompts.' },
          { id: 'send', title: 'Send via Email Service', description: 'Deliver packet to selected AEs.' }
        ]
      }
    ]
  }
];

export default class GuideData extends LightningElement {
  // This is a data-only component
}
