import { useState } from 'react';
import { useKV } from '@github/spark/hooks';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { ReleaseCard } from '@/components/ReleaseCard';
import { EnhancedRelease } from '@/lib/types';
import { ReleasesService } from '@/lib/releases';
import { RefreshCw, Rocket, AlertTriangle, Trash2, Bug } from '@phosphor-icons/react';
import { toast } from 'sonner';

export function ReleasesPage() {
  const [releases, setReleases] = useKV<EnhancedRelease[]>('aks-releases', []);
  const [isLoading, setIsLoading] = useState(false);
  const [lastFetch, setLastFetch] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [debugInfo, setDebugInfo] = useState<string>('');

  const releasesService = new ReleasesService();

  const fetchReleases = async () => {
    setIsLoading(true);
    setError(null);
    setDebugInfo('Starting fetch...');

    try {
      console.log('Starting to fetch releases...');
      const enhancedReleases = await releasesService.getEnhancedReleases(10);
      console.log('Fetch completed, releases:', enhancedReleases);
      
      setDebugInfo(`Fetched ${enhancedReleases.length} releases successfully`);
      
      if (enhancedReleases.length === 0) {
        toast.info('No releases found');
        setLastFetch(new Date().toISOString());
        return;
      }

      // Merge with existing releases, avoiding duplicates
      const existingIds = new Set(releases.map(r => r.id));
      const newReleases = enhancedReleases.filter(r => !existingIds.has(r.id));
      
      if (newReleases.length > 0 || releases.length === 0) {
        const allReleases = [...newReleases, ...releases]
          .sort((a, b) => new Date(b.publishedAt).getTime() - new Date(a.publishedAt).getTime())
          .slice(0, 50); // Keep last 50 releases
        
        setReleases(allReleases);
        
        if (newReleases.length > 0) {
          toast.success(`Found ${newReleases.length} new release${newReleases.length !== 1 ? 's' : ''}`);
        }
      } else {
        toast.info('No new releases found');
      }
      
      setLastFetch(new Date().toISOString());
      
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      console.error('Fetch failed:', error);
      setError(errorMessage);
      setDebugInfo(`Error: ${errorMessage}`);
      toast.error(`Failed to fetch releases: ${errorMessage}`);
    } finally {
      setIsLoading(false);
    }
  };

  const clearData = () => {
    setReleases([]);
    setDebugInfo('Data cleared');
    toast.success('All release data cleared');
  };

  // Test GitHub API directly
  const testGitHubAPI = async () => {
    setIsLoading(true);
    setDebugInfo('Testing GitHub API...');
    
    try {
      const response = await fetch('https://api.github.com/repos/Azure/AKS/releases?per_page=5');
      console.log('Test response:', response.status, response.statusText);
      
      if (!response.ok) {
        throw new Error(`API returned ${response.status}: ${response.statusText}`);
      }
      
      const data = await response.json();
      console.log('Test data:', data);
      setDebugInfo(`GitHub API working: Found ${data.length} releases. Latest: ${data[0]?.tag_name || 'none'}`);
      toast.success('GitHub API test successful!');
      
    } catch (error) {
      console.error('API test failed:', error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      setDebugInfo(`GitHub API test failed: ${errorMessage}`);
      toast.error(`API test failed: ${errorMessage}`);
    } finally {
      setIsLoading(false);
    }
  };

  // Statistics
  const totalCVEs = releases.reduce((acc, release) => acc + release.cves.length, 0);
  const totalRegions = new Set(releases.flatMap(r => r.regions)).size;
  const prereleases = releases.filter(r => r.isPrerelease).length;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-foreground mb-2">
            AKS Releases
          </h2>
          <p className="text-muted-foreground">
            Latest AKS releases with AI-generated summaries, breaking changes, and regional rollout information.
          </p>
        </div>
        
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={testGitHubAPI}
            disabled={isLoading}
            className="flex items-center gap-2"
          >
            <Bug size={14} />
            Test API
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={clearData}
            className="flex items-center gap-2"
          >
            <Trash2 size={14} />
            Clear Data
          </Button>
          <Button
            onClick={fetchReleases}
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

      {/* Debug Info */}
      {debugInfo && (
        <Alert>
          <AlertTriangle size={16} />
          <AlertDescription>
            Debug: {debugInfo}
          </AlertDescription>
        </Alert>
      )}

      {/* Error Alert */}
      {error && (
        <Alert variant="destructive">
          <AlertTriangle size={16} />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Statistics */}
      {releases.length > 0 && (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="text-center p-4 rounded-lg border bg-card">
            <div className="text-2xl font-bold text-primary">{releases.length}</div>
            <div className="text-sm text-muted-foreground">Total Releases</div>
          </div>
          <div className="text-center p-4 rounded-lg border bg-card">
            <div className="text-2xl font-bold text-orange-600">{totalCVEs}</div>
            <div className="text-sm text-muted-foreground">CVEs Tracked</div>
          </div>
          <div className="text-center p-4 rounded-lg border bg-card">
            <div className="text-2xl font-bold text-green-600">{totalRegions}</div>
            <div className="text-sm text-muted-foreground">Regions</div>
          </div>
          <div className="text-center p-4 rounded-lg border bg-card">
            <div className="text-2xl font-bold text-blue-600">{prereleases}</div>
            <div className="text-sm text-muted-foreground">Pre-releases</div>
          </div>
        </div>
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
            Click "Refresh" to fetch the latest AKS releases from GitHub
          </p>
          <div className="flex justify-center gap-2">
            <Button onClick={testGitHubAPI} variant="outline" disabled={isLoading}>
              <Bug size={16} className={isLoading ? 'animate-spin mr-2' : 'mr-2'} />
              Test API Connection
            </Button>
            <Button onClick={fetchReleases} disabled={isLoading}>
              <RefreshCw size={16} className={isLoading ? 'animate-spin mr-2' : 'mr-2'} />
              Fetch Releases
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}