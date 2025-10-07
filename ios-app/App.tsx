import React, { useCallback, useMemo, useRef, useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import {
  ActivityIndicator,
  Linking,
  Pressable,
  SafeAreaView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { WebView } from 'react-native-webview';

const START_URL = 'https://stellar-travesseiro-4619b2.netlify.app/';

export default function App() {
  const webViewRef = useRef<WebView>(null);
  const [canGoBack, setCanGoBack] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState<string | null>(null);

  const allowedHosts = useMemo(() => new Set([
    'stellar-travesseiro-4619b2.netlify.app',
    'www.stellar-travesseiro-4619b2.netlify.app',
  ]), []);

  const handleShouldStart = useCallback(async (navRequest: any) => {
    try {
      const urlString: string = navRequest?.url ?? '';
      const url = new URL(urlString);
      const scheme = url.protocol.replace(':', '');

      const isHttp = scheme === 'http' || scheme === 'https';
      const isAllowedHost = allowedHosts.has(url.hostname);

      if (!isHttp) {
        // Open non-http(s) links externally (mailto:, tel:, etc.)
        try {
          await Linking.openURL(urlString);
        } catch {
          // ignore failures to open external handlers
        }
        return false;
      }

      if (!isAllowedHost) {
        // Open external websites in the system browser
        try {
          await Linking.openURL(urlString);
        } catch {
          // ignore failures
        }
        return false;
      }

      return true;
    } catch {
      // If parsing fails, block navigation as a precaution
      return false;
    }
  }, [allowedHosts]);

  const handleNavChange = useCallback((navState: any) => {
    setCanGoBack(navState.canGoBack);
  }, []);

  const handleReload = useCallback(() => {
    setHasError(null);
    webViewRef.current?.reload();
  }, []);

  const handleGoBack = useCallback(() => {
    if (canGoBack) {
      webViewRef.current?.goBack();
    }
  }, [canGoBack]);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar style="auto" />
      <View style={styles.topBar}>
        <Pressable
          onPress={handleGoBack}
          disabled={!canGoBack}
          style={[styles.topButton, !canGoBack && styles.topButtonDisabled]}
        >
          <Text style={styles.topButtonText}>{'‹'}</Text>
        </Pressable>
        <Text style={styles.title} numberOfLines={1}>
          Web App
        </Text>
        <Pressable onPress={handleReload} style={styles.topButton}>
          <Text style={styles.topButtonText}>↻</Text>
        </Pressable>
      </View>

      <View style={styles.webContainer}>
        {hasError ? (
          <View style={styles.errorContainer}>
            <Text style={styles.errorTitle}>Something went wrong</Text>
            <Text style={styles.errorMessage}>
              {hasError || 'The page failed to load. Please try again.'}
            </Text>
            <Pressable onPress={handleReload} style={styles.retryButton}>
              <Text style={styles.retryButtonText}>Retry</Text>
            </Pressable>
          </View>
        ) : (
          <WebView
            ref={webViewRef}
            source={{ uri: START_URL }}
            onLoadStart={() => {
              setIsLoading(true);
              setHasError(null);
            }}
            onLoadEnd={() => setIsLoading(false)}
            onError={(syntheticEvent) => {
              setIsLoading(false);
              const { nativeEvent } = syntheticEvent;
              setHasError(nativeEvent?.description || 'Failed to load content.');
            }}
            onNavigationStateChange={handleNavChange}
            onShouldStartLoadWithRequest={handleShouldStart}
            allowsBackForwardNavigationGestures
            startInLoadingState={false}
            originWhitelist={["*"]}
            incognito={false}
            applicationNameForUserAgent="StellarApp/1.0"
            allowsInlineMediaPlayback
            mediaPlaybackRequiresUserAction
            contentInsetAdjustmentBehavior="always"
            setSupportMultipleWindows={false as any}
            style={styles.webView}
          />
        )}

        {isLoading && !hasError && (
          <View style={styles.loadingOverlay} pointerEvents="none">
            <ActivityIndicator size="large" color="#000" />
          </View>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#ffffff',
  },
  topBar: {
    height: 48,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#e2e2e2',
    backgroundColor: '#fafafa',
  },
  title: {
    flex: 1,
    textAlign: 'center',
    fontSize: 16,
    fontWeight: '600',
    color: '#111',
  },
  topButton: {
    width: 44,
    height: 32,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 6,
  },
  topButtonDisabled: {
    opacity: 0.4,
  },
  topButtonText: {
    fontSize: 20,
    fontWeight: '700',
    color: '#111',
  },
  webContainer: {
    flex: 1,
  },
  webView: {
    flex: 1,
    backgroundColor: '#fff',
  },
  loadingOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.5)',
  },
  errorContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 24,
  },
  errorTitle: {
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 8,
  },
  errorMessage: {
    fontSize: 14,
    color: '#444',
    textAlign: 'center',
    marginBottom: 16,
  },
  retryButton: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    backgroundColor: '#111',
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#fff',
    fontWeight: '600',
  },
});
