import { useState } from 'react';
import { useKV } from '@github/spark/hooks';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
import { UpdateCard } from '@/components/UpdateCard';
import { Update } from '@/lib/types';
import { GitHubService } from '@/lib/github';
import { isNoiseCommit, groupCommitsByRelatedness, createUpdateFromCommits } from '@/lib/processing';
import { RefreshCw, GitBranch, AlertTriangle, Warning, Trash2 } from '@phosphor-icons/react';
import { toast } from 'sonner';
import { Toaster } from '@/components/ui/sonner';

function App() {
  const [updates, setUpdates] = useKV<Update[]>('aks-updates', []);
  const [isLoading, setIsLoading] = useState(false);
  const [lastFetch, setLastFetch] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const githubService = new GitHubService(); // No token needed for public repo

  // Helper function to merge updates with the same URL
  const mergeUpdatesByUrl = (updates: Update[]): Update[] => {
    const urlGroups = new Map<string, Update[]>();
    
    // Group updates by URL
    for (const update of updates) {
      const existing = urlGroups.get(update.url) || [];
      existing.push(update);
      urlGroups.set(update.url, existing);
    }
    
    // Merge each group into a single update
    const mergedUpdates: Update[] = [];
    for (const [url, groupUpdates] of urlGroups) {
      if (groupUpdates.length === 1) {
        mergedUpdates.push(groupUpdates[0]);
      } else {
        // Sort by date to get the earliest and latest
        const sortedByDate = groupUpdates.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        const earliest = sortedByDate[0];
        const latest = sortedByDate[sortedByDate.length - 1];
        
        // Combine unique summaries and impacts
        const uniqueSummaries = Array.from(new Set(groupUpdates.map(u => u.summary.trim())));
        const uniqueImpacts = Array.from(new Set(groupUpdates.map(u => u.impact.trim())));
        
        // Create merged update
        const mergedUpdate: Update = {
          ...earliest, // Use earliest as base
          rowKey: `merged-${latest.rowKey}`, // Create unique key
          title: `${earliest.title.replace(/ \(\d+ updates?\)$/, '')} (${groupUpdates.length} updates)`,
          summary: uniqueSummaries.length > 1 ? uniqueSummaries.join(' • ') : uniqueSummaries[0],
          impact: uniqueImpacts.length > 1 ? uniqueImpacts.join(' • ') : uniqueImpacts[0],
          commits: Array.from(new Set(groupUpdates.flatMap(u => u.commits || []))),
          date: latest.date // Use latest date for sorting
        };
        
        mergedUpdates.push(mergedUpdate);
      }
    }
    
    return mergedUpdates.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  };

  // Filter updates to only show those from the last 7 days
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  
  const recentUpdates = updates.filter(update => {
    const updateDate = new Date(update.date);
    return updateDate >= sevenDaysAgo;
  });

  const mergedUpdates = mergeUpdatesByUrl(recentUpdates);
  const categories = ['All', ...Array.from(new Set(mergedUpdates.map(u => u.category))).sort()];
  const filteredUpdates = selectedCategory === 'All' 
    ? mergedUpdates 
    : mergedUpdates.filter(u => u.category === selectedCategory);

  const fetchUpdates = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // Fetch commits from the last 7 days
      const since = new Date();
      since.setDate(since.getDate() - 7);
      
      const commits = await githubService.getRecentCommits(since.toISOString());
      
      if (commits.length === 0) {
        toast.info('No recent commits found');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Filter out noise commits
      const meaningfulCommits = commits.filter(commit => !isNoiseCommit(commit));
      
      if (meaningfulCommits.length === 0) {
        toast.info('No meaningful changes found in recent commits');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Group related commits
      const commitGroups = groupCommitsByRelatedness(meaningfulCommits);
      
      // Create updates from commit groups
      const newUpdates: Update[] = [];
      
      for (const group of commitGroups) {
        try {
          const update = createUpdateFromCommits(group);
          
          // Use AI to enhance summary and impact if available
          try {
            const prompt = spark.llmPrompt`
            Analyze these Azure AKS documentation commits and provide a concise summary and impact assessment:
            
            Commits: ${group.map(c => `- ${c.message} (files: ${c.files.join(', ')})`).join('\n')}
            
            Please respond with JSON in this format:
            {
              "summary": "1-2 sentences describing what changed",
              "impact": "1-2 sentences describing how this affects AKS users"
            }
            `;
            
            const analysis = await spark.llm(prompt, 'gpt-4o-mini', true);
            const parsed = JSON.parse(analysis);
            
            if (parsed.summary && parsed.impact) {
              update.summary = parsed.summary;
              update.impact = parsed.impact;
            }
          } catch (aiError) {
            console.warn('Failed to enhance with AI:', aiError);
          }
          
          newUpdates.push(update);
        } catch (error) {
          console.warn('Failed to create update from commit group:', error);
        }
      }

      // Merge with existing updates, avoiding duplicates and filtering old data
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      
      // Filter existing updates to only keep recent ones
      const recentExistingUpdates = updates.filter(update => {
        const updateDate = new Date(update.date);
        return updateDate >= sevenDaysAgo;
      });
      
      const existingKeys = new Set(recentExistingUpdates.map(u => u.rowKey));
      const uniqueNewUpdates = newUpdates.filter(u => !existingKeys.has(u.rowKey));
      
      if (uniqueNewUpdates.length > 0 || recentExistingUpdates.length !== updates.length) {
        const allUpdates = [...uniqueNewUpdates, ...recentExistingUpdates]
          .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
          .slice(0, 100); // Keep last 100 updates
        
        setUpdates(allUpdates);
        
        if (uniqueNewUpdates.length > 0) {
          toast.success(`Found ${uniqueNewUpdates.length} new updates`);
        }
        
        if (recentExistingUpdates.length !== updates.length) {
          toast.info(`Cleaned up ${updates.length - recentExistingUpdates.length} old updates`);
        }
      } else {
        toast.info('No new updates found');
      }
      
      setLastFetch(new Date().toISOString());
      
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      setError(errorMessage);
      toast.error(`Failed to fetch updates: ${errorMessage}`);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <Toaster position="top-right" />
      
      <div className="container mx-auto px-4 py-8 max-w-6xl">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-3xl font-bold text-foreground mb-2">
                Azure AKS Documentation Tracker
              </h1>
              <p className="text-muted-foreground leading-relaxed">
                Welcome! This tool automatically tracks and summarizes meaningful updates to the Azure Kubernetes Service (AKS) documentation. <br /><br />
                It filters out typos, minor edits, and bot changes, so you only see what really matters. <br />
                Check back often or hit "Refresh" to explore what's new in the last 7 days.
              </p>
              <p className="text-sm text-muted-foreground mt-2 italic">
                <br />Powered by GitHub Spark and GitHub Copilot — built to keep your AKS knowledge up to date with less noise.
              </p>
            </div>
            
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  setUpdates([]);
                  toast.success('All stored data cleared');
                }}
                className="flex items-center gap-2"
              >
                <Trash2 size={14} />
                Clear Data
              </Button>
              <Button
                onClick={fetchUpdates}
                disabled={isLoading}
                className="flex items-center gap-2"
              >
                <RefreshCw size={16} className={isLoading ? 'animate-spin' : ''} />
                {isLoading ? 'Fetching...' : 'Refresh'}
              </Button>
            </div>
          </div>

          {lastFetch && (
            <div className="text-sm text-muted-foreground">
              Last updated: {new Date(lastFetch).toLocaleString()}
            </div>
          )}
        </div>

        {/* Warning Alert */}
        <Alert className="mb-6 border-amber-200 bg-amber-50/50">
          <Warning size={16} className="text-amber-600" />
          <AlertDescription className="text-amber-800">
            <span>This app is built with <strong>GitHub Spark</strong> and is currently in <em>alpha</em>.</span> Expect occasional changes or interruptions as it evolves.
          </AlertDescription>
        </Alert>


        {/* Error Alert */}
        {error && (
          <Alert className="mb-6" variant="destructive">
            <AlertTriangle size={16} />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* Category Filter */}
        {updates.length > 0 && (
          <div className="mb-6">
            <div className="flex items-center gap-2 mb-3">
              <GitBranch size={16} className="text-muted-foreground" />
              <span className="text-sm font-medium">Filter by category:</span>
            </div>
            <div className="flex flex-wrap gap-2">
              {categories.map(category => (
                <Badge
                  key={category}
                  variant={selectedCategory === category ? "default" : "outline"}
                  className="cursor-pointer hover:bg-primary/10 transition-colors"
                  onClick={() => setSelectedCategory(category)}
                >
                  {category}
                  {category !== 'All' && (
                    <span className="ml-1 text-xs">
                      ({mergedUpdates.filter(u => u.category === category).length})
                    </span>
                  )}
                </Badge>
              ))}
            </div>
          </div>
        )}

        <Separator className="mb-8" />

        {/* Updates List */}
        {filteredUpdates.length > 0 ? (
          <div className="space-y-6">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">
                Recent Updates {selectedCategory !== 'All' && `- ${selectedCategory}`}
              </h2>
              <Badge variant="secondary">
                {filteredUpdates.length} update{filteredUpdates.length !== 1 ? 's' : ''} (last 7 days)
              </Badge>
            </div>
            
            <div className="grid gap-4">
              {filteredUpdates.map((update) => (
                <UpdateCard key={update.rowKey} update={update} />
              ))}
            </div>
          </div>
        ) : (
          <div className="text-center py-12">
            <GitBranch size={48} className="mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">No Recent Updates Found</h3>
            <p className="text-muted-foreground mb-4">
              {updates.length > 0 
                ? "No updates found in the last 7 days. Click \"Refresh\" to check for newer changes."
                : "Click \"Refresh\" to fetch the latest documentation changes from the past 7 days"
              }
            </p>
            <Button onClick={fetchUpdates} disabled={isLoading}>
              <RefreshCw size={16} className={isLoading ? 'animate-spin mr-2' : 'mr-2'} />
              Fetch Updates
            </Button>
          </div>
        )}
      </div>
      
      {/* Footer */}
      <footer className="mt-16 border-t bg-muted/30">
        <div className="container mx-auto px-4 py-6 max-w-6xl">
          <div className="text-center text-sm text-muted-foreground">
            Built by{' '}
            <a 
              href="https://pixelrobots.co.uk" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-primary hover:text-primary/80 transition-colors font-medium"
            >
              pixelrobots.co.uk
            </a>
            {' '}with the help of{' '}
            <a 
              href="https://github.com/features/spark" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-primary hover:text-primary/80 transition-colors font-medium"
            >
              GitHub Spark
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;