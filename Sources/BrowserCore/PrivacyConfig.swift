import WebKit

class ContentBlockerManager {
    static let shared = ContentBlockerManager()
    
    private var ruleList: WKContentRuleList?
    
    // Minimal block list for demonstration (EasyList-style would need parsing)
    // In a real app, you'd parse actual EasyList JSON.
    private let blockRulesJSON = """
    [
        {
            "trigger": {
                "url-filter": ".*",
                "resource-type": ["image", "style-sheet", "script", "popup"],
                "if-domain": ["*doubleclick.net", "*google-analytics.com", "*facebook.com"]
            },
            "action": {
                "type": "block"
            }
        },
        {
            "trigger": {
                "url-filter": "(ads|banner|popup).*",
                "resource-type": ["image", "frame"]
            },
            "action": {
                "type": "block"
            }
        }
    ]
    """
    
    func loadRules(completion: @escaping (WKContentRuleList?) -> Void) {
        if let existing = ruleList {
            completion(existing)
            return
        }
        
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "ContentBlocker",
            encodedContentRuleList: blockRulesJSON
        ) { [weak self] list, error in
            if let error = error {
                print("Rule compilation error: \(error)")
                completion(nil)
            } else {
                self?.ruleList = list
                completion(list)
            }
        }
    }
}
