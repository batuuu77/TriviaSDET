
import Foundation

class ProgressTracker: ObservableObject {
    @Published var topicProgress: [String: TopicProgress] = [:]
    
    struct TopicProgress: Codable {
        var questionsAnswered: Int
        var correctAnswers: Int
        var averageScore: Double
        var lastPracticeDate: Date
        var strengths: [String]
        var areasToImprove: [String]
    }
    
    func updateProgress(topic: String, score: Int, strengths: [String], improvements: [String]) {
        var current = topicProgress[topic] ?? TopicProgress(
            questionsAnswered: 0,
            correctAnswers: 0,
            averageScore: 0,
            lastPracticeDate: Date(),
            strengths: [],
            areasToImprove: []
        )
        
        current.questionsAnswered += 1
        if score >= 70 { current.correctAnswers += 1 }
        current.averageScore = ((current.averageScore * Double(current.questionsAnswered - 1)) + Double(score)) / Double(current.questionsAnswered)
        current.lastPracticeDate = Date()
        current.strengths = strengths
        current.areasToImprove = improvements
        
        topicProgress[topic] = current
    }
}
