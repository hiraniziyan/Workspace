'use client'
import * as React from 'react';
import { AppRouterCacheProvider } from '@mui/material-nextjs/v15-appRouter';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import theme from '@/theme';
import InitColorSchemeScript from '@mui/material/InitColorSchemeScript';
import ModeSwitch from '@/components/ModeSwitch';
import AppTheme from '@/shared-theme/AppTheme';
import AppAppBar from '@/components/AppAppBar';

export default function RootLayout(props: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <InitColorSchemeScript attribute="class" />
        <AppRouterCacheProvider options={{ enableCssLayer: true }}>
        <AppTheme {...props}>
          {/* CssBaseline kickstart an elegant, consistent, and simple baseline to build upon. */}
            <CssBaseline enableColorScheme />

            <AppAppBar />
           
            {props.children}
          </AppTheme>
        </AppRouterCacheProvider>
      </body>
    </html>
  );
}
