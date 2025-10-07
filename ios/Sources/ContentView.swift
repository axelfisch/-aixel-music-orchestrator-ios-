import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var isLoading: Bool
    @Binding var estimatedProgress: Double

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        weak var webViewRef: WKWebView?
        var progressObservation: NSKeyValueObservation?
        var backObserver: NSObjectProtocol?
        var forwardObserver: NSObjectProtocol?
        var reloadObserver: NSObjectProtocol?
        init(parent: WebView) { self.parent = parent }

        deinit {
            progressObservation?.invalidate()
            if let backObserver { NotificationCenter.default.removeObserver(backObserver) }
            if let forwardObserver { NotificationCenter.default.removeObserver(forwardObserver) }
            if let reloadObserver { NotificationCenter.default.removeObserver(reloadObserver) }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }
        // Handle target=_blank
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }

        // Keep state in sync during navigation decisions
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            decisionHandler(.allow)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webViewRef = webView

        // Observe progress updates
        context.coordinator.progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak coordinator = context.coordinator] webView, _ in
            guard let coordinator = coordinator else { return }
            coordinator.parent.estimatedProgress = webView.estimatedProgress
        }

        // Wire up navigation actions via NotificationCenter
        context.coordinator.backObserver = NotificationCenter.default.addObserver(forName: .goBack, object: nil, queue: .main) { [weak coordinator = context.coordinator] _ in
            coordinator?.webViewRef?.goBack()
        }
        context.coordinator.forwardObserver = NotificationCenter.default.addObserver(forName: .goForward, object: nil, queue: .main) { [weak coordinator = context.coordinator] _ in
            coordinator?.webViewRef?.goForward()
        }
        context.coordinator.reloadObserver = NotificationCenter.default.addObserver(forName: .reload, object: nil, queue: .main) { [weak coordinator = context.coordinator] _ in
            coordinator?.webViewRef?.reload()
        }

        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        estimatedProgress = uiView.estimatedProgress
        canGoBack = uiView.canGoBack
        canGoForward = uiView.canGoForward
    }
}

struct ContentView: View {
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = false
    @State private var estimatedProgress: Double = 0

    private let startURL = URL(string: "https://stellar-travesseiro-4619b2.netlify.app/")!

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView(value: estimatedProgress)
                        .progressViewStyle(.linear)
                }
                WebView(
                    url: startURL,
                    canGoBack: $canGoBack,
                    canGoForward: $canGoForward,
                    isLoading: $isLoading,
                    estimatedProgress: $estimatedProgress
                )
                .edgesIgnoringSafeArea(.bottom)
                HStack {
                    Button(action: { NotificationCenter.default.post(name: .goBack, object: nil) }) {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!canGoBack)
                    Spacer()
                    Button(action: { NotificationCenter.default.post(name: .reload, object: nil) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    Spacer()
                    Button(action: { NotificationCenter.default.post(name: .goForward, object: nil) }) {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!canGoForward)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Stellar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension Notification.Name {
    static let goBack = Notification.Name("WebViewGoBack")
    static let goForward = Notification.Name("WebViewGoForward")
    static let reload = Notification.Name("WebViewReload")
}
