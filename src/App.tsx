import { Alert, AlertDescription } from '@/components/ui/alert';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { DocumentationPage } from '@/components/DocumentationPage';
import { ReleasesPage } from '@/components/ReleasesPage';
import { ThemeToggle } from '@/components/ThemeToggle';
import { Warning } from '@phosphor-icons/react';
import { Toaster } from '@/components/ui/sonner';
import { useTheme } from '@/hooks/useTheme';

function App() {
  // Initialize theme
  useTheme();
  return (
    <div className="min-h-screen bg-background">
      <Toaster position="top-right" />
      
      <div className="container mx-auto px-4 py-8 max-w-6xl">
        {/* Header */}
        <div className="mb-8">
          <div className="flex items-start justify-between mb-4">
            <div>
              <h1 className="text-3xl font-bold text-foreground mb-2">
                Azure AKS Documentation Tracker
              </h1>
              <p className="text-muted-foreground leading-relaxed">
                Welcome! This tool automatically tracks and summarizes meaningful updates to the Azure Kubernetes Service (AKS) documentation and releases. <br /><br />
                It filters out typos, minor edits, and bot changes, so you only see what really matters. <br />
                Check back often or hit "Refresh" to explore what's new.
              </p>
              <p className="text-sm text-muted-foreground mt-2 italic">
                <br />Powered by GitHub Spark and GitHub Copilot — built to keep your AKS knowledge up to date with less noise.
              </p>
            </div>
            <div className="ml-4 flex-shrink-0">
              <ThemeToggle />
            </div>
          </div>
        </div>

        {/* Warning Alert */}
        <div
          className="mb-6 bg-amber-100 dark:bg-amber-900/20 border-t-4 border-amber-500 dark:border-amber-400 rounded-b text-black dark:text-amber-200 px-4 py-3 shadow-md"
          role="alert"
        >
          <div className="flex">
            <div className="py-1">
              <Warning size={24} className="text-amber-500 dark:text-amber-400 mr-4" />
            </div>
            <div>
              <p className="font-bold">Alpha Version Notice</p>
              <p className="text-sm [&_strong]:text-inherit [&_em]:text-inherit">
                This app is built with <strong>GitHub Spark</strong> and is currently in <em>alpha</em>. 
                Expect occasional changes or interruptions as it evolves.
              </p>
            </div>
          </div>
        </div>


        {/* Tabs */}
        <Tabs defaultValue="documentation" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="documentation">Documentation Updates</TabsTrigger>
            <TabsTrigger value="releases">AKS Releases</TabsTrigger>
          </TabsList>
          
          <TabsContent value="documentation" className="mt-6">
            <DocumentationPage />
          </TabsContent>
          
          <TabsContent value="releases" className="mt-6">
            <ReleasesPage />
          </TabsContent>
        </Tabs>
      </div>
      
      {/* Footer */}
      <footer className="mt-16 border-t bg-muted/30">
        <div className="container mx-auto px-4 py-6 max-w-6xl">
          <div className="text-center text-sm text-muted-foreground">
            Built by{' '}
            <a 
              href="https://pixelrobots.co.uk" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-primary hover:text-primary/80 transition-colors font-medium"
            >
              pixelrobots.co.uk
            </a>
            {' '}with the help of{' '}
            <a 
              href="https://github.com/features/spark" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-primary hover:text-primary/80 transition-colors font-medium"
            >
              GitHub Spark
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;