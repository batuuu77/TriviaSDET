
import SwiftUI
import AVFoundation
import Foundation
struct InterviewQuestionView: View {

let topic: String

// MARK: - Environment Objects
@EnvironmentObject var userManager: UserManager

// MARK: - State Properties
@State private var currentQuestion: String?
@State private var currentTopic: String?
@State private var questionContext: String?
@State private var isRecording = false
@State private var recognizedText = ""
@State private var chatGPTResponse = ""
@State private var showResponse = false
@State private var responseStartTime: Date?
@State private var showStartRecordingButton = false
@State private var showPressStartText = true
@State private var isLoading = false
@State private var loadingProgress: CGFloat = 0
@State private var selectedFeedbackTab = 0
@State private var feedbackDetails: FeedbackDetails?
@State private var technicalScore = 0
@State private var communicationScore = 0
@State private var completenessScore = 0
@State private var showPremiumView = false
@State private var showLimitAlert = false
@State private var showTips = false
@State private var isExpanded = false
@State private var animateGradient = false
@AppStorage("dailyQuestionCount") private var dailyQuestionCount = 0

// MARK: - Private Properties
private let speechRecognizerManager = SpeechRecognizerManager()
private let chatGPTManager = ChatGPTManager()
    private let ttsHelper = TextToSpeechHelper.shared
private let feedbackTabs = ["Overview", "Technical", "Communication", "Improvements"]

// MARK: - Body
var body: some View {
    ZStack {
        backgroundLayer
        
        ScrollView {
            VStack(spacing: 20) {
                if showPressStartText {
                    welcomeSection
                } else {
                    questionSection
                    
                    if !recognizedText.isEmpty {
                        responseSection
                    }
                    
                    if showResponse {
                        feedbackSection
                    }
                }
                
                actionButtonsSection
            }
            .padding()
        }
    }
    .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
        Button("Upgrade to Premium", role: .none) {
            showPremiumView = true
        }
        Button("Cancel", role: .cancel) { }
    } message: {
        Text("You've reached your daily limit of 5 questions. Upgrade to Premium for unlimited access.")
    }
}

// MARK: - View Components
private var backgroundLayer: some View {
    LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: "1A1A2E"),
            Color(hex: "16213E"),
            Color(hex: "0F3460")
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    .ignoresSafeArea()
}

private var welcomeSection: some View {
    VStack(spacing: 20) {
        Text("Ready to Practice?")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.white)
        
        Text("Press Start to begin your interview practice session")
            .font(.system(size: 18, design: .rounded))
            .foregroundColor(.white.opacity(0.7))
            .multilineTextAlignment(.center)
    }
    .padding()
}

private var questionSection: some View {
    VStack(alignment: .leading, spacing: 15) {
        Text(currentTopic ?? topic)
            .font(.headline)
            .foregroundColor(.white.opacity(0.7))
        
        if let question = currentQuestion {
            Text(question)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        
        if let context = questionContext {
            Text(context)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
        }
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(15)
}

private var responseSection: some View {
    VStack(alignment: .leading, spacing: 15) {
        HStack {
            Text("Your Response")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            if let startTime = responseStartTime {
                Text("-\(Date().timeIntervalSince(startTime).formatDuration())")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        
        Text(recognizedText)
            .font(.body)
            .foregroundColor(.white.opacity(0.9))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(15)
}

private var feedbackSection: some View {
    VStack(alignment: .leading, spacing: 15) {
        Text("Feedback")
            .font(.headline)
            .foregroundColor(.white)
        
        Text(chatGPTResponse)
            .font(.body)
            .foregroundColor(.white.opacity(0.9))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
    }
    .padding()
    .background(Color.white.opacity(0.05))
    .cornerRadius(15)
}

private var actionButtonsSection: some View {
    VStack(spacing: 16) {
        if !showStartRecordingButton {
            startButton
        } else {
            recordingButton
        }
    }
}

private var startButton: some View {
    Button(action: handleStartButtonTapped) {
        HStack(spacing: 12) {
            Image(systemName: "play.fill")
            Text("Begin Interview")
                .fontWeight(.semibold)
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.primary)
        .cornerRadius(15)
    }
}

private var recordingButton: some View {
    Button(action: isRecording ? handleRecordingStop : handleRecordingStart) {
        HStack(spacing: 12) {
            Image(systemName: isRecording ? "stop.fill" : "mic.fill")
            Text(isRecording ? "Stop Recording" : "Start Recording")
                .fontWeight(.semibold)
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(isRecording ? Theme.secondary : Theme.primary)
        .cornerRadius(15)
    }
}

// MARK: - Helper Methods
private func handleStartButtonTapped() {
    if !canContinue() { return }
    
    withAnimation {
        showPressStartText = false
        showStartRecordingButton = true
        incrementDailyCount()
        responseStartTime = Date()
        
        if topic == "Random Questions" {
            if let randomResult = DataLoader.shared.getRandomQuestionFromAllTopics() {
                currentQuestion = randomResult.question
                currentTopic = randomResult.topic
            }
        } else {
            currentQuestion = DataLoader.shared.getRandomQuestion(forTopic: topic)
            currentTopic = topic
        }
    }
}

private func handleRecordingStart() {
    withAnimation {
        isRecording = true
        responseStartTime = Date()
        recognizedText = ""
    }
}

private func handleRecordingStop() {
    withAnimation {
        isRecording = false
        // Simulate some response
        recognizedText = "This is a simulated response. In a real implementation, this would be the transcribed text from speech recognition."
        chatGPTResponse = "This is simulated feedback. In a real implementation, this would be the response from ChatGPT."
        showResponse = true
    }
}

private func canContinue() -> Bool {
    if !userManager.isPremium && dailyQuestionCount >= 5 {
        showLimitAlert = true
        return false
    }
    return true
}

private func incrementDailyCount() {
    dailyQuestionCount += 1
}
}

// MARK: - Preview Provider
struct InterviewQuestionView_Model: PreviewProvider {
static var previews: some View {
    InterviewQuestionView(topic: "Java")
        .environmentObject(UserManager())
}
}

