import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Attempt to maximize the first window
        NSApp.windows.first?.setFrame(NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800), display: true)
        NSApp.windows.first?.center()
    }
}

@main
struct BrowserApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var tabManager = TabManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(tabManager: tabManager)
                .frame(minWidth: 1024, minHeight: 768)
        }
        .windowStyle(.hiddenTitleBar) // Optional: Modern look
        .commands {
            // Add custom menu commands if needed
            CommandGroup(replacing: .newItem) {
                Button("New Tab") {
                    tabManager.addNewTab()
                }
                .keyboardShortcut("t")
                
                Button("Close Tab") {
                    if let active = tabManager.activeTabId {
                        tabManager.closeTab(active)
                    }
                }
                .keyboardShortcut("w")
            }
        }
    }
}
