
import Foundation

struct SampleAnswerTemplate: Identifiable {
    let id: UUID
    let topic: String
    let question: String
    let template: String
    let keyPoints: [String]
    let commonMistakes: [String]
    let tips: [String]
}

class TemplateManager {
    static let shared = TemplateManager()
    
    private var templates: [String: [SampleAnswerTemplate]] = [
        "Java": [
            SampleAnswerTemplate(
                id: UUID(),
                topic: "Java",
                question: "What is inheritance?",
                template: """
                Inheritance is a fundamental OOP concept that allows a class to inherit properties and methods from another class. Key points:
                
                1. Extends keyword usage
                2. Types of inheritance
                3. Method overriding
                4. Super keyword
                
                Example:
                public class Child extends Parent {
                    // Inherited methods and properties
                }
                """,
                keyPoints: [
                    "Mention 'extends' keyword",
                    "Explain types of inheritance",
                    "Discuss method overriding",
                    "Include practical example"
                ],
                commonMistakes: [
                    "Confusing inheritance with interfaces",
                    "Not mentioning access modifiers",
                    "Forgetting to discuss 'super' keyword"
                ],
                tips: [
                    "Start with a clear definition",
                    "Use real-world examples",
                    "Mention practical applications"
                ]
            )
        ]
    ]
    
    func getTemplate(for topic: String, question: String) -> SampleAnswerTemplate? {
        return templates[topic]?.first { $0.question == question }
    }
}
