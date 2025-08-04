export interface Commit {
  sha: string;
  date: string;
  author: string;
  message: string;
  files: string[];
  diff?: string;
}

export interface Update {
  partitionKey: string; // Date in YYYY-MM-DD format
  rowKey: string; // Latest commit SHA
  title: string;
  category: string;
  date: string;
  url: string;
  summary: string;
  impact: string;
  commits?: string[]; // Array of commit SHAs that contributed to this update
}

export interface GitHubCommit {
  sha: string;
  commit: {
    author: {
      name: string;
      date: string;
    };
    message: string;
  };
  files?: Array<{
    filename: string;
    status: string;
    patch?: string;
  }>;
}

// Types for AKS releases

export interface GitHubRelease {
  id: number;
  tag_name: string;
  name: string;
  body: string;
  published_at: string;
  html_url: string;
  prerelease: boolean;
  draft: boolean;
}

export interface ReleaseRegionInfo {
  regions: string[];
  cves: CVEInfo[];
  rolloutStatus?: string;
}

export interface CVEInfo {
  id: string;
  severity: string;
  description: string;
  mitigated: boolean;
}

export interface EnhancedRelease {
  id: string;
  version: string;
  title: string;
  publishedAt: string;
  htmlUrl: string;
  isPrerelease: boolean;
  
  // AI-generated content
  summary: string;
  breakingChanges: string[];
  goodToKnow: string[];
  keyFeatures: string[];
  
  // Enriched data from releases.aks.azure.com
  regions: string[];
  cves: CVEInfo[];
  rolloutStatus?: string;
  
  // Raw data
  rawBody: string;
}

export const CATEGORY_MAPPINGS: Record<string, string> = {
  'reliability-': 'Reliability',
  'localdns': 'Networking/DNS',
  'networking': 'Networking',
  'production-upgrade': 'Upgrade',
  'upgrade': 'Upgrade',
  'concepts-lifecycle': 'Fleet Manager',
  'lifecycle': 'Fleet Manager',
  'security': 'Security',
  'monitoring': 'Monitoring',
  'troubleshoot': 'Troubleshooting',
  'concepts-': 'Concepts',
  'tutorial-': 'Tutorial',
  'quickstart': 'Quickstart',
  'best-practices': 'Best Practices',
  'cluster-': 'Cluster Management',
  'node-': 'Node Management',
  'workload-': 'Workloads',
  'storage': 'Storage',
  'ingress': 'Ingress',
  'autoscal': 'Autoscaling',
  'gpu': 'GPU/Compute',
  'windows': 'Windows Containers'
};