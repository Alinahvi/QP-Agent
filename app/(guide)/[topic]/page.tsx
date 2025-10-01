import { notFound } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { getTopicById } from '@/lib/guide';
import Subflow from '@/components/Subflow';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';

interface TopicPageProps {
  params: {
    topic: string;
  };
}

export default function TopicPage({ params }: TopicPageProps) {
  const topic = getTopicById(params.topic);

  if (!topic) {
    notFound();
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container mx-auto px-4 py-6">
          <div className="flex items-center space-x-4">
            <Button variant="ghost" size="sm" asChild>
              <Link href="/">
                <ArrowLeft className="h-4 w-4 mr-2" />
                Back to Topics
              </Link>
            </Button>
            <div>
              <h1 className="text-3xl font-bold">{topic.title}</h1>
              <p className="text-muted-foreground mt-1">{topic.blurb}</p>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="space-y-6">
          {topic.subflows.map((subflow) => (
            <Subflow
              key={subflow.id}
              subflow={subflow}
              topicId={topic.id}
            />
          ))}
        </div>

        {/* Help Card */}
        <Card className="mt-12">
          <CardHeader>
            <CardTitle>Need help?</CardTitle>
            <CardDescription>
              Each action is designed to work with the AI agent. Click "Use this" to send the action directly to the agent.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-2 text-sm text-muted-foreground">
              <p>• <strong>Use this:</strong> Sends the action to the AI agent in the right panel</p>
              <p>• <strong>Copy:</strong> Copies the utterance to your clipboard for later use</p>
              <p>• <strong>Placeholders:</strong> Replace {`{OU}`}, {`{COUNTRY}`}, {`{PRODUCT}`} etc. with your actual values</p>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}
