# Azure AKS Documentation & Release Tracker

Welcome to the Azure AKS Tracker by PixelRobots! 🚀

This web app helps you stay up to date with meaningful changes to Azure Kubernetes Service (AKS) documentation and releases. It automatically fetches, filters, and summarizes updates from official Microsoft GitHub repositories—so you only see what matters.

---

## What Does It Do?

- **Tracks AKS Documentation Updates:**  
  Fetches recent commits from the [MicrosoftDocs/azure-aks-docs](https://github.com/MicrosoftDocs/azure-aks-docs) repo, filters out noise (typos, bot merges, trivial edits), and groups related changes by documentation page.
- **Monitors AKS Releases:**  
  Pulls the latest release data from the [Azure/AKS](https://github.com/Azure/AKS) repo, including security (CVE) and regional rollout info.
- **AI-Enhanced Summaries:**  
  Uses AI to generate concise summaries and impact assessments for each documentation update and release.
- **Category-Based Filtering:**  
  Organizes updates by category (e.g., Reliability, Networking, Upgrade) for easy browsing.
- **Tab-Based Navigation:**  
  Switch between Documentation Updates and AKS Releases with a single click.
- **Persistent Storage:**  
  Caches processed updates and releases for fast reloads and offline access.

---

## How It Works

- **Data Fetching:**  
  Uses public GitHub APIs (no login required) to fetch commits and releases.
- **Noise Filtering:**  
  Applies heuristics to exclude trivial commits (e.g., typos, grammar, bot changes).
- **Commit Grouping:**  
  Groups related commits by documentation page for a cleaner update list.
- **AI Summarization:**  
  Calls an LLM to generate human-friendly summaries and impact notes for each update.
- **Categorization:**  
  Classifies updates/releases by topic using file paths and content.
- **UI Components:**  
  - **Update Cards:** Show summary, impact, category, and links.
  - **Badges:** Indicate update categories.
  - **Tabs:** Switch between Documentation and Releases.
  - **Refresh Button:** Manually fetch the latest data.
  - **Alerts/Toasts:** Show errors, loading, and status messages.

---

## Code Structure

- `src/components/` — UI components (pages, cards, toggles, etc.)
- `src/hooks/` — Custom React hooks (theme, mobile)
- `src/lib/` — GitHub API logic, data processing, types, and utilities
- `src/styles/` — Theme and global styles
- `packages/spark-tools/` — Shared tools and utilities

---

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/PixelRobots/azure-aks-tracker.git
   cd azure-aks-tracker
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

4. Open your browser at `http://localhost:5173`

---

## Usage

- View your AKS clusters and their status.
- Track release notes and updates.
- Customize the dashboard to fit your workflow.

---

## Contributing

Contributions are welcome! Please fork the repo and submit a pull request. For major changes, open an issue to discuss your ideas.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

*Created with ❤️ by PixelRobots*

---

Built by [pixelrobots.co.uk](https://pixelrobots.co.uk) with the help of [GitHub Spark](https://github.com/features/spark)