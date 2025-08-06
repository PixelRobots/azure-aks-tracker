import { Commit, GitHubCommit } from './types';

const GITHUB_API_BASE = 'https://api.github.com';
const REPO_OWNER = 'MicrosoftDocs';
const REPO_NAME = 'azure-aks-docs';

export class GitHubService {
  private token: string | null = null;

  constructor(token?: string) {
    this.token = token || null;
  }

  private async makeRequest(endpoint: string): Promise<any> {
    const headers: Record<string, string> = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'AKS-Docs-Tracker'
    };

    if (this.token) {
      headers['Authorization'] = `token ${this.token}`;
    }

    const response = await fetch(`${GITHUB_API_BASE}${endpoint}`, { headers });
    
    if (!response.ok) {
      // Provide more specific error messages for common issues
      if (response.status === 403) {
        const remaining = response.headers.get('x-ratelimit-remaining');
        const resetTime = response.headers.get('x-ratelimit-reset');
        
        if (remaining === '0') {
          const resetDate = resetTime ? new Date(parseInt(resetTime) * 1000) : new Date();
          throw new Error(`GitHub API rate limit exceeded. Resets at ${resetDate.toLocaleTimeString()}.`);
        } else {
          throw new Error(`GitHub API access forbidden (403). This may be due to rate limiting or repository access restrictions.`);
        }
      }
      
      throw new Error(`GitHub API error: ${response.status} ${response.statusText}`);
    }

    return response.json();
  }

  async getRecentCommits(since?: string, perPage = 15): Promise<Commit[]> {
    try {
      let endpoint = `/repos/${REPO_OWNER}/${REPO_NAME}/commits?per_page=${perPage}`;
      
      if (since) {
        endpoint += `&since=${since}`;
      }

      const commits: GitHubCommit[] = await this.makeRequest(endpoint);
      const processedCommits: Commit[] = [];

      // Process fewer commits to reduce API calls
      const limitedCommits = commits.slice(0, Math.min(commits.length, 10));

      for (const commit of limitedCommits) {
        try {
          // Add a small delay between requests to be respectful to the API
          await new Promise(resolve => setTimeout(resolve, 100));
          
          // Get detailed commit info including files
          const detailedCommit = await this.makeRequest(`/repos/${REPO_OWNER}/${REPO_NAME}/commits/${commit.sha}`);
          
          const files = detailedCommit.files?.map((file: any) => file.filename) || [];
          
          // Filter to only include markdown files in articles/aks directory
          const relevantFiles = files.filter((file: string) => 
            file.startsWith('articles/aks/') && file.endsWith('.md')
          );

          if (relevantFiles.length > 0) {
            processedCommits.push({
              sha: commit.sha,
              date: commit.commit.author.date,
              author: commit.commit.author.name,
              message: commit.commit.message,
              files: relevantFiles,
              diff: this.extractRelevantDiff(detailedCommit.files)
            });
          }
        } catch (error) {
          console.warn(`Failed to process commit ${commit.sha}:`, error);
          // Don't break the loop, just skip this commit
        }
      }

      return processedCommits;
    } catch (error) {
      console.error('Failed to fetch commits:', error);
      throw error;
    }
  }

  private extractRelevantDiff(files: any[]): string {
    if (!files) return '';
    
    // Extract a summary of changes from the diff
    const changes = files
      .filter(file => file.filename.startsWith('articles/aks/') && file.filename.endsWith('.md'))
      .map(file => {
        const additions = file.additions || 0;
        const deletions = file.deletions || 0;
        return `${file.filename}: +${additions} -${deletions}`;
      })
      .join(', ');

    return changes;
  }

  async getFileContent(path: string, ref?: string): Promise<string> {
    try {
      let endpoint = `/repos/${REPO_OWNER}/${REPO_NAME}/contents/${path}`;
      if (ref) {
        endpoint += `?ref=${ref}`;
      }

      const response = await this.makeRequest(endpoint);
      
      if (response.content) {
        return atob(response.content);
      }
      
      return '';
    } catch (error) {
      console.warn(`Failed to get file content for ${path}:`, error);
      return '';
    }
  }

  setToken(token: string) {
    this.token = token;
  }

  hasToken(): boolean {
    return this.token !== null;
  }
}