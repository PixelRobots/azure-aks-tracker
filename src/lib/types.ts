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