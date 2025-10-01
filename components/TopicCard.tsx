import Link from 'next/link';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Topic } from '@/lib/guide';
import { ArrowRight } from 'lucide-react';

interface TopicCardProps {
  topic: Topic;
}

export default function TopicCard({ topic }: TopicCardProps) {
  return (
    <Link href={`/${topic.id}`} className="group">
      <Card className="h-full transition-all hover:shadow-lg hover:scale-[1.02] group-hover:border-primary/20">
        <CardHeader>
          <CardTitle className="group-hover:text-primary transition-colors">
            {topic.title}
          </CardTitle>
          <CardDescription className="text-sm leading-relaxed">
            {topic.blurb}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-between text-sm text-muted-foreground">
            <span>{topic.subflows.length} subflows</span>
            <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
