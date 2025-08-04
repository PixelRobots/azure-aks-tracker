import { GitHubRelease, EnhancedRelease, CVEInfo } from './types';

export class ReleasesService {
  private readonly aksRepo = 'Azure/AKS';
  private readonly releasesApiUrl = 'https://releases.aks.azure.com/api';

  async getGitHubReleases(limit: number = 20): Promise<GitHubRelease[]> {
    const response = await fetch(
      `https://api.github.com/repos/${this.aksRepo}/releases?per_page=${limit}`
    );
    
    if (!response.ok) {
      throw new Error(`Failed to fetch releases: ${response.statusText}`);
    }
    
    return response.json();
  }

  async getRegionRolloutData(version: string): Promise<{ regions: string[]; cves: CVEInfo[]; rolloutStatus?: string }> {
    try {
      // Try to fetch from releases.aks.azure.com API
      // Note: This might need to be adjusted based on the actual API structure
      const response = await fetch(`${this.releasesApiUrl}/releases/${version}`);
      
      if (!response.ok) {
        console.warn(`Failed to fetch region data for ${version}: ${response.statusText}`);
        return { regions: [], cves: [] };
      }
      
      const data = await response.json();
      
      return {
        regions: data.regions || [],
        cves: data.cves?.map((cve: any) => ({
          id: cve.id || cve.cve_id,
          severity: cve.severity || 'Unknown',
          description: cve.description || '',
          mitigated: cve.mitigated || false
        })) || [],
        rolloutStatus: data.rolloutStatus || data.status
      };
    } catch (error) {
      console.warn(`Failed to fetch region data for ${version}:`, error);
      return { regions: [], cves: [] };
    }
  }

  async enhanceReleaseWithAI(release: GitHubRelease): Promise<EnhancedRelease> {
    const baseRelease: EnhancedRelease = {
      id: release.id.toString(),
      version: release.tag_name,
      title: release.name || release.tag_name,
      publishedAt: release.published_at,
      htmlUrl: release.html_url,
      isPrerelease: release.prerelease,
      summary: '',
      breakingChanges: [],
      goodToKnow: [],
      keyFeatures: [],
      regions: [],
      cves: [],
      rawBody: release.body
    };

    try {
      // Use AI to analyze the release notes
      const prompt = spark.llmPrompt`
      Analyze these AKS release notes and extract key information:

      Release: ${release.tag_name}
      Title: ${release.name}
      Body: ${release.body}

      Please respond with JSON in this exact format:
      {
        "summary": "2-3 sentence overview of this release",
        "breakingChanges": ["list of breaking changes", "each as separate string"],
        "goodToKnow": ["important things users should know", "each as separate string"],
        "keyFeatures": ["new features and improvements", "each as separate string"]
      }

      Focus on:
      - Breaking changes (API changes, deprecated features, migration requirements)
      - Good to know items (important notes, recommendations, caveats)
      - Key features (new functionality, major improvements, bug fixes)
      `;

      const analysis = await spark.llm(prompt, 'gpt-4o-mini', true);
      const parsed = JSON.parse(analysis);

      if (parsed.summary) baseRelease.summary = parsed.summary;
      if (Array.isArray(parsed.breakingChanges)) baseRelease.breakingChanges = parsed.breakingChanges;
      if (Array.isArray(parsed.goodToKnow)) baseRelease.goodToKnow = parsed.goodToKnow;
      if (Array.isArray(parsed.keyFeatures)) baseRelease.keyFeatures = parsed.keyFeatures;

    } catch (error) {
      console.warn('Failed to enhance release with AI:', error);
      baseRelease.summary = 'Release notes analysis unavailable';
    }

    // Fetch region and CVE data
    try {
      const regionData = await this.getRegionRolloutData(release.tag_name);
      baseRelease.regions = regionData.regions;
      baseRelease.cves = regionData.cves;
      baseRelease.rolloutStatus = regionData.rolloutStatus;
    } catch (error) {
      console.warn('Failed to fetch region data:', error);
    }

    return baseRelease;
  }

  async getEnhancedReleases(limit: number = 10): Promise<EnhancedRelease[]> {
    const releases = await this.getGitHubReleases(limit);
    
    // Filter out draft releases and enhance with AI
    const publicReleases = releases.filter(r => !r.draft);
    
    const enhancedReleases: EnhancedRelease[] = [];
    
    for (const release of publicReleases) {
      try {
        const enhanced = await this.enhanceReleaseWithAI(release);
        enhancedReleases.push(enhanced);
      } catch (error) {
        console.warn(`Failed to enhance release ${release.tag_name}:`, error);
      }
    }
    
    return enhancedReleases;
  }
}