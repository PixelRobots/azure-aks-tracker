import { useState, useEffect } from 'react';
import { useKV } from '@github/spark/hooks';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
import { UpdateCard } from '@/components/UpdateCard';
import { Settings } from '@/components/Settings';
import { Update } from '@/lib/types';
import { GitHubService } from '@/lib/github';
import { isNoiseCommit, groupCommitsByRelatedness, createUpdateFromCommits } from '@/lib/processing';
import { RefreshCw, Settings as SettingsIcon, GitBranch, AlertTriangle } from '@phosphor-icons/react';
import { toast } from 'sonner';
import { Toaster } from '@/components/ui/sonner';

function App() {
  const [updates, setUpdates] = useKV<Update[]>('aks-updates', []);
  const [token] = useKV<string>('github-token', '');
  const [isLoading, setIsLoading] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [lastFetch, setLastFetch] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const githubService = new GitHubService(token);

  useEffect(() => {
    if (!token) {
      setShowSettings(true);
    } else {
      setShowSettings(false);
    }
  }, [token]);

  const categories = ['All', ...Array.from(new Set(updates.map(u => u.category))).sort()];
  const filteredUpdates = selectedCategory === 'All' 
    ? updates 
    : updates.filter(u => u.category === selectedCategory);

  const fetchUpdates = async () => {
    if (!token) {
      toast.error('Please configure your GitHub token first');
      setShowSettings(true);
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      githubService.setToken(token);
      
      // Fetch commits from the last 30 days
      const since = new Date();
      since.setDate(since.getDate() - 30);
      
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

      // Merge with existing updates, avoiding duplicates
      const existingKeys = new Set(updates.map(u => u.rowKey));
      const uniqueNewUpdates = newUpdates.filter(u => !existingKeys.has(u.rowKey));
      
      if (uniqueNewUpdates.length > 0) {
        const allUpdates = [...uniqueNewUpdates, ...updates]
          .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
          .slice(0, 100); // Keep last 100 updates
        
        setUpdates(allUpdates);
        toast.success(`Found ${uniqueNewUpdates.length} new updates`);
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
              <p className="text-muted-foreground">
                Monitor meaningful changes to the Azure Kubernetes Service documentation
              </p>
            </div>
            
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowSettings(!showSettings)}
              >
                <SettingsIcon size={16} />
                Settings
              </Button>
              
              <Button
                onClick={fetchUpdates}
                disabled={isLoading || !token}
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

        {/* Settings Panel */}
        {showSettings && (
          <div className="mb-8">
            <Settings onTokenSaved={() => setShowSettings(false)} />
          </div>
        )}

        {/* Error Alert */}
        {error && (
          <Alert className="mb-6" variant="destructive">
            <AlertTriangle size={16} />
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* No Token Warning */}
        {!token && !showSettings && (
          <Alert className="mb-6">
            <SettingsIcon size={16} />
            <AlertDescription>
              Please configure your GitHub token in Settings to fetch documentation updates.
            </AlertDescription>
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
                      ({updates.filter(u => u.category === category).length})
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
                {filteredUpdates.length} update{filteredUpdates.length !== 1 ? 's' : ''}
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
            <h3 className="text-lg font-semibold mb-2">No Updates Found</h3>
            <p className="text-muted-foreground mb-4">
              {token 
                ? 'Click "Refresh" to fetch the latest documentation changes'
                : 'Configure your GitHub token to start tracking updates'
              }
            </p>
            {token && (
              <Button onClick={fetchUpdates} disabled={isLoading}>
                <RefreshCw size={16} className={isLoading ? 'animate-spin mr-2' : 'mr-2'} />
                Fetch Updates
              </Button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default App;