import { useState, useEffect } from 'react';
import { useKV } from '@github/spark/hooks';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { ReleaseCard } from '@/components/ReleaseCard';
import { EnhancedRelease } from '@/lib/types';
import { ReleasesService } from '@/lib/releases';
import { Rocket, AlertTriangle, Clock } from '@phosphor-icons/react';
import { toast } from 'sonner';

export function ReleasesPage() {
  const [releases, setReleases] = useKV<EnhancedRelease[]>('aks-releases', []);
  const [lastFetch, setLastFetch] = useKV<string>('aks-releases-last-fetch', '');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const releasesService = new ReleasesService();

  // Check if we need to fetch data
  const shouldFetchData = () => {
    if (!lastFetch) return true;
    
    const lastFetchTime = new Date(lastFetch);
    const now = new Date();
    const hoursSinceLastFetch = (now.getTime() - lastFetchTime.getTime()) / (1000 * 60 * 60);
    
    // Fetch data every 12 hours
    return hoursSinceLastFetch >= 12;
  };

  const fetchReleases = async (showToasts = true) => {
    setIsLoading(true);
    setError(null);

    try {
      const enhancedReleases = await releasesService.getEnhancedReleases(5); // Only fetch 5 releases
      
      if (enhancedReleases.length === 0) {
        if (showToasts) toast.info('No releases found');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Merge with existing releases, avoiding duplicates
      const existingIds = new Set(releases.map(r => r.id));
      const newReleases = enhancedReleases.filter(r => !existingIds.has(r.id));
      
      if (newReleases.length > 0 || releases.length === 0) {
        const allReleases = [...newReleases, ...releases]
          .sort((a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime())
          .slice(0, 5); // Keep only last 5 releases
        
        setReleases(allReleases);
        
        if (showToasts && newReleases.length > 0) {
          toast.success(`Found ${newReleases.length} new release${newReleases.length !== 1 ? 's' : ''}`);
        }
      } else {
        if (showToasts) toast.info('No new releases found');
      }
      
      setLastFetch(new Date().toISOString());
      
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      setError(errorMessage);
      if (showToasts) toast.error(`Failed to fetch releases: ${errorMessage}`);
    } finally {
      setIsLoading(false);
    }
  };

  // Auto-fetch data on component mount and when needed
  useEffect(() => {
    if (shouldFetchData()) {
      fetchReleases(false); // Don't show toasts for automatic fetches
    }
  }, []);


  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-foreground mb-2">
            AKS Releases
          </h2>
          <p className="text-muted-foreground">
            Latest 5 AKS releases with AI-generated summaries, breaking changes, and Good to Know information.
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
        <Alert variant="destructive">
          <AlertTriangle size={16} />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Releases List */}
      {releases.length > 0 ? (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-semibold">Latest Releases</h3>
            <Badge variant="secondary">
              {releases.length} release{releases.length !== 1 ? 's' : ''}
            </Badge>
          </div>
          
          <div className="grid gap-6">
            {releases.map((release) => (
              <ReleaseCard key={release.id} release={release} />
            ))}
          </div>
        </div>
      ) : (
        <div className="text-center py-12">
          <Rocket size={48} className="mx-auto text-muted-foreground mb-4" />
          <h3 className="text-lg font-semibold mb-2">No Releases Found</h3>
          <p className="text-muted-foreground mb-4">
            Release data is automatically fetched from GitHub every 12 hours.
          </p>
          {shouldFetchData() && !isLoading && (
            <button 
              onClick={() => fetchReleases(true)} 
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