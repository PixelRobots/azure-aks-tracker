import { Update } from '@/lib/types';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { ExternalLink } from '@phosphor-icons/react';
import { formatDistanceToNow } from 'date-fns';

interface UpdateCardProps {
  update: Update;
}

const getCategoryColor = (category: string): string => {
  const colors: Record<string, string> = {
    'Reliability': 'bg-green-100 text-green-800 border-green-200',
    'Networking/DNS': 'bg-blue-100 text-blue-800 border-blue-200',
    'Networking': 'bg-blue-100 text-blue-800 border-blue-200',
    'Upgrade': 'bg-purple-100 text-purple-800 border-purple-200',
    'Fleet Manager': 'bg-indigo-100 text-indigo-800 border-indigo-200',
    'Security': 'bg-red-100 text-red-800 border-red-200',
    'Monitoring': 'bg-yellow-100 text-yellow-800 border-yellow-200',
    'Troubleshooting': 'bg-orange-100 text-orange-800 border-orange-200',
    'Concepts': 'bg-gray-100 text-gray-800 border-gray-200',
    'Tutorial': 'bg-emerald-100 text-emerald-800 border-emerald-200',
    'Quickstart': 'bg-teal-100 text-teal-800 border-teal-200',
    'Best Practices': 'bg-violet-100 text-violet-800 border-violet-200',
    'Cluster Management': 'bg-rose-100 text-rose-800 border-rose-200',
    'Node Management': 'bg-pink-100 text-pink-800 border-pink-200',
    'Workloads': 'bg-cyan-100 text-cyan-800 border-cyan-200',
    'Storage': 'bg-amber-100 text-amber-800 border-amber-200',
    'Ingress': 'bg-lime-100 text-lime-800 border-lime-200',
    'Autoscaling': 'bg-sky-100 text-sky-800 border-sky-200',
    'GPU/Compute': 'bg-fuchsia-100 text-fuchsia-800 border-fuchsia-200',
    'Windows Containers': 'bg-slate-100 text-slate-800 border-slate-200'
  };
  
  return colors[category] || 'bg-gray-100 text-gray-800 border-gray-200';
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
            className={`font-medium ${getCategoryColor(update.category)}`}
          >
            {update.category}
          </Badge>
        </div>
      </CardHeader>
      
      <CardContent className="pt-0">
        <div className="space-y-3">
          <div>
            <h4 className="font-medium text-sm text-foreground mb-1">Summary</h4>
            <p className="text-sm text-muted-foreground leading-relaxed">
              {update.summary}
            </p>
          </div>
          
          <div>
            <h4 className="font-medium text-sm text-foreground mb-1">Impact</h4>
            <p className="text-sm text-muted-foreground leading-relaxed">
              {update.impact}
            </p>
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
                <ExternalLink size={14} />
                View Documentation
              </a>
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}