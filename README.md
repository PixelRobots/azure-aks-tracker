# Azure AKS Documentation & Release Tracker

A comprehensive tracking tool built with GitHub Spark that automatically monitors meaningful changes to the Azure Kubernetes Service (AKS) documentation and releases.

## 🚀 Features

### Documentation Updates
- **Automatic Monitoring**: Tracks commits to the [MicrosoftDocs/azure-aks-docs](https://github.com/MicrosoftDocs/azure-aks-docs) repository
- **Intelligent Filtering**: Filters out noise like typos, grammar fixes, and bot merges to show only meaningful changes
- **Smart Grouping**: Combines related commits that touch the same files or have similar messages within a 7-day window
- **AI-Enhanced Summaries**: Uses AI to generate clear summaries and impact assessments for each change
- **Category Classification**: Automatically categorizes updates (Reliability, Networking, Security, etc.)
- **Bullet Point Formatting**: Properly displays multi-point summaries and impacts with clear formatting

### AKS Releases
- **Latest Releases**: Shows the 5 most recent AKS releases from GitHub
- **AI Analysis**: Automatically extracts and categorizes:
  - Key Features
  - Breaking Changes  
  - Good to Know information
- **Release Enhancement**: Enriches release data with deployment information from releases.aks.azure.com
- **CVE Mitigation**: Highlights security-related updates and mitigated vulnerabilities

### User Experience
- **Automatic Updates**: Data refreshes every 12 hours without manual intervention
- **Dark/Light/System Theme**: Responsive theme switching with system preference detection
- **Category Filtering**: Filter documentation updates by category
- **Direct Links**: Quick access to documentation pages and GitHub releases
- **Mobile Responsive**: Works seamlessly across all device sizes

## 🛠️ Technical Implementation

- **Built with GitHub Spark**: Leverages the Spark runtime for AI integration and persistent storage
- **React + TypeScript**: Modern, type-safe frontend development
- **Tailwind CSS + shadcn/ui**: Beautiful, consistent UI components
- **AI Integration**: Uses GPT-4o-mini for content analysis and enhancement
- **Smart Caching**: Efficient data storage and retrieval with automatic cleanup
- **Rate Limit Aware**: Respects GitHub API limits with intelligent request management

## 📊 Data Processing

### Documentation Updates
1. **Fetching**: Retrieves commits from the last 7 days via GitHub API
2. **Filtering**: Removes noise commits (typos, grammar, bot merges)
3. **Grouping**: Combines related commits by file path and similarity
4. **Enhancement**: AI analyzes changes to generate meaningful summaries
5. **Storage**: Persists processed updates with smart deduplication

### Release Analysis
1. **GitHub Integration**: Fetches latest releases from azure/aks repository
2. **Content Analysis**: AI extracts key features, breaking changes, and important notes
3. **Enhancement**: Enriches with deployment status and CVE information
4. **Presentation**: Organizes information in user-friendly cards

## 🎯 Use Cases

- **AKS Administrators**: Stay informed about documentation changes affecting your clusters
- **DevOps Teams**: Track new features, breaking changes, and best practices
- **Security Teams**: Monitor CVE mitigations and security-related updates
- **Technical Writers**: Understand documentation evolution and patterns
- **Developers**: Keep up with AKS capabilities without information overload

## 🔧 Installation & Usage

This application runs entirely within GitHub Spark:

1. **Access**: Open the Spark application in your browser
2. **Automatic Loading**: Data begins loading automatically on first visit
3. **Navigation**: Use tabs to switch between Documentation Updates and AKS Releases
4. **Filtering**: Use category badges to filter documentation updates
5. **Manual Refresh**: Click "Check for updates now" if you want to force a refresh

## 📈 Benefits

- **Time Saving**: No need to manually monitor multiple documentation pages
- **Noise Reduction**: Focus on meaningful changes, not editorial fixes
- **Context Aware**: AI-generated summaries explain the impact of changes
- **Comprehensive Coverage**: Tracks both documentation and release changes
- **Always Current**: Automatic updates ensure you never miss important changes

## 📄 License

The Spark Template files and resources from GitHub are licensed under the terms of the MIT license, Copyright GitHub, Inc.

---

Built by [pixelrobots.co.uk](https://pixelrobots.co.uk) with the help of [GitHub Spark](https://github.com/features/spark)