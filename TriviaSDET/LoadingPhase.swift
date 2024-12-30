import Foundation

struct LoadingPhase {
    let title: String
    let description: String
    
    static let initial = LoadingPhase(
        title: "Initializing",
        description: "Preparing to analyze your response..."
    )
}
let loadingPhases = [
    LoadingPhase(
        title: "Analyzing Response",
        description: "Processing your answer..."
    ),
    LoadingPhase(
        title: "Technical Review",
        description: "Evaluating technical accuracy..."
    ),
    LoadingPhase(
        title: "Communication Check",
        description: "Assessing communication clarity..."
    ),
    LoadingPhase(
        title: "Generating Feedback",
        description: "Preparing detailed feedback..."
    )
]
