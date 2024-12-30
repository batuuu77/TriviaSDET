import Foundation

class DataLoader {
    static let shared = DataLoader()
    var topics: [Question] = [] // JSON'daki her topic bir Question nesnesi olacak.

    init() {
        loadQuestions()
    }

    func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            fatalError("Failed to locate questions.json in app bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load questions.json from app bundle.")
        }
        do {
            topics = try JSONDecoder().decode([Question].self, from: data)
        } catch {
            fatalError("Failed to decode questions from JSON: \(error)")
        }
    }

    func getRandomQuestion(forTopic topicName: String) -> String? {
        guard let topic = topics.first(where: { $0.topic == topicName }) else { return nil }
        return topic.questions.randomElement()
    }

    // Tüm topicler arasından rastgele bir soru seç
    func getRandomQuestionFromAllTopics() -> (question: String, topic: String)? {
        guard let randomTopic = topics.randomElement(),
              let randomQuestion = randomTopic.questions.randomElement() else {
            return nil
        }
        return (randomQuestion, randomTopic.topic)
    }
}
extension DataLoader {
    func getAvailableTopics() -> [String] {
        return topics.map { $0.topic }
    }
    
    func hasQuestions(forTopic topic: String) -> Bool {
        guard let topic = topics.first(where: { $0.topic == topic }) else {
            return false
        }
        return !topic.questions.isEmpty
    }
}
