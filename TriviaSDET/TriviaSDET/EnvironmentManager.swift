import Foundation

class EnvironmentManager {
    static let shared = EnvironmentManager()
    
    private init() {}
    
    func getAPIKey() -> String {
        // First try to get from environment variable
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil),
           let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) {
            let lines = envContent.components(separatedBy: .newlines)
            for line in lines {
                let parts = line.components(separatedBy: "=")
                if parts.count == 2 && parts[0] == "OPENAI_API_KEY" {
                    return parts[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        // Fallback to a development key or throw an error in production
        #if DEBUG
        return "development_key"
        #else
        fatalError("API Key not found in environment")
        #endif
    }
} 