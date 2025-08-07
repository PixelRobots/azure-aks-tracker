// src/components/DocumentationPage.tsx
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

  // Compute a “since” cutoff at UTC midnight 7 days ago
  const now = new Date();
  const sinceMidnightUTC = new Date(Date.UTC(
    now.getUTCFullYear(),
    now.getUTCMonth(),
    now.getUTCDate() - 7,
    0, 0, 0, 0
  ));

  const githubService = new GitHubService(); // No token needed for public repo

  // Clean old bullet points from summary and impact
  const cleanBulletPoints = (text: string): string => {
    return text.replace(/\s*•\s*/g, '\n• ').trim();
  };

  // Check if we need to fetch data
  const shouldFetchData = () => {
    if (!lastFetch) return true;
    
    const lastFetchTime = new Date(lastFetch);
    const hoursSinceLastFetch = (now.getTime() - lastFetchTime.getTime()) / (1000 * 60 * 60);
    return hoursSinceLastFetch >= 12;
  };

  // Helper function to merge updates with the same URL
  const mergeUpdatesByUrl = (updates: Update[]): Update[] => {
    const urlGroups = new Map<string, Update[]>();
    for (const update of updates) {
      const existing = urlGroups.get(update.url) || [];
      existing.push(update);
      urlGroups.set(update.url, existing);
    }

    const mergedUpdates: Update[] = [];
    for (const [url, groupUpdates] of urlGroups) {
      if (groupUpdates.length === 1) {
        const singleUpdate = { ...groupUpdates[0] };
        singleUpdate.summary = cleanBulletPoints(singleUpdate.summary);
        singleUpdate.impact = cleanBulletPoints(singleUpdate.impact);
        mergedUpdates.push(singleUpdate);
      } else {
        const sortedByDate = groupUpdates.sort(
          (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
        );
        const earliest = sortedByDate[0];
        const latest = sortedByDate[sortedByDate.length - 1];
        const uniqueSummaries = Array.from(new Set(groupUpdates.map(u => u.summary.trim())));
        const uniqueImpacts   = Array.from(new Set(groupUpdates.map(u => u.impact.trim())));

        const mergedUpdate: Update = {
          ...earliest,
          rowKey: `merged-${latest.rowKey}`,
          title: `${earliest.title.replace(/ \(\d+ updates?\)$/, '')} (${groupUpdates.length} updates)`,
          summary: cleanBulletPoints(
            uniqueSummaries.length > 1 ? uniqueSummaries.join('\n• ') : uniqueSummaries[0]
          ),
          impact: cleanBulletPoints(
            uniqueImpacts.length > 1 ? uniqueImpacts.join('\n• ') : uniqueImpacts[0]
          ),
          commits: Array.from(new Set(groupUpdates.flatMap(u => u.commits || []))),
          date: latest.date
        };
        mergedUpdates.push(mergedUpdate);
      }
    }

    return mergedUpdates.sort(
      (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime()
    );
  };

  // Filter updates to only show those from our UTC-midnight cutoff
  const recentUpdates = updates.filter(update => {
    const updateDate = new Date(update.date);
    return updateDate >= sinceMidnightUTC;
  });

  const mergedUpdates   = mergeUpdatesByUrl(recentUpdates);
  const categories      = ['All', ...Array.from(new Set(mergedUpdates.map(u => u.category))).sort()];
  const filteredUpdates = selectedCategory === 'All'
    ? mergedUpdates
    : mergedUpdates.filter(u => u.category === selectedCategory);

  const fetchUpdates = async (showToasts = true) => {
    setIsLoading(true);
    setError(null);

    try {
      // Fetch commits from an inclusive 7-day window (midnight UTC)
      const commits = await githubService.getRecentCommits(sinceMidnightUTC.toISOString());

      if (commits.length === 0) {
        if (showToasts) toast.info('No recent commits found');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Filter out noise commits
      const meaningfulCommits = commits.filter(c => !isNoiseCommit(c));
      if (meaningfulCommits.length === 0) {
        if (showToasts) toast.info('No meaningful changes found in recent commits');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Group related commits, but only keep groups with any commit in our window
      const allGroups    = groupCommitsByRelatedness(meaningfulCommits);
      const commitGroups = allGroups.filter(group =>
        group.some(c => new Date(c.date) >= sinceMidnightUTC)
      );

      const newUpdates: Update[] = [];
      for (const group of commitGroups) {
        try {
          const update = createUpdateFromCommits(group);

          // AI enhancement (skip trivial-only commits)
          try {
            const prompt = `
Exclude any commit that only corrects spelling, punctuation, code formatting, broken links, or other trivial style issues.

Analyze the following Azure AKS documentation commits by focusing on content changes inside the files, not commit messages or code diffs.

Scoring priority for your analysis (highest to lowest importance):
1. Substantive content changes (new topics, new sections, expanded explanations, new features covered)
2. New or updated examples, code snippets, or diagrams that improve understanding
3. Reorganization or restructuring of sections for clarity
4. Formatting or style-only changes (mention only if no other substantive changes are present)

Commits:
${group.map(c => `- ${c.message} (files: ${c.files.join(', ')})`).join('\n')}
`;
            const analysis = await spark.llm(prompt, 'gpt-4o-mini', true);
            const parsed   = JSON.parse(analysis);
            if (parsed.summary && parsed.impact) {
              update.summary = parsed.summary;
              update.impact  = parsed.impact;
            }
          } catch { /* ignore AI failures */ }

          newUpdates.push(update);
        } catch { /* ignore grouping failures */ }
      }

      // Merge with existing updates, avoiding duplicates and filtering old data
      const recentExistingUpdates = updates.filter(update => {
        const updateDate = new Date(update.date);
        return updateDate >= sinceMidnightUTC;
      });

      const existingKeys    = new Set(recentExistingUpdates.map(u => u.rowKey));
      const uniqueNewUpdates = newUpdates.filter(u => !existingKeys.has(u.rowKey));

      if (uniqueNewUpdates.length > 0 || recentExistingUpdates.length !== updates.length) {
        const allUpdates = [...uniqueNewUpdates, ...recentExistingUpdates]
          .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
          .slice(0, 100);

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
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Unknown error occurred';
      setError(msg);
      if (showToasts) toast.error(`Failed to fetch updates: ${msg}`);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (shouldFetchData()) {
      fetchUpdates(false);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
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
            {filteredUpdates.map(update => (
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
