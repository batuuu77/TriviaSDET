import Foundation

struct FeedbackDetails {
    let technical: String
    let communication: String
    let completeness: String
    let improvements: [String]
    
    static let empty = FeedbackDetails(
        technical: "",
        communication: "",
        completeness: "",
        improvements: []
    )
}
