'use client';
import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { UtteranceEvent } from '@/lib/events';

export default function AgentDock() {
  const [lastUtterance, setLastUtterance] = useState<UtteranceEvent | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const handler = (e: CustomEvent<UtteranceEvent>) => {
      setLastUtterance(e.detail);
    };

    window.addEventListener('agent:utterance', handler as EventListener);
    return () => window.removeEventListener('agent:utterance', handler as EventListener);
  }, []);

  const connect = () => {
    setIsConnected(true);
    // TODO: Implement actual agent connection
  };

  return (
    <aside className="lg:sticky lg:top-0 h-screen p-4 border-l bg-muted/30">
      <Card className="h-full">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-green-500"></div>
            Agent Dock
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="text-sm text-muted-foreground">
            {isConnected ? (
              <Badge variant="default">Connected</Badge>
            ) : (
              <Badge variant="secondary">Not Connected</Badge>
            )}
          </div>
          
          {!isConnected && (
            <button
              onClick={connect}
              className="w-full text-sm text-primary hover:underline"
            >
              Connect Agent
            </button>
          )}

          {lastUtterance && (
            <div className="space-y-2">
              <div className="text-xs uppercase font-medium text-muted-foreground">
                Last Utterance
              </div>
              <div className="rounded-lg border p-3 bg-background">
                <pre className="text-sm whitespace-pre-wrap font-mono">
                  {lastUtterance.utterance}
                </pre>
                {lastUtterance.meta && (
                  <div className="mt-2 flex flex-wrap gap-1">
                    {lastUtterance.meta.topicId && (
                      <Badge variant="outline" className="text-xs">
                        {lastUtterance.meta.topicId}
                      </Badge>
                    )}
                    {lastUtterance.meta.subflowId && (
                      <Badge variant="outline" className="text-xs">
                        {lastUtterance.meta.subflowId}
                      </Badge>
                    )}
                    {lastUtterance.meta.actionId && (
                      <Badge variant="outline" className="text-xs">
                        {lastUtterance.meta.actionId}
                      </Badge>
                    )}
                  </div>
                )}
              </div>
            </div>
          )}

          <div className="text-xs text-muted-foreground">
            <p>This panel is reserved for the AI agent interface. Click "Use this" on any action to send it to the agent.</p>
          </div>
        </CardContent>
      </Card>
    </aside>
  );
}
