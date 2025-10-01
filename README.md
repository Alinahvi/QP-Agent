# Agent Guide UI

A production-ready Next.js application that helps users discover what to ask an AI sales-enablement agent. The UI provides a guided menu → subflow experience where every click corresponds to a future "utterance" sent to the agent.

## Features

- **67%/33% Layout**: Left content area with reserved right panel for agent integration
- **6 Main Topics**: Onboarding, Territory Analysis, KPI Analysis, Content Discovery, SME Connections, Priority Initiatives
- **Interactive Actions**: Each action can be sent to the agent or copied to clipboard
- **Event System**: Custom events for agent communication
- **Responsive Design**: Mobile-friendly with collapsible agent dock
- **Accessibility**: Keyboard navigation, ARIA labels, focus states

## Tech Stack

- **Framework**: Next.js 14 with App Router
- **Language**: TypeScript
- **Styling**: TailwindCSS + shadcn/ui components
- **Icons**: Lucide React
- **State**: Local component state + custom event system

## Getting Started

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Run the development server**:
   ```bash
   npm run dev
   ```

3. **Open your browser**:
   Navigate to [http://localhost:3000](http://localhost:3000)

## Project Structure

```
├── app/
│   ├── (guide)/
│   │   └── [topic]/
│   │       └── page.tsx          # Dynamic topic pages
│   ├── globals.css               # Global styles
│   ├── layout.tsx                # Root layout with 67%/33% split
│   ├── not-found.tsx             # 404 page
│   └── page.tsx                  # Home page with topic grid
├── components/
│   ├── ui/                       # shadcn/ui components
│   │   ├── accordion.tsx
│   │   ├── badge.tsx
│   │   ├── button.tsx
│   │   └── card.tsx
│   ├── ActionCard.tsx            # Individual action cards
│   ├── AgentDock.tsx             # Right panel for agent
│   ├── Subflow.tsx               # Accordion of actions
│   └── TopicCard.tsx             # Topic cards for home page
├── lib/
│   ├── events.ts                 # Event system for agent communication
│   ├── guide.ts                  # Data model and content
│   └── utils.ts                  # Utility functions
└── public/                       # Static assets
```

## Usage

### Home Page
- Displays 6 topic cards in a responsive grid
- Each card shows title, description, and subflow count
- Click any card to navigate to the topic page

### Topic Pages
- Shows all subflows for the selected topic
- Each subflow is an expandable accordion
- Actions are displayed in a 2-column grid
- Each action has "Use this" and "Copy" buttons

### Agent Dock
- Always visible on desktop (right 33% of screen)
- Collapsible on mobile
- Shows connection status
- Displays last emitted utterance
- Reserved space for future agent integration

### Event System
- Clicking "Use this" emits a `CustomEvent('agent:utterance')`
- Event includes utterance text and metadata
- Agent dock listens for events and displays them
- "Copy" button copies utterance to clipboard

## Data Model

The application uses a typed data structure defined in `lib/guide.ts`:

```typescript
type LeafAction = {
  id: string;
  title: string;
  description: string;
  utterance: string;        // What gets sent to the agent
  tags?: string[];
};

type SubFlow = {
  id: string;
  title: string;
  description?: string;
  actions: LeafAction[];
};

type Topic = {
  id: 'onboarding'|'territory'|'kpi'|'content'|'sme'|'priority';
  title: string;
  blurb: string;
  subflows: SubFlow[];
};
```

## Customization

### Adding New Topics
1. Add new topic ID to the `Topic` type in `lib/guide.ts`
2. Add topic data to the `guideData` array
3. The routing will automatically work

### Modifying Actions
1. Edit the `guideData` array in `lib/guide.ts`
2. Update utterance strings as needed
3. Add or modify tags for better categorization

### Styling
- Uses TailwindCSS with custom design system
- Modify `tailwind.config.js` for theme changes
- Update component styles in individual files

## Development

### Available Scripts
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

### Code Quality
- TypeScript for type safety
- ESLint for code quality
- Prettier for code formatting (recommended)
- Accessible components with ARIA labels

## Future Enhancements

- [ ] Search functionality across all actions
- [ ] Tag filtering system
- [ ] Breadcrumb navigation
- [ ] Agent connection integration
- [ ] User preferences and favorites
- [ ] Analytics and usage tracking

## License

MIT License - see LICENSE file for details.