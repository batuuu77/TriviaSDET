
import Foundation

class AnalyticsManager: ObservableObject {
    @Published var sessionData: [PracticeSession] = []
    
    struct PracticeSession: Identifiable, Codable {
        let id: UUID
        let date: Date
        let topic: String
        let question: String
        let answerDuration: TimeInterval
        let technicalScore: Int
        let communicationScore: Int
        let overallScore: Int
        let strengths: [String]
        let improvements: [String]
    }
    
    func addSession(
        topic: String,
        question: String,
        duration: TimeInterval,
        scores: (technical: Int, communication: Int, overall: Int),
        strengths: [String],
        improvements: [String]
    ) {
        let session = PracticeSession(
            id: UUID(),
            date: Date(),
            topic: topic,
            question: question,
            answerDuration: duration,
            technicalScore: scores.technical,
            communicationScore: scores.communication,
            overallScore: scores.overall,
            strengths: strengths,
            improvements: improvements
        )
        sessionData.append(session)
    }
    
    func getAverageScores(for topic: String) -> (technical: Double, communication: Double, overall: Double) {
        let topicSessions = sessionData.filter { $0.topic == topic }
        guard !topicSessions.isEmpty else { return (0, 0, 0) }
        
        let technical = Double(topicSessions.map { $0.technicalScore }.reduce(0, +)) / Double(topicSessions.count)
        let communication = Double(topicSessions.map { $0.communicationScore }.reduce(0, +)) / Double(topicSessions.count)
        let overall = Double(topicSessions.map { $0.overallScore }.reduce(0, +)) / Double(topicSessions.count)
        
        return (technical, communication, overall)
    }
}
