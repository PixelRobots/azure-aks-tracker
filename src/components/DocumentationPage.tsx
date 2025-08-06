import { useState, useEffect } from 'react';
import { useKV } from '@github/spark/hooks';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
import { UpdateCard } from '@/components/UpdateCard';
import { Update } from '@/lib/types';
import { GitHubService } from '@/lib/github';
import { isNoiseCommit, groupCommitsByRelatedness, createUpdateFromCommits } from '@/lib/processing';
import { GitBranch, AlertTriangle, Clock } from '@phosphor-icons/react';
import { toast } from 'sonner';

export function DocumentationPage() {
  const [updates, setUpdates] = useKV<Update[]>('aks-updates', []);
  const [lastFetch, setLastFetch] = useKV<string>('aks-last-fetch', '');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<string>('All');

  const githubService = new GitHubService(); // No token needed for public repo

  // Clean old bullet points from summary and impact
  const cleanBulletPoints = (text: string): string => {
    return text.replace(/\s*•\s*/g, '\n• ').trim();
  };

  // Check if we need to fetch data
  const shouldFetchData = () => {
    if (!lastFetch) return true;
    
    const lastFetchTime = new Date(lastFetch);
    const now = new Date();
    const hoursSinceLastFetch = (now.getTime() - lastFetchTime.getTime()) / (1000 * 60 * 60);
    
    // Fetch data every 12 hours
    return hoursSinceLastFetch >= 12;
  };

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
        const singleUpdate = { ...groupUpdates[0] };
        singleUpdate.summary = cleanBulletPoints(singleUpdate.summary);
        singleUpdate.impact = cleanBulletPoints(singleUpdate.impact);
        mergedUpdates.push(singleUpdate);
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
          summary: cleanBulletPoints(uniqueSummaries.length > 1 ? uniqueSummaries.join('\n• ') : uniqueSummaries[0]),
          impact: cleanBulletPoints(uniqueImpacts.length > 1 ? uniqueImpacts.join('\n• ') : uniqueImpacts[0]),
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

  const fetchUpdates = async (showToasts = true) => {
    setIsLoading(true);
    setError(null);

    try {
      // Fetch commits from the last 7 days
      const since = new Date();
      since.setDate(since.getDate() - 7);
      
      const commits = await githubService.getRecentCommits(since.toISOString());
      
      if (commits.length === 0) {
        if (showToasts) toast.info('No recent commits found');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Filter out noise commits
      const meaningfulCommits = commits.filter(commit => !isNoiseCommit(commit));
      
      if (meaningfulCommits.length === 0) {
        if (showToasts) toast.info('No meaningful changes found in recent commits');
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
              Analyze the following Azure AKS documentation commits by focusing on the content changes inside the files, not the commit messages or code diffs.
              
              Scoring priority for your analysis (highest to lowest importance):
              1. Substantive content changes (new topics, new sections, expanded explanations, new features covered)
              2. New or updated examples, code snippets, or diagrams that improve understanding
              3. Reorganization or restructuring of sections for clarity
              4. Formatting or style-only changes (mention only if no other substantive changes are present)
              
              Inference step:
              - When a section is reworded or updated, infer the likely intent and explain it in plain language (e.g., "The introduction was rewritten to better explain when to use managed namespaces" instead of "clarity improvements").
              - When something is added, briefly describe the new information and why it might be useful.
              - When something is removed, briefly note what was removed and the possible reason if apparent.
              
              Your goal:
              - Identify and clearly describe the topics or features affected.
              - Indicate if this is a new document or an update to existing content.
              - For updates, specify what sections or content areas were changed and in what way (e.g., "A new troubleshooting section was added for MCP Server connectivity issues").
              - Avoid generic statements like "minor updates" or "formatting changes" unless there truly is no substantive change.
              - Use clear, reader-friendly language that an AKS end user would understand.
              
              Commits:
              ${group.map(c => `- ${c.message} (files: ${c.files.join(', ')})`).join('\n')}
              
              Please respond with JSON in this format:
              {
                "summary": "1-2 sentences summarizing the actual content changes (e.g., 'A new section on configuring AKS MCP Server was added, and the managed namespaces guide now includes troubleshooting tips.')",
                "impact": "1-2 sentences explaining how these content changes affect or help AKS users."
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
        
        if (showToasts && uniqueNewUpdates.length > 0) {
          toast.success(`Found ${uniqueNewUpdates.length} new updates`);
        }
        
        if (showToasts && recentExistingUpdates.length !== updates.length) {
          toast.info(`Cleaned up ${updates.length - recentExistingUpdates.length} old updates`);
        }
      } else {
        if (showToasts) toast.info('No new updates found');
      }
      
      setLastFetch(new Date().toISOString());
      
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      setError(errorMessage);
      if (showToasts) toast.error(`Failed to fetch updates: ${errorMessage}`);
    } finally {
      setIsLoading(false);
    }
  };

  // Auto-fetch data on component mount and when needed
  useEffect(() => {
    if (shouldFetchData()) {
      fetchUpdates(false); // Don't show toasts for automatic fetches
    }
  }, []);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-foreground mb-2">
            Documentation Updates
          </h2>
          <p className="text-muted-foreground">
            Meaningful updates to the Azure Kubernetes Service (AKS) documentation from the last 7 days.
          </p>
        </div>
        
        <div className="flex items-center gap-2">
          {isLoading && (
            <div className="flex items-center gap-2 text-muted-foreground">
              <Clock size={16} className="animate-pulse" />
              <span className="text-sm">Updating...</span>
            </div>
          )}
        </div>
      </div>

      {lastFetch && (
        <div className="text-sm text-muted-foreground">
          Last updated: {new Date(lastFetch).toLocaleString()}
          {shouldFetchData() && !isLoading && (
            <span className="ml-2 text-primary">• Next update available</span>
          )}
        </div>
      )}

      {/* Error Alert */}
      {error && (
        <Alert className="mb-6" variant="destructive">
          <AlertTriangle size={16} />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Category Filter */}
      {updates.length > 0 && (
        <div>
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

      <Separator />

      {/* Updates List */}
      {filteredUpdates.length > 0 ? (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold">
              Recent Updates {selectedCategory !== 'All' && `- ${selectedCategory}`}
            </h3>
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
              ? "No updates found in the last 7 days. Updates are checked automatically every 12 hours."
              : "Data will be automatically fetched from the Azure AKS documentation repository every 12 hours."
            }
          </p>
          {shouldFetchData() && !isLoading && (
            <button 
              onClick={() => fetchUpdates(true)} 
              className="text-primary hover:text-primary/80 text-sm underline"
            >
              Check for updates now
            </button>
          )}
        </div>
      )}
    </div>
  );
}