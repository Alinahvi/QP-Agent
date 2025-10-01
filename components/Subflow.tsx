import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import ActionCard from '@/components/ActionCard';
import { SubFlow } from '@/lib/guide';

interface SubflowProps {
  subflow: SubFlow;
  topicId: string;
}

export default function Subflow({ subflow, topicId }: SubflowProps) {
  return (
    <Accordion type="single" collapsible className="w-full">
      <AccordionItem value={subflow.id} className="border rounded-lg">
        <AccordionTrigger className="px-6 py-4 hover:no-underline">
          <div className="text-left">
            <h3 className="text-lg font-semibold">{subflow.title}</h3>
            {subflow.description && (
              <p className="text-sm text-muted-foreground mt-1">
                {subflow.description}
              </p>
            )}
          </div>
        </AccordionTrigger>
        <AccordionContent className="px-6 pb-4">
          <div className="grid gap-4 md:grid-cols-2">
            {subflow.actions.map((action) => (
              <ActionCard
                key={action.id}
                action={action}
                topicId={topicId}
                subflowId={subflow.id}
              />
            ))}
          </div>
        </AccordionContent>
      </AccordionItem>
    </Accordion>
  );
}
