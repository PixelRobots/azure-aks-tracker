import { Update } from '@/lib/types';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ExternalLink, BookOpen } from '@phosphor-icons/react';
import { formatDistanceToNow } from 'date-fns';

interface UpdateCardProps {
  update: Update;
}

// Helper function to format text with bullet points
const formatTextWithBullets = (text: string) => {
  // Check if text contains bullet points (•, -, *, or numbered lists)
  const hasBulletPoints = /^[\s]*[•\-\*]|\d+\./.test(text) || text.includes('\n•') || text.includes('\n-') || text.includes('\n*');
  
  if (!hasBulletPoints) {
    return <span>{text}</span>;
  }
  
  // Split by newlines and process each line
  const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 0);
  
  return (
    <div className="space-y-1">
      {lines.map((line, index) => {
        // Check if line starts with bullet point
        const isBulletPoint = /^[•\-\*]\s/.test(line) || /^\d+\.\s/.test(line);
        
        if (isBulletPoint) {
          // Remove the bullet/number and return as list item
          const cleanedLine = line.replace(/^[•\-\*]\s/, '').replace(/^\d+\.\s/, '');
          return (
            <div key={index} className="flex items-start gap-2">
              <span className="text-primary mt-1 flex-shrink-0">•</span>
              <span className="flex-1">{cleanedLine}</span>
            </div>
          );
        } else {
          // Regular text line
          return (
            <div key={index} className={index > 0 ? 'mt-2' : ''}>
              {line}
            </div>
          );
        }
      })}
    </div>
  );
};

const getCategoryColor = (category: string): string => {
  const colors: Record<string, string> = {
    'Reliability': 'bg-green-100/80 dark:bg-green-900/30 text-green-900 dark:text-green-200 border-green-300 dark:border-green-800',
    'Networking/DNS': 'bg-blue-100/80 dark:bg-blue-900/30 text-blue-900 dark:text-blue-200 border-blue-300 dark:border-blue-800',
    'Networking': 'bg-blue-100/80 dark:bg-blue-900/30 text-blue-900 dark:text-blue-200 border-blue-300 dark:border-blue-800',
    'Upgrade': 'bg-purple-100/80 dark:bg-purple-900/30 text-purple-900 dark:text-purple-200 border-purple-300 dark:border-purple-800',
    'Fleet Manager': 'bg-indigo-100/80 dark:bg-indigo-900/30 text-indigo-900 dark:text-indigo-200 border-indigo-300 dark:border-indigo-800',
    'Security': 'bg-red-100/80 dark:bg-red-900/30 text-red-900 dark:text-red-200 border-red-300 dark:border-red-800',
    'Monitoring': 'bg-yellow-100/80 dark:bg-yellow-900/30 text-yellow-900 dark:text-yellow-200 border-yellow-300 dark:border-yellow-800',
    'Troubleshooting': 'bg-orange-100/80 dark:bg-orange-900/30 text-orange-900 dark:text-orange-200 border-orange-300 dark:border-orange-800',
    'Concepts': 'bg-gray-100/80 dark:bg-gray-800/30 text-gray-900 dark:text-gray-200 border-gray-300 dark:border-gray-700',
    'Tutorial': 'bg-emerald-100/80 dark:bg-emerald-900/30 text-emerald-900 dark:text-emerald-200 border-emerald-300 dark:border-emerald-800',
    'Quickstart': 'bg-teal-100/80 dark:bg-teal-900/30 text-teal-900 dark:text-teal-200 border-teal-300 dark:border-teal-800',
    'Best Practices': 'bg-violet-100/80 dark:bg-violet-900/30 text-violet-900 dark:text-violet-200 border-violet-300 dark:border-violet-800',
    'Cluster Management': 'bg-rose-100/80 dark:bg-rose-900/30 text-rose-900 dark:text-rose-200 border-rose-300 dark:border-rose-800',
    'Node Management': 'bg-pink-100/80 dark:bg-pink-900/30 text-pink-900 dark:text-pink-200 border-pink-300 dark:border-pink-800',
    'Workloads': 'bg-cyan-100/80 dark:bg-cyan-900/30 text-cyan-900 dark:text-cyan-200 border-cyan-300 dark:border-cyan-800',
    'Storage': 'bg-amber-100/80 dark:bg-amber-900/30 text-amber-900 dark:text-amber-200 border-amber-300 dark:border-amber-800',
    'Ingress': 'bg-lime-100/80 dark:bg-lime-900/30 text-lime-900 dark:text-lime-200 border-lime-300 dark:border-lime-800',
    'Autoscaling': 'bg-sky-100/80 dark:bg-sky-900/30 text-sky-900 dark:text-sky-200 border-sky-300 dark:border-sky-800',
    'GPU/Compute': 'bg-fuchsia-100/80 dark:bg-fuchsia-900/30 text-fuchsia-900 dark:text-fuchsia-200 border-fuchsia-300 dark:border-fuchsia-800',
    'Windows Containers': 'bg-slate-100/80 dark:bg-slate-800/30 text-slate-900 dark:text-slate-200 border-slate-300 dark:border-slate-700'
  };
  
  return colors[category] || 'bg-gray-100/80 dark:bg-gray-800/30 text-gray-900 dark:text-gray-200 border-gray-300 dark:border-gray-700';
};

export function UpdateCard({ update }: UpdateCardProps) {
  const formattedDate = formatDistanceToNow(new Date(update.date), { addSuffix: true });
  
  return (
    <Card className="hover:shadow-md transition-shadow duration-200">
      <CardHeader className="pb-3">
        <div className="flex items-start justify-between gap-4">
          <div className="flex-1">
            <a 
              href={update.url}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex items-start gap-2 text-lg font-semibold text-foreground hover:text-primary transition-colors"
            >
              <span className="flex-1">{update.title}</span>
              <ExternalLink 
                size={16} 
                className="mt-1 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0" 
              />
            </a>
          </div>
        </div>
        
        <div className="flex items-center gap-3 text-sm text-muted-foreground">
          <Badge 
            variant="outline" 
            className={`font-medium ${getCategoryColor(update.category)} text-black dark:text-inherit`}
          >
            {update.category}
          </Badge>
        </div>
      </CardHeader>
      
      <CardContent className="pt-0">
        <div className="space-y-3">
          <div>
            <h4 className="font-medium text-sm text-foreground mb-1">Summary</h4>
            <div className="text-sm text-muted-foreground leading-relaxed">
              {formatTextWithBullets(update.summary)}
            </div>
          </div>
          
          <div>
            <h4 className="font-medium text-sm text-foreground mb-1">Impact</h4>
            <div className="text-sm text-muted-foreground leading-relaxed">
              {formatTextWithBullets(update.impact)}
            </div>
          </div>
          
          {update.commits && update.commits.length > 1 ? (
            <div className="text-xs text-muted-foreground pt-2 border-t">
              Consolidated from {update.commits.length} related commits • Last updated {formattedDate}
            </div>
          ) : (
            <div className="text-xs text-muted-foreground pt-2 border-t">
              Last updated {formattedDate}
            </div>
          )}
          
          <div className="pt-3">
            <Button 
              asChild 
              size="sm" 
              className="w-full"
            >
              <a 
                href={update.url}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2"
              >
                <BookOpen size={14} />
                View Documentation
              </a>
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}