import Foundation

struct Question: Decodable {
    let id: Int
    let topic: String
    let questions: [String]
}
