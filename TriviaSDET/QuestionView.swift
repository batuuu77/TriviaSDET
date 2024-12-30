import SwiftUI
import AVFoundation
import StoreKit

struct QuestionView: View {
    var topic: String
    @EnvironmentObject var userManager: UserManager
    
    
    // MARK: - State Properties
    @State private var currentQuestion: String?
    @State private var currentTopic: String?
    @State private var questionContext: String?
    @State private var isRecording = false
    @State private var recognizedText = ""
    @State private var responseStartTime: Date?
    @State private var responseDuration: TimeInterval = 0
    @State private var showStartRecordingButton = false
    @State private var showPressStartText = true
    @State private var animateGradient = false
    @State private var isNavigatingBack = false
    
    // MARK: - UI State
    @State private var selectedFeedbackTab = 0
    @State private var showTips = false
    @State private var showFeedbackDetail = false
    @State private var cardOffset: CGFloat = 1000
    @State private var isExpanded = false
    @State private var showResponse = false
    @State private var progress: CGFloat = 0
    
    // MARK: - Premium Features State
    @State private var sampleAnswer: SampleAnswer?
    @State private var showingSampleAnswer = false
    @State private var showingAnalytics = false
    @State private var evaluationResult: EvaluationResult?
    @State private var showPremiumFeatures = false
    
    // MARK: - Feedback Properties
    @State private var technicalScore: Int = 0
    @State private var communicationScore: Int = 0
    @State private var completenessScore: Int = 0
    @State private var feedbackDetails: FeedbackDetails?
    @State private var chatGPTResponse = "Awaiting response..."
    @State private var textToSpeechEnabled = true
    
    // MARK: - Loading States
    @State private var isLoading = false
    @State private var currentLoadingPhase = LoadingPhase.initial
    @State private var loadingProgress: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Premium Features
    @State private var dailyQuestionCount = UserDefaults.standard.integer(forKey: "dailyQuestionCount")
    @State private var showLimitAlert = false
    @State private var showPremiumView = false
    
    // MARK: - Managers
    @StateObject private var storeManager = StoreManager()
    @ObservedObject private var speechRecognizerManager = SpeechRecognizerManager()
    private let chatGPTManager = ChatGPTManager()
    private let ttsHelper = TextToSpeechHelper.shared
    private let textToSpeechHelper = TextToSpeechHelper.shared
    
    // MARK: - Constants
    private let loadingPhases = [
        LoadingPhase(title: "Analyzing Response", description: "Evaluating technical accuracy..."),
        LoadingPhase(title: "Processing", description: "Assessing communication clarity..."),
        LoadingPhase(title: "Finalizing", description: "Generating comprehensive feedback..."),
        LoadingPhase(title: "Complete", description: "Preparing your results...")
    ]
    
    private let feedbackTabs = ["Overview", "Technical", "Communication", "Tips"]
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    headerSection
                    
                    if !showPressStartText {
                        ProgressView(value: progress)
                            .tint(Color.appPrimary)
                            .padding(.horizontal)
                    }
                    
                    mainContent
                    
                    actionButtonsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            
            if showTips {
                tipsOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            isNavigatingBack = true
            textToSpeechHelper.stopSpeaking()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                Text("Back")
                    .foregroundColor(.white)
            }
        })
        .onDisappear {
            if !isNavigatingBack {
                textToSpeechHelper.stopSpeaking()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            textToSpeechHelper.stopSpeaking()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            textToSpeechHelper.stopSpeaking()
        }
        .sheet(isPresented: $showPremiumView) {
            PremiumPlanView(storeManager: storeManager, showModal: $showPremiumView) {
                handlePremiumPurchase()
            }
            .environmentObject(userManager)
        }
        .sheet(isPresented: $showingSampleAnswer) {
            SampleAnswerView(
                question: currentQuestion ?? "",
                topic: topic
            )
        }
        .sheet(isPresented: $showingAnalytics) {
            AnalyticsView(evaluationResult: evaluationResult)
        }
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("Upgrade to Premium", role: .none) {
                showPremiumView = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You've reached your daily limit of 5 questions. Upgrade to Premium for unlimited access and exclusive features.")
        }
    }
    
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("1A1A2E"),
                    Color("16213E"),
                    Color("0F3460")
                ]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            .onAppear { animateGradient = true }
            
            ParticleEffect()
                .opacity(0.3)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text(topic)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.appPrimary.opacity(0.5), radius: 10)
            
            if let currentTopic = currentTopic, topic == "Random Questions" {
                TopicBadge(topic: currentTopic)
            }
            
            if !showPressStartText {
                HStack(spacing: 15) {
                    StatsCard(title: "Questions", value: "\(dailyQuestionCount)")
                    
                    // Avg Score with lock for non-premium
                    if userManager.isPremium {
                        StatsCard(title: "Avg Score", value: "\(overallScore)%")
                    } else {
                        Button(action: {
                            showPremiumView = true
                        }) {
                            VStack(spacing: 4) {
                                HStack(spacing: 4) {
                                    Text("Avg Score")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color.appPrimary)
                                }
                                Text("Unlock")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.appPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    
                    if let duration = responseStartTime?.timeIntervalSinceNow {
                        StatsCard(title: "Time", value: duration.formatDuration())
                    }
                }
            }
            
            if userManager.isPremium {
                premiumFeatureButtons
            }
        }
        .padding(.top, 40)
    }

    private var mainContent: some View {
        Group {
            if let question = currentQuestion {
                questionCard(question)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else if showPressStartText {
                welcomeCard
            }
            
            if !recognizedText.isEmpty {
                responseCard
            }
            
            if isLoading {
                loadingCard
            } else if showResponse {
                feedbackCard
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isLoading)
    }
    
    private var welcomeCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.appPrimary)
            
            Text("Ready to Practice?")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("Tap 'Begin Interview' to start your practice session.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
    
    private var responseCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Response")
                .font(.headline)
                .foregroundColor(.white)
            
            Text(recognizedText)
                .font(.body)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
    }

    private var loadingCard: some View {
        VStack(spacing: 20) {
            LoadingRing(progress: loadingProgress)
                .frame(width: 80, height: 80)
            
            Text(currentLoadingPhase.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(currentLoadingPhase.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(loadingPhases.indices, id: \.self) { index in
                    LoadingStep(
                        phase: loadingPhases[index],
                        isCompleted: index < Int(loadingProgress * CGFloat(loadingPhases.count)),
                        isActive: index == Int(loadingProgress * CGFloat(loadingPhases.count))
                    )
                }
            }
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
    
    private var feedbackCard: some View {
        VStack(spacing: 20) {
            // ChatGPT Response Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("AI Feedback")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Replay Button
                    Button(action: {
                        textToSpeechHelper.speak(text: chatGPTResponse)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))
                            Text("Replay")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.3))
                        .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    
                    // Stop Button
                    Button(action: {
                        textToSpeechHelper.stopSpeaking()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "speaker.slash.fill")
                                .font(.system(size: 14))
                            Text("Stop")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.3))
                        .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    .padding(.leading, 8)
                }
                
                Text(chatGPTResponse)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if userManager.isPremium {
                HStack(spacing: 20) {
                    scoreCircle(score: technicalScore, title: "Technical")
                    scoreCircle(score: communicationScore, title: "Communication")
                    scoreCircle(score: completenessScore, title: "Completeness")
                }
            } else {
                // Enhanced Premium upgrade prompt
                VStack(spacing: 16) {
                    Text("🌟 Unlock Premium Features")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PremiumFeatureRow(icon: "chart.bar.fill", title: "Detailed Scoring", description: "Get technical, communication & overall scores")
                        PremiumFeatureRow(icon: "doc.text.fill", title: "Sample Answers", description: "View model answers with code examples")
                        PremiumFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Analytics", description: "Access personalized improvement tips")
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)
                    
                    Button(action: {
                        showPremiumView = true
                    }) {
                        Text("Upgrade to Premium")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.appPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
            }
            
            // Next Question Button
            Button(action: {
                textToSpeechHelper.stopSpeaking()
                withAnimation {
                    recognizedText = ""
                    showResponse = false
                    handleStartButtonTapped()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                    Text("Next Question")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.3))
                .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .shadow(color: Color.black.opacity(0.1), radius: 10)
        )
    }
    private struct PremiumFeatureRow: View {
        let icon: String
        let title: String
        let description: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color.appPrimary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    private var premiumFeedbackSection: some View {
        VStack(spacing: 15) {
            if let result = evaluationResult {
                Text("Detailed Analysis")
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    ForEach(result.strengths, id: \.self) { strength in
                        Text(strength)
                            .font(.caption)
                            .padding(8)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                if let code = result.sampleCode {
                    Text("Sample Implementation")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(code)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private func scoreCircle(score: Int, title: String) -> some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(scoreColor(for: score), lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(score)")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private func scoreColor(for score: Int) -> Color {
        switch score {
        case 0..<60: return .red
        case 60..<80: return .yellow
        default: return .green
        }
    }
    
    // MARK: - Helper Methods
    private func handleStartButtonTapped() {
            if !userManager.canAskMoreQuestions() {
                showLimitAlert = true
                return
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                stopSpeaking()
                showPressStartText = false
                showStartRecordingButton = true
                userManager.incrementQuestionsAsked()
                responseStartTime = Date()
                
                if topic == "Random Questions" {
                    if let randomResult = DataLoader.shared.getRandomQuestionFromAllTopics() {
                        currentQuestion = randomResult.question
                        currentTopic = randomResult.topic
                        questionContext = generateContext(for: randomResult.topic)
                    }
                } else {
                    currentQuestion = DataLoader.shared.getRandomQuestion(forTopic: topic)
                    questionContext = generateContext(for: topic)
                }
            }
        }
    
    private func handleRecordingStart() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isRecording = true
            stopSpeaking()
            responseStartTime = Date()
            speechRecognizerManager.startListening()
        }
    }
    
    private func handleRecordingStop() {
        withAnimation {
            isRecording = false
            responseDuration = Date().timeIntervalSince(responseStartTime ?? Date())
        }
        
        speechRecognizerManager.stopListening { audioFileUrl in
            processAudio(fileUrl: audioFileUrl)
        }
    }
    
    private func processAudio(fileUrl: URL?) {
        guard let fileUrl = fileUrl else {
            recognizedText = "Audio recording failed. Please try again."
            return
        }
        
        isLoading = true
        loadingProgress = 0
        currentLoadingPhase = loadingPhases[0]
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation {
                if loadingProgress < 1.0 {
                    loadingProgress += 0.25
                    let phaseIndex = Int(loadingProgress * CGFloat(loadingPhases.count - 1))
                    currentLoadingPhase = loadingPhases[phaseIndex]
                } else {
                    timer.invalidate()
                }
            }
        }
        
        let whisperRecognizer = WhisperSpeechRecognizer()
        whisperRecognizer.transcribeAudio(fileUrl: fileUrl) { transcription in
            if let transcription = transcription {
                DispatchQueue.main.async {
                    withAnimation {
                        self.recognizedText = transcription
                        print("✅ Got transcription: \(transcription)")
                    }
                    
                    self.chatGPTManager.evaluateAnswer(
                        question: self.currentQuestion ?? "",
                        userAnswer: transcription,
                        isPremium: self.userManager.isPremium
                    ) { result in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            if let result = result {
                                print("✅ Received scores - Technical: \(result.technicalScore), Communication: \(result.communicationScore)")
                                
                                withAnimation {
                                    self.evaluationResult = result
                                    self.chatGPTResponse = result.feedback
                                    self.showResponse = true
                                    
                                    // Explicitly update the scores
                                    self.technicalScore = result.technicalScore
                                    self.communicationScore = result.communicationScore
                                    self.completenessScore = (result.technicalScore + result.communicationScore) / 2
                                    
                                    // Generate feedback details with the new scores
                                    self.generateFeedbackDetails(from: result)
                                }
                                
                                if self.textToSpeechEnabled {
                                    self.textToSpeechHelper.speak(text: result.feedback)
                                }
                                
                                if self.userManager.isPremium {
                                    self.loadSampleAnswer()
                                }
                            } else {
                                self.chatGPTResponse = "Failed to evaluate answer. Please try again."
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func generateFeedbackDetails(from result: EvaluationResult) {
        print("Generating feedback details with scores:")
        print("Technical: \(result.technicalScore)")
        print("Communication: \(result.communicationScore)")
        
        self.technicalScore = result.technicalScore
        self.communicationScore = result.communicationScore
        self.completenessScore = (result.technicalScore + result.communicationScore) / 2
        
        feedbackDetails = FeedbackDetails(
            technical: "Technical proficiency: \(result.technicalScore)%",
            communication: "Communication clarity: \(result.communicationScore)%",
            completeness: "Overall completeness: \(completenessScore)%",
            improvements: result.improvements
        )
    };    private func loadSampleAnswer() {
        guard let question = currentQuestion else { return }
        chatGPTManager.generateSampleAnswer(for: question) { answer in
            DispatchQueue.main.async {
                self.sampleAnswer = answer
            }
        }
    }
    
    private func handlePremiumPurchase() {
        userManager.isPremium = true
        showPremiumView = false
    }
    
    private func canContinue() -> Bool {
           if !userManager.canAskMoreQuestions() {
               showLimitAlert = true
               return false
           }
           return true
       }
    
    private func stopSpeaking() {
        ttsHelper.stopSpeaking()
    }
    
    private var overallScore: Int {
        guard technicalScore > 0 && communicationScore > 0 && completenessScore > 0 else { return 0 }
        return (technicalScore + communicationScore + completenessScore) / 3
    }
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            if !showStartRecordingButton {
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
                    .background(Color.appPrimary)
                    .cornerRadius(15)
                }
            }
            
            if showStartRecordingButton {
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
                           .background(isRecording ? Color.red : Color.appPrimary)
                           .cornerRadius(15)
                       }
                       
                       // Add Next Question button for premium users
                       if userManager.isPremium && !isRecording {
                           Button(action: {
                               textToSpeechHelper.stopSpeaking()
                               withAnimation {
                                   recognizedText = ""
                                   showResponse = false
                                   handleStartButtonTapped()
                               }
                           }) {
                               HStack(spacing: 12) {
                                   Image(systemName: "arrow.triangle.2.circlepath")
                                   Text("Next Question")
                                       .fontWeight(.semibold)
                               }
                               .font(.headline)
                               .foregroundColor(.white)
                               .frame(maxWidth: .infinity)
                               .padding()
                               .background(
                                   LinearGradient(
                                       colors: [Color(hex: "FFD700"), Color(hex: "FDB931")],
                                       startPoint: .leading,
                                       endPoint: .trailing
                                   )
                               )
                               .cornerRadius(15)
                           }
                       }
                   }
               }
           }
    private var tipsOverlay: some View {
        VStack {
            Text("Interview Tips")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    TipCard(title: "Structure", content: "Use STAR method: Situation, Task, Action, Result")
                    TipCard(title: "Clarity", content: "Speak clearly and maintain good pace")
                    TipCard(title: "Examples", content: "Provide specific examples from your experience")
                    TipCard(title: "Technical", content: "Use proper technical terms and explain concepts")
                }
                .padding()
            }
            
            Button("Close") {
                withAnimation {
                    showTips = false
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.9))
        .edgesIgnoringSafeArea(.all)
    }

    struct TipCard: View {
        let title: String
        let content: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(content)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }
    private struct ScoreView: View {
        let title: String
        let score: Int
        
        var body: some View {
            VStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(score)%")
                    .font(.title3.bold())
                    .foregroundColor(.white)
            }
        }
    }

    struct AnalyticsView: View {
        let evaluationResult: EvaluationResult?
        
        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Performance Analytics")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    if let result = evaluationResult {
                        AnalyticsScoreCard(title: "Technical", score: result.technicalScore)
                        AnalyticsScoreCard(title: "Communication", score: result.communicationScore)
                        AnalyticsScoreCard(title: "Overall", score: result.overallScore)
                        
                        StrengthsSection(strengths: result.strengths)
                        ImprovementsSection(improvements: result.improvements)
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.9))
        }
    }

    private struct AnalyticsScoreCard: View {
        let title: String
        let score: Int
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(score)%")
                    .font(.title2)
                    .foregroundColor(scoreColor)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
        
        private var scoreColor: Color {
            switch score {
            case 0..<60: return .red
            case 60..<80: return .yellow
            default: return .green
            }
        }
    }

    private struct StrengthsSection: View {
        let strengths: [String]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Strengths")
                    .font(.headline)
                ForEach(strengths, id: \.self) { strength in
                    Text("• \(strength)")
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }

    private struct ImprovementsSection: View {
        let improvements: [String]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text("Areas to Improve")
                    .font(.headline)
                ForEach(improvements, id: \.self) { improvement in
                    Text("• \(improvement)")
                        .foregroundColor(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
    }

    private func questionCard(_ question: String) -> some View {
        VStack(spacing: 20) {
            Text(question)
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
        }
    }

    private var premiumFeatureButtons: some View {
        HStack(spacing: 20) {
            Button(action: { showingSampleAnswer = true }) {
                PremiumFeatureButton(icon: "doc.text.fill", title: "Sample Answer")
            }
            
            Button(action: { showingAnalytics = true }) {
                PremiumFeatureButton(icon: "chart.bar.fill", title: "Analytics")
            }
        }
    }
}

// MARK: - Preview Provider
struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(topic: "API Testing")
            .environmentObject(UserManager())
            .preferredColorScheme(.dark)
    }
}
private struct StatsCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }}
struct PremiumFeatureButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
            Text(title)
                .font(.caption)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

extension AnyTransition {
    static var asymmetric: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
    }
}

