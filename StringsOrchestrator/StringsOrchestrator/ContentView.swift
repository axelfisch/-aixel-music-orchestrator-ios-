import SwiftUI
import WebKit

struct ContentView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var isLoading = true
    @State private var error: Error?
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var showSettings = false
    @State private var progress: Double = 0
    
    let webURL = "https://stellar-travesseiro-4619b2.netlify.app/"
    
    var body: some View {
        NavigationView {
            ZStack {
                if networkMonitor.isConnected {
                    VStack(spacing: 0) {
                        if isLoading && progress > 0 && progress < 1 {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                .frame(height: 2)
                        }
                        
                        WebView(
                            urlString: webURL,
                            isLoading: $isLoading,
                            error: $error,
                            canGoBack: $canGoBack,
                            canGoForward: $canGoForward,
                            progress: $progress
                        )
                        .edgesIgnoringSafeArea(.bottom)
                    }
                } else {
                    OfflineView()
                }
                
                if isLoading && networkMonitor.isConnected {
                    ProgressView("Chargement...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .purple))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
            .navigationBarTitle("StringsOrchestrator", displayMode: .inline)
            .navigationBarItems(
                leading: HStack {
                    Button(action: {
                        NotificationCenter.default.post(name: .goBack, object: nil)
                    }) {
                        Image(systemName: "chevron.left")
                            .imageScale(.large)
                    }
                    .disabled(!canGoBack)
                    
                    Button(action: {
                        NotificationCenter.default.post(name: .goForward, object: nil)
                    }) {
                        Image(systemName: "chevron.right")
                            .imageScale(.large)
                    }
                    .disabled(!canGoForward)
                },
                trailing: Button(action: {
                    NotificationCenter.default.post(name: .reload, object: nil)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.large)
                }
            )
        }
        .alert(isPresented: .constant(error != nil)) {
            Alert(
                title: Text("Erreur de connexion"),
                message: Text(error?.localizedDescription ?? "Une erreur s'est produite"),
                primaryButton: .default(Text("Réessayer")) {
                    NotificationCenter.default.post(name: .reload, object: nil)
                },
                secondaryButton: .cancel(Text("Annuler"))
            )
        }
        .preferredColorScheme(.dark)
    }
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let goBack = Notification.Name("goBack")
    static let goForward = Notification.Name("goForward")
}

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var error: Error?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var progress: Double
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        // Enable JavaScript
        webView.configuration.preferences.javaScriptEnabled = true
        
        // Add progress observer
        context.coordinator.addProgressObserver(webView)
        
        // Set up notifications
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.reload),
            name: .reload,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.goBack),
            name: .goBack,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.goForward),
            name: .goForward,
            object: nil
        )
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update navigation state
        canGoBack = uiView.canGoBack
        canGoForward = uiView.canGoForward
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var webView: WKWebView?
        private var progressObservation: NSKeyValueObservation?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        deinit {
            progressObservation?.invalidate()
        }
        
        func addProgressObserver(_ webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
                DispatchQueue.main.async {
                    self?.parent.progress = webView.estimatedProgress
                }
            }
        }
        
        @objc func reload() {
            webView?.reload()
        }
        
        @objc func goBack() {
            webView?.goBack()
        }
        
        @objc func goForward() {
            webView?.goForward()
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            self.webView = webView
            parent.isLoading = true
            parent.error = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.error = error
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.error = error
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}