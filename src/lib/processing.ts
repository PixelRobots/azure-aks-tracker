import { Commit, Update, GitHubCommit, CATEGORY_MAPPINGS } from './types';

const NOISE_KEYWORDS = [
  'typo', 'grammar', 'link fix', 'acrolinx', 'final fix',
  'fixing typo', 'fix typo', 'grammar fix', 'minor fix',
  'formatting', 'format fix', 'spell check', 'spellcheck'
];

const BOT_AUTHORS = [
  'learn-build-service-prod',
  'prmerger-automator',
  'github-actions',
  'dependabot'
];

export function isNoiseCommit(commit: Commit): boolean {
  const message = commit.message.toLowerCase();
  const author = commit.author.toLowerCase();
  
  // Check for merge commits
  if (message.startsWith('merge pull request')) {
    return true;
  }
  
  // Check for bot authors
  if (BOT_AUTHORS.some(bot => author.includes(bot))) {
    return true;
  }
  
  // Check for noise keywords
  if (NOISE_KEYWORDS.some(keyword => message.includes(keyword))) {
    return true;
  }
  
  return false;
}

export function extractCategory(filePath: string): string {
  const fileName = filePath.toLowerCase();
  
  for (const [pattern, category] of Object.entries(CATEGORY_MAPPINGS)) {
    if (fileName.includes(pattern)) {
      return category;
    }
  }
  
  // Fallback categorization based on path structure
  if (fileName.includes('/concepts/')) return 'Concepts';
  if (fileName.includes('/tutorial/')) return 'Tutorial';
  if (fileName.includes('/how-to/')) return 'How-to Guide';
  if (fileName.includes('/reference/')) return 'Reference';
  
  return 'General';
}

export function generateDocsUrl(filePath: string): string {
  // Convert GitHub path to docs.microsoft.com URL
  // articles/aks/localdns-custom.md -> https://learn.microsoft.com/azure/aks/localdns-custom
  const path = filePath
    .replace('articles/aks/', '')
    .replace('.md', '')
    .replace(/\//g, '/');
    
  return `https://learn.microsoft.com/azure/aks/${path}`;
}

export function extractTitle(content: string): string {
  // Extract first H1 heading from markdown content
  const h1Match = content.match(/^#\s+(.+)$/m);
  if (h1Match) {
    return h1Match[1].trim();
  }
  
  // Fallback to title metadata
  const titleMatch = content.match(/title:\s*['"](.+)['"]$/m);
  if (titleMatch) {
    return titleMatch[1].trim();
  }
  
  return 'Documentation Update';
}

export function groupCommitsByRelatedness(commits: Commit[]): Commit[][] {
  const groups: Commit[][] = [];
  
  // Sort commits by date to ensure we process them in chronological order
  const sortedCommits = commits.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  
  for (const commit of sortedCommits) {
    // Find existing group that affects the same document(s)
    const existingGroup = groups.find(group => {
      // Check if any files in this commit match any files in the existing group
      const hasSharedDocument = commit.files.some(commitFile => 
        group.some(groupCommit => 
          groupCommit.files.some(groupFile => {
            // Same exact file path - this is the primary matching criteria
            if (commitFile === groupFile) {
              return true;
            }
            
            // Files that would generate the same documentation URL
            const commitUrl = generateDocsUrl(commitFile);
            const groupUrl = generateDocsUrl(groupFile);
            return commitUrl === groupUrl;
          })
        )
      );
      
      // Additional check: if commits are within the same timeframe and have similar patterns
      if (hasSharedDocument) {
        return true;
      }
      
      // Check for commits within the same day affecting related files
      const commitDate = new Date(commit.date).toDateString();
      const groupDate = new Date(group[0].date).toDateString();
      
      if (commitDate === groupDate) {
        // Check if commit messages suggest they're related to the same change
        const commitMessage = commit.message.toLowerCase();
        const groupMessages = group.map(c => c.message.toLowerCase());
        
        // Look for similar patterns in commit messages
        const hasRelatedMessage = groupMessages.some(groupMessage => {
          const commitWords = commitMessage.split(/\s+/);
          const groupWords = groupMessage.split(/\s+/);
          const commonWords = commitWords.filter(word => 
            word.length > 3 && groupWords.includes(word)
          );
          return commonWords.length >= 2; // At least 2 common meaningful words
        });
        
        if (hasRelatedMessage && commit.files.length > 0 && group[0].files.length > 0) {
          // Check if files are in the same directory or related
          const commitDir = commit.files[0].split('/').slice(0, -1).join('/');
          const groupDir = group[0].files[0].split('/').slice(0, -1).join('/');
          return commitDir === groupDir;
        }
      }
      
      return false;
    });
    
    if (existingGroup) {
      existingGroup.push(commit);
    } else {
      groups.push([commit]);
    }
  }
  
  return groups;
}

export async function generateSummaryAndImpact(commits: Commit[]): Promise<{ summary: string; impact: string }> {
  // For now, generate based on commit messages and files
  // In a real implementation, this would use the LLM API to analyze the diffs
  
  const mainCommit = commits[0];
  const allFiles = Array.from(new Set(commits.flatMap(c => c.files)));
  const categories = Array.from(new Set(allFiles.map(extractCategory)));
  
  let summary = `Updated documentation for ${categories.join(', ').toLowerCase()}`;
  let impact = 'Improved documentation clarity and accuracy';
  
  // Analyze commit messages for specific changes
  const messages = commits.map(c => c.message.toLowerCase()).join(' ');
  
  if (messages.includes('prerequisite') || messages.includes('requirement')) {
    summary += ' with updated prerequisites and requirements';
    impact = 'Users should review updated requirements before implementation';
  } else if (messages.includes('example') || messages.includes('sample')) {
    summary += ' including new examples and code samples';
    impact = 'Enhanced guidance with practical examples for easier implementation';
  } else if (messages.includes('deprecat') || messages.includes('remov')) {
    summary += ' noting deprecated features and migration guidance';
    impact = 'Critical update - users should plan migration from deprecated features';
  } else if (messages.includes('new feature') || messages.includes('support')) {
    summary += ' covering new features and capabilities';
    impact = 'New functionality available for AKS users to leverage';
  }
  
  return { summary, impact };
}

export function createUpdateFromCommits(commits: Commit[]): Update {
  const sortedCommits = commits.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  const earliestCommit = sortedCommits[0];
  const latestCommit = sortedCommits[sortedCommits.length - 1];
  
  const partitionKey = earliestCommit.date.split('T')[0];
  const rowKey = latestCommit.sha;
  
  const allFiles = Array.from(new Set(commits.flatMap(c => c.files)));
  const primaryFile = allFiles.find(f => f.endsWith('.md')) || allFiles[0];
  const category = extractCategory(primaryFile);
  const url = generateDocsUrl(primaryFile);
  
  // Generate a better title based on the number of commits and category
  let title: string;
  if (commits.length > 1) {
    title = `${category} Documentation Update`;
  } else {
    // For single commits, try to extract more specific information
    const commitMessage = commits[0].message;
    if (commitMessage.length > 50) {
      title = `${category}: ${commitMessage.substring(0, 50)}...`;
    } else {
      title = `${category}: ${commitMessage}`;
    }
  }
  
  return {
    partitionKey,
    rowKey,
    title,
    category,
    date: earliestCommit.date,
    url,
    summary: 'Documentation updated with latest changes',
    impact: 'Improved guidance and accuracy for AKS users',
    commits: commits.map(c => c.sha)
  };
}