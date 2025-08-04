import { Button } from '@/components/ui/button';
import { Moon, Sun, Monitor } from '@phosphor-icons/react';
import { useTheme } from '@/hooks/useTheme';

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  const getThemeIcon = () => {
    switch (theme) {
      case 'light':
        return <Moon size={16} />;
      case 'dark':
        return <Monitor size={16} />;
      case 'system':
        return <Sun size={16} />;
      default:
        return <Sun size={16} />;
    }
  };

  const getThemeLabel = () => {
    switch (theme) {
      case 'light':
        return 'Dark';
      case 'dark':
        return 'System';
      case 'system':
        return 'Light';
      default:
        return 'Light';
    }
  };

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={toggleTheme}
      className="flex items-center gap-2 hover:text-gray-500 dark:hover:text-gray-400"
      title={`Switch to ${getThemeLabel()} theme`}
    >
      {getThemeIcon()}
      {getThemeLabel()}
    </Button>
  );
}