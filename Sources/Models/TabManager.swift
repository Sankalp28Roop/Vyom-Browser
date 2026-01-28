import SwiftUI
import WebKit
import Combine

struct TabItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var url: URL
    var snapshot: NSImage?
    var favicon: NSImage?
    
    init(url: URL, title: String = "New Tab") {
        self.id = UUID()
        self.url = url
        self.title = title
    }
    
    static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        return lhs.id == rhs.id && lhs.url == rhs.url && lhs.title == rhs.title
    }
}

@MainActor
class TabManager: ObservableObject {
    @Published var tabs: [TabItem] = []
    @Published var activeTabId: UUID?
    
    // Live WebViews
    var webViews: [UUID: WKWebView] = [:]
    private var contentRuleList: WKContentRuleList?
    
    init() {
        // Preload privacy rules from ContentBlockerManager (now in PrivacyConfig.swift)
        ContentBlockerManager.shared.loadRules { [weak self] list in
            self?.contentRuleList = list
        }
        
        let initialTab = TabItem(url: URL(string: "http://start/")!)
        tabs.append(initialTab)
        activeTabId = initialTab.id
        
        _ = getWebView(for: initialTab.id)
    }
    
    func addNewTab(url: URL = URL(string: "http://start/")!) {
        let newTab = TabItem(url: url)
        tabs.append(newTab)
        selectTab(newTab.id)
    }
    
    func closeTab(_ id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        webViews.removeValue(forKey: id)
        tabs.remove(at: index)
        
        if activeTabId == id {
            if tabs.isEmpty {
                addNewTab()
            } else {
                let newIndex = min(index, tabs.count - 1)
                selectTab(tabs[newIndex].id)
            }
        }
    }
    
    func selectTab(_ id: UUID) {
        guard let oldId = activeTabId, oldId != id else {
            activeTabId = id
            return
        }
        suspendTab(oldId)
        activeTabId = id
        _ = getWebView(for: id)
    }
    
    func getWebView(for tabId: UUID) -> WKWebView {
        if let existing = webViews[tabId] {
            return existing
        }
        return createWebView(for: tabId)
    }
    
    private func createWebView(for tabId: UUID) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        let mediaPrefs = WKWebpagePreferences()
        mediaPrefs.allowsContentJavaScript = true 
        config.defaultWebpagePreferences = mediaPrefs
        
        if let ruleList = self.contentRuleList {
            config.userContentController.add(ruleList)
        } else {
             ContentBlockerManager.shared.loadRules { [weak self] list in
                 self?.contentRuleList = list
             }
        }
        
        let protectionJS = """
        const toDataURL = HTMLCanvasElement.prototype.toDataURL;
        HTMLCanvasElement.prototype.toDataURL = function() { return "data:image/png;base64,"; };
        """
        let script = WKUserScript(source: protectionJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        if let tab = tabs.first(where: { $0.id == tabId }) {
            // Local Start Page Logic
            if tab.url.absoluteString == "about:blank" || tab.url.absoluteString == "http://start/" {
                // Try Bundle.module (SwiftPM) first, then Bundle.main
                var path: String? = Bundle.main.path(forResource: "StartPage", ofType: "html", inDirectory: "Resources")
                if path == nil {
                    path = Bundle.main.path(forResource: "StartPage", ofType: "html")
                }
                
                if let resourcePath = path {
                    let url = URL(fileURLWithPath: resourcePath)
                    webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                } else {
                     print("Error: StartPage.html not found in bundle!")
                     webView.load(URLRequest(url: URL(string: "https://www.google.com")!))
                }
            } else {
                let request = URLRequest(url: tab.url)
                webView.load(request)
            }
        }
        
        webViews[tabId] = webView
        return webView
    }
    
    private func suspendTab(_ tabId: UUID) {
        guard let webView = webViews[tabId] else { return }
        let catchConfig = WKSnapshotConfiguration()
        catchConfig.rect = webView.bounds
        catchConfig.afterScreenUpdates = false
        
        webView.takeSnapshot(with: catchConfig) { [weak self] image, error in
            guard let self = self else { return }
            if let image = image, let index = self.tabs.firstIndex(where: { $0.id == tabId }) {
                self.tabs[index].snapshot = image
            }
            self.webViews.removeValue(forKey: tabId)
        }
    }
    
    func updateTabUrl(_ id: UUID, url: URL?) {
        guard let url = url, let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs[index].url = url
    }
    
    func updateTabTitle(_ id: UUID, title: String?) {
        guard let title = title, !title.isEmpty, let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs[index].title = title
    }
}
