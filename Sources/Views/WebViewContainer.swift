import SwiftUI
import WebKit

struct WebViewContainer: View {
    @ObservedObject var tabManager: TabManager
    let tab: TabItem
    
    var body: some View {
        GeometryReader { geometry in
            if tabManager.activeTabId == tab.id {
                // Live View
                if let webView = tabManager.webViews[tab.id] {
                    WebViewRepresentable(webView: webView, tabManager: tabManager, tabId: tab.id)
                } else {
                    WebViewRepresentable(webView: tabManager.getWebView(for: tab.id), tabManager: tabManager, tabId: tab.id)
                }
            } else {
                // Suspended View (Snapshot)
                if let snapshot = tab.snapshot {
                    Image(nsImage: snapshot)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    Color.white.overlay(Text(tab.title).foregroundColor(.gray))
                }
            }
        }
    }
}
