import { getAllTopics } from '@/lib/guide';
import TopicCard from '@/components/TopicCard';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Search } from 'lucide-react';

export default function HomePage() {
  const topics = getAllTopics();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold">Agent Guide</h1>
              <p className="text-muted-foreground mt-1">
                Discover what to ask an AI sales-enablement agent
              </p>
            </div>
            <div className="flex items-center space-x-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-4 w-4" />
                <input
                  type="text"
                  placeholder="Search actions..."
                  className="pl-10 pr-4 py-2 border rounded-md bg-background text-sm focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                  disabled
                />
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h2 className="text-2xl font-semibold mb-2">What are you trying to do?</h2>
          <p className="text-muted-foreground">
            Choose a topic to explore available actions and discover what you can ask the AI agent.
          </p>
        </div>

        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {topics.map((topic) => (
            <TopicCard key={topic.id} topic={topic} />
          ))}
        </div>

        {/* Info Card */}
        <Card className="mt-12">
          <CardHeader>
            <CardTitle>How it works</CardTitle>
            <CardDescription>
              This interface helps you discover what you can ask an AI sales-enablement agent.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-4 md:grid-cols-3">
              <div className="space-y-2">
                <h4 className="font-semibold">1. Choose a Topic</h4>
                <p className="text-sm text-muted-foreground">
                  Select from onboarding, territory analysis, KPI analysis, content discovery, SME connections, or priority initiatives.
                </p>
              </div>
              <div className="space-y-2">
                <h4 className="font-semibold">2. Explore Actions</h4>
                <p className="text-sm text-muted-foreground">
                  Browse through subflows and specific actions tailored to your needs.
                </p>
              </div>
              <div className="space-y-2">
                <h4 className="font-semibold">3. Use with Agent</h4>
                <p className="text-sm text-muted-foreground">
                  Click "Use this" to send the action to the AI agent, or copy the utterance for later use.
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
