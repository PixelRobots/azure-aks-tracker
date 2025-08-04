import { useKV } from '@github/spark/hooks';
import { useEffect, useState } from 'react';

export type Theme = 'light' | 'dark' | 'system';

function getSystemTheme(): 'light' | 'dark' {
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export function useTheme() {
  const [theme, setTheme] = useKV<Theme>('theme', 'system');
  const [systemTheme, setSystemTheme] = useState<'light' | 'dark'>(getSystemTheme);

  // Listen for system theme changes
  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = (e: MediaQueryListEvent) => {
      setSystemTheme(e.matches ? 'dark' : 'light');
    };

    mediaQuery.addEventListener('change', handleChange);
    return () => mediaQuery.removeEventListener('change', handleChange);
  }, []);

  // Apply theme to document
  useEffect(() => {
    const root = window.document.documentElement;
    const actualTheme = theme === 'system' ? systemTheme : theme;
    
    if (actualTheme === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
  }, [theme, systemTheme]);

  const toggleTheme = () => {
    setTheme(prevTheme => {
      if (prevTheme === 'system') return 'light';
      if (prevTheme === 'light') return 'dark';
      return 'system';
    });
  };

  const actualTheme = theme === 'system' ? systemTheme : theme;

  return {
    theme,
    actualTheme,
    setTheme,
    toggleTheme,
  };
}