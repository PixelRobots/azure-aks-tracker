import { useState } from 'react';
import { useKV } from '@github/spark/hooks';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Key, Eye, EyeSlash } from '@phosphor-icons/react';
import { toast } from 'sonner';

interface SettingsProps {
  onTokenSaved?: () => void;
}

export function Settings({ onTokenSaved }: SettingsProps) {
  const [token, setToken, deleteToken] = useKV<string>('github-token', '');
  const [inputToken, setInputToken] = useState('');
  const [showToken, setShowToken] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSaveToken = async () => {
    if (!inputToken.trim()) {
      toast.error('Please enter a GitHub token');
      return;
    }

    setIsLoading(true);
    try {
      await setToken(inputToken.trim());
      setInputToken('');
      toast.success('GitHub token saved successfully');
      onTokenSaved?.();
    } catch (error) {
      toast.error('Failed to save token');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRemoveToken = async () => {
    setIsLoading(true);
    try {
      await deleteToken();
      toast.success('GitHub token removed');
      onTokenSaved?.();
    } catch (error) {
      toast.error('Failed to remove token');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Key size={20} />
          GitHub Configuration
        </CardTitle>
        <CardDescription>
          Configure your GitHub personal access token to access the Azure AKS documentation repository.
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-4">
        <Alert>
          <AlertDescription>
            To fetch commits from the MicrosoftDocs/azure-aks-docs repository, you need a GitHub personal access token.
            Create one at{' '}
            <a 
              href="https://github.com/settings/tokens" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-primary hover:underline"
            >
              github.com/settings/tokens
            </a>
            {' '}with 'public_repo' scope.
          </AlertDescription>
        </Alert>

        {token && (
          <div className="p-3 bg-muted rounded-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Key size={16} className="text-muted-foreground" />
                <span className="text-sm font-medium">Token configured</span>
              </div>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setShowToken(!showToken)}
                >
                  {showToken ? <EyeSlash size={16} /> : <Eye size={16} />}
                </Button>
                <Button
                  variant="destructive"
                  size="sm"
                  onClick={handleRemoveToken}
                  disabled={isLoading}
                >
                  Remove
                </Button>
              </div>
            </div>
            {showToken && (
              <div className="mt-2 font-mono text-xs text-muted-foreground break-all">
                {token}
              </div>
            )}
          </div>
        )}

        <div className="space-y-2">
          <Label htmlFor="github-token">
            {token ? 'Update GitHub Token' : 'GitHub Personal Access Token'}
          </Label>
          <div className="flex gap-2">
            <Input
              id="github-token"
              type="password"
              placeholder="ghp_xxxxxxxxxxxxxxxxxxxx"
              value={inputToken}
              onChange={(e) => setInputToken(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSaveToken()}
            />
            <Button 
              onClick={handleSaveToken}
              disabled={isLoading || !inputToken.trim()}
            >
              {isLoading ? 'Saving...' : 'Save'}
            </Button>
          </div>
        </div>

        <div className="text-xs text-muted-foreground">
          <p className="mb-1">Required permissions:</p>
          <ul className="list-disc list-inside space-y-1 ml-2">
            <li>public_repo (to read public repository contents)</li>
            <li>repo:status (to read commit statuses)</li>
          </ul>
        </div>
      </CardContent>
    </Card>
  );
}