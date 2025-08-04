import { Button } from '@/components/ui/button';
import { Moon, Sun } from '@phosphor-icons/react';
import { useTheme } from '@/hooks/useTheme';

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={toggleTheme}
      className="flex items-center gap-2"
    >
      {theme === 'light' ? (
        <>
          <Moon size={16} />
          Dark
        </>
      ) : (
        <>
          <Sun size={16} />
          Light
        </>
      )}
    </Button>
  );
}