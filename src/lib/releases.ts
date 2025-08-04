import { GitHubRelease, EnhancedRelease, CVEInfo } from './types';

export class ReleasesService {
  private readonly aksRepo = 'Azure/AKS';
  private readonly releasesApiUrl = 'https://releases.aks.azure.com/api';

  async getGitHubReleases(limit: number = 20): Promise<GitHubRelease[]> {
    const url = `https://api.github.com/repos/${this.aksRepo}/releases?per_page=${limit}`;
    console.log('Fetching releases from:', url);
    
    try {
      const response = await fetch(url);
      console.log('Response status:', response.status, response.statusText);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('Error response:', errorText);
        throw new Error(`Failed to fetch releases: ${response.status} ${response.statusText}`);
      }
      
      const data = await response.json();
      console.log('Fetched releases:', data.length);
      return data;
    } catch (error) {
      console.error('Fetch error:', error);
      throw error;
    }
  }

  async getRegionRolloutData(version: string): Promise<{ regions: string[]; cves: CVEInfo[]; rolloutStatus?: string }> {
    try {
      // Try to fetch from releases.aks.azure.com API
      const url = `${this.releasesApiUrl}/releases/${version}`;
      console.log(`Fetching region data from: ${url}`);
      
      const response = await fetch(url, {
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'AKS-Documentation-Tracker'
        }
      });
      
      if (!response.ok) {
        console.warn(`Failed to fetch region data for ${version}: ${response.status} ${response.statusText}`);
        return { regions: [], cves: [] };
      }
      
      const data = await response.json();
      console.log(`Region data for ${version}:`, data);
      
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
      rawBody: release.body || ''
    };

    // Only use AI if we have meaningful content
    if (release.body && release.body.trim().length > 50) {
      try {
        console.log(`Analyzing release ${release.tag_name} with AI...`);
        
        // Use AI to analyze the release notes
        const prompt = spark.llmPrompt`
        Analyze these AKS release notes and extract key information:

        Release: ${release.tag_name}
        Title: ${release.name || ''}
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
        
        If there are no items for a category, use an empty array.
        `;

        const analysis = await spark.llm(prompt, 'gpt-4o-mini', true);
        const parsed = JSON.parse(analysis);

        if (parsed.summary && typeof parsed.summary === 'string') {
          baseRelease.summary = parsed.summary;
        }
        if (Array.isArray(parsed.breakingChanges)) {
          baseRelease.breakingChanges = parsed.breakingChanges.filter(item => typeof item === 'string');
        }
        if (Array.isArray(parsed.goodToKnow)) {
          baseRelease.goodToKnow = parsed.goodToKnow.filter(item => typeof item === 'string');
        }
        if (Array.isArray(parsed.keyFeatures)) {
          baseRelease.keyFeatures = parsed.keyFeatures.filter(item => typeof item === 'string');
        }

        console.log(`Successfully analyzed release ${release.tag_name}`);

      } catch (error) {
        console.warn(`Failed to enhance release ${release.tag_name} with AI:`, error);
        baseRelease.summary = `Release ${release.tag_name} - See raw notes below for details`;
      }
    } else {
      baseRelease.summary = `Release ${release.tag_name} - No detailed notes available`;
    }

    // Try to fetch region and CVE data (this might fail for external API)
    try {
      const regionData = await this.getRegionRolloutData(release.tag_name);
      baseRelease.regions = regionData.regions;
      baseRelease.cves = regionData.cves;
      baseRelease.rolloutStatus = regionData.rolloutStatus;
    } catch (error) {
      console.warn(`Failed to fetch region data for ${release.tag_name}:`, error);
      // Keep empty arrays as defaults
    }

    return baseRelease;
  }

  async getEnhancedReleases(limit: number = 10): Promise<EnhancedRelease[]> {
    console.log(`Fetching ${limit} enhanced releases...`);
    
    try {
      const releases = await this.getGitHubReleases(limit);
      console.log(`Found ${releases.length} total releases from GitHub`);
      
      // Filter out draft releases
      const publicReleases = releases.filter(r => !r.draft);
      console.log(`${publicReleases.length} public releases after filtering drafts`);
      
      if (publicReleases.length === 0) {
        console.warn('No public releases found');
        return [];
      }
      
      const enhancedReleases: EnhancedRelease[] = [];
      
      for (const release of publicReleases) {
        try {
          console.log(`Enhancing release: ${release.tag_name}`);
          const enhanced = await this.enhanceReleaseWithAI(release);
          enhancedReleases.push(enhanced);
        } catch (error) {
          console.warn(`Failed to enhance release ${release.tag_name}:`, error);
          
          // Create a basic enhanced release without AI analysis
          const basicRelease: EnhancedRelease = {
            id: release.id.toString(),
            version: release.tag_name,
            title: release.name || release.tag_name,
            publishedAt: release.published_at,
            htmlUrl: release.html_url,
            isPrerelease: release.prerelease,
            summary: 'Analysis pending - check raw notes below',
            breakingChanges: [],
            goodToKnow: [],
            keyFeatures: [],
            regions: [],
            cves: [],
            rawBody: release.body
          };
          
          enhancedReleases.push(basicRelease);
        }
      }
      
      console.log(`Successfully enhanced ${enhancedReleases.length} releases`);
      return enhancedReleases;
      
    } catch (error) {
      console.error('Failed to fetch releases:', error);
      throw new Error(`Failed to fetch AKS releases: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }
}