import SwiftUI

struct ContentView: View {
    @ObservedObject var tabManager: TabManager
    @State private var urlInput: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // -- Tab Bar --
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 1) {
                    ForEach(tabManager.tabs) { tab in
                        TabButton(tab: tab, isActive: tabManager.activeTabId == tab.id) {
                            tabManager.selectTab(tab.id)
                        } onClose: {
                            tabManager.closeTab(tab.id)
                        }
                    }
                    
                    Button(action: {
                        tabManager.addNewTab()
                    }) {
                        Image(systemName: "plus")
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }
            .frame(height: 38)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // -- Toolbar (Address Bar & Nav) --
            HStack(spacing: 12) {
                // Nav Buttons
                HStack(spacing: 8) {
                    Button(action: goBack) { Image(systemName: "chevron.left") }
                    Button(action: goForward) { Image(systemName: "chevron.right") }
                    Button(action: reload) { Image(systemName: "arrow.clockwise") }
                }
                .buttonStyle(.plain)
                
                // Address Bar
                TextField("Search or enter address", text: $urlInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        loadUrl(urlInput)
                    }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // -- Content --
            ZStack {
                // Only render the active tab to keep view hierarchy light? 
                // Alternatively, render all but use WebViewContainer to swap to Image.
                // For optimal performance, we only want the ACTIVE one in hierarchy logic if possible, 
                // but SwiftUI `ForEach` works too if we trust WebViewContainer to be efficient.
                // However, `ForEach` keeps all views in memory.
                
                // Better approach for strict memory:
                // Just show current active tab if we trust TabManager state.
                if let activeId = tabManager.activeTabId,
                   let activeTab = tabManager.tabs.first(where: { $0.id == activeId }) {
                    WebViewContainer(tabManager: tabManager, tab: activeTab)
                        .id(activeId) // Transition
                } else {
                    Text("No Tabs")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: tabManager.activeTabId) { newId in
            if let id = newId, let tab = tabManager.tabs.first(where: { $0.id == id }) {
                urlInput = tab.url.absoluteString
            }
        }
        .onChange(of: tabManager.tabs) { _ in
           // update inputs if needed
             if let id = tabManager.activeTabId, let tab = tabManager.tabs.first(where: { $0.id == id }) {
                 if urlInput != tab.url.absoluteString && !isEditing {
                     // Check if not editing (approx)
                     urlInput = tab.url.absoluteString
                 }
             }
        }
    }
    
    // Quick helper to detect if user is typing? (Skipped for simplicity)
    var isEditing: Bool = false
    
    func loadUrl(_ input: String) {
        // Simple heuristic: if contains spaces -> search, else url
        var urlString = input
        if !input.lowercased().hasPrefix("http") {
             if input.contains(" ") || !input.contains(".") {
                 urlString = "https://www.google.com/search?q=\(input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
             } else {
                 urlString = "https://\(input)"
             }
        }
        
        if let url = URL(string: urlString), let activeId = tabManager.activeTabId {
             tabManager.getWebView(for: activeId).load(URLRequest(url: url))
        }
    }
    
    func goBack() {
        if let id = tabManager.activeTabId { tabManager.getWebView(for: id).goBack() }
    }
    func goForward() {
         if let id = tabManager.activeTabId { tabManager.getWebView(for: id).goForward() }
    }
    func reload() {
         if let id = tabManager.activeTabId { tabManager.getWebView(for: id).reload() }
    }
}

struct TabButton: View {
    let tab: TabItem
    let isActive: Bool
    let action: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Favicon could go here
            if let favicon = tab.favicon {
                Image(nsImage: favicon)
                    .resizable()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "globe")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.gray)
            }
            
            Text(tab.title)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(maxWidth: 150)
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .foregroundColor(isActive ? .primary : .secondary)
            }
            .buttonStyle(.plain)
            .opacity(0.6)
            
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(isActive ? Color(NSColor.controlBackgroundColor) : Color.clear)
        .cornerRadius(6)
        .onTapGesture {
            action()
        }
    }
}
