'use client';
import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Copy, Send } from 'lucide-react';
import { LeafAction } from '@/lib/guide';
import { sendUtterance, copyToClipboard } from '@/lib/events';

interface ActionCardProps {
  action: LeafAction;
  topicId: string;
  subflowId: string;
}

export default function ActionCard({ action, topicId, subflowId }: ActionCardProps) {
  const [isCopied, setIsCopied] = useState(false);

  const handleUseAction = () => {
    sendUtterance(action.utterance, {
      topicId,
      subflowId,
      actionId: action.id
    });
  };

  const handleCopyUtterance = async () => {
    const success = await copyToClipboard(action.utterance);
    if (success) {
      setIsCopied(true);
      setTimeout(() => setIsCopied(false), 2000);
    }
  };

  return (
    <Card 
      className="transition-all hover:shadow-md hover:border-primary/20"
      data-utterance={action.utterance}
    >
      <CardHeader>
        <CardTitle className="text-lg">{action.title}</CardTitle>
        <CardDescription className="text-sm leading-relaxed">
          {action.description}
        </CardDescription>
        {action.tags && action.tags.length > 0 && (
          <div className="flex flex-wrap gap-1 mt-2">
            {action.tags.map((tag, index) => (
              <Badge key={index} variant="secondary" className="text-xs">
                {tag}
              </Badge>
            ))}
          </div>
        )}
      </CardHeader>
      <CardContent>
        <div className="flex gap-2">
          <Button 
            onClick={handleUseAction}
            className="flex-1"
            size="sm"
          >
            <Send className="h-4 w-4 mr-2" />
            Use this
          </Button>
          <Button 
            onClick={handleCopyUtterance}
            variant="outline"
            size="sm"
          >
            <Copy className="h-4 w-4 mr-2" />
            {isCopied ? 'Copied!' : 'Copy'}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
