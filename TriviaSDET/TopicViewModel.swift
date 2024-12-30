import SwiftUI

class TopicViewModel: ObservableObject {
    @Published var topics: [String]
    private let dataLoader = DataLoader.shared
    
    init() {
        self.topics = [
            "Java",
            "SQL",
            "API Testing",
            "Selenium",
            "Git",
            "CI/CD",
            "Random Questions"
        ]
        
        // Debug prints
        print("All topics in dataLoader: \(dataLoader.topics.map { $0.topic })")
    }
    
    func getQuestionCount(for topic: String) -> Int {
        if topic == "Random Questions" {
            let totalCount = dataLoader.topics.reduce(0) { $0 + $1.questions.count }
            print("Random Questions total count: \(totalCount)")
            return totalCount
        } else {
            print("Looking for topic: \(topic)")
            let count = dataLoader.topics.first(where: { $0.topic == topic })?.questions.count ?? 0
            print("Found count: \(count) for topic: \(topic)")
            
            return count
        }
    }
    
    func color1(topic: String) -> Color {
        switch topic {
        case "Java":
            return Color(hex: "f89820")
        case "SQL":
            return Color(hex: "00758F")
        case "API Testing":
            return Color(hex: "7B68EE")
        case "Selenium":
            return Color(hex: "43B02A")
        case "Git":
            return Color(hex: "F05032")
        case "CI/CD":
            return Color(hex: "4B0082")
        case "Random Questions":
            return Color(hex: "6A5ACD")
        default:
            return Color.blue
        }
    }
    
    func color2(topic: String) -> Color {
        switch topic {
        case "Java":
            return Color(hex: "d87800")
        case "SQL":
            return Color(hex: "005571")
        case "API Testing":
            return Color(hex: "5A48CD")
        case "Selenium":
            return Color(hex: "339020")
        case "Git":
            return Color(hex: "D03012")
        case "CI/CD":
            return Color(hex: "380062")
        case "Random Questions":
            return Color(hex: "483AAD")
        default:
            return Color.blue.opacity(0.7)
        }
    }
}
