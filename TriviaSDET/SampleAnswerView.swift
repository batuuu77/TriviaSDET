import SwiftUI
import Foundation

struct SampleAnswerView: View {
    let question: String
    let topic: String
    @Environment(\.dismiss) private var dismiss
    @State private var sampleAnswer: SampleAnswer?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    loadingView
                } else if let answer = sampleAnswer {
                    answerContent(answer)
                } else if error != nil {
                    errorView
                } else {
                    Text("No sample answer available")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Sample Answer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadSampleAnswer()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView("Generating sample answer...")
                .tint(.blue)
            Text("This may take a few moments...")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Failed to load sample answer")
                .font(.headline)
            Button("Try Again") {
                loadSampleAnswer()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func answerContent(_ answer: SampleAnswer) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                questionSection
                
                mainAnswerSection(answer)
                
                keyPointsSection(answer)
                
                if let code = answer.codeExample {
                    codeSection(code)
                }
                
                bestPracticesSection(answer)
                
                commonPitfallsSection(answer)
            }
            .padding()
        }
    }
    
    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Question")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(question)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private func mainAnswerSection(_ answer: SampleAnswer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sample Answer")
                .font(.headline)
            
            Text(answer.mainAnswer)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private func keyPointsSection(_ answer: SampleAnswer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Points")
                .font(.headline)
            
            ForEach(answer.keyPoints, id: \.self) { point in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    Text(point)
                }
            }
        }
    }
    
    private func codeSection(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Code Example")
                .font(.headline)
            
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private func bestPracticesSection(_ answer: SampleAnswer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best Practices")
                .font(.headline)
            
            ForEach(answer.bestPractices, id: \.self) { practice in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .padding(.top, 2)
                    Text(practice)
                }
            }
        }
    }
    
    private func commonPitfallsSection(_ answer: SampleAnswer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common Pitfalls")
                .font(.headline)
            
            ForEach(answer.commonPitfalls, id: \.self) { pitfall in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .padding(.top, 2)
                    Text(pitfall)
                }
            }
        }
    }
    
    private func loadSampleAnswer() {
        isLoading = true
        error = nil
        
        let chatGPTManager = ChatGPTManager()
        chatGPTManager.generateSampleAnswer(for: question) { answer in
            DispatchQueue.main.async {
                self.isLoading = false
                self.sampleAnswer = answer
            }
        }
    }
    
}

#Preview {
    SampleAnswerView(
        question: "What is dependency injection?",
        topic: "Software Architecture"
    )
}
