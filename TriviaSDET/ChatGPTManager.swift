import Foundation

class ChatGPTManager {
    private let apiKey = EnvironmentManager.shared.getAPIKey()

    func transcribeAudio(fileUrl: URL, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/audio/transcriptions") else {
            print("Invalid Whisper API URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)

        do {
            let audioData = try Data(contentsOf: fileUrl)
            body.append(audioData)
        } catch {
            print("Error reading audio file: \(error.localizedDescription)")
            completion(nil)
            return
        }

        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("Sending request to Whisper API...")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error while sending request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("Unexpected status code: \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }
            }

            guard let data = data else {
                print("No data received from Whisper API.")
                completion(nil)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let transcription = jsonResponse["text"] as? String {
                    print("Whisper API Transcription: \(transcription)")
                    completion(transcription)
                } else {
                    print("Unexpected response format from Whisper API.")
                    completion(nil)
                }
            } catch {
                print("Error decoding Whisper API response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    func evaluateAnswer(question: String, userAnswer: String, isPremium: Bool = false, completion: @escaping (EvaluationResult?) -> Void) {
            guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                print("Invalid ChatGPT API URL")
                completion(nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let systemMessage = """
            You are an expert SDET instructor. Evaluate the answer and provide:
            1. Brief feedback on the response's accuracy and completeness
            2. A concise but correct answer to the question
            3. Prepare your answers for the person who knows Java,Selenium,Junit,TestNG,Cucumber,RestAssured
            
            For premium users, also include detailed scoring and analysis in JSON format:
            {
                "feedback": "Main feedback message",
                "correctAnswer": "The complete correct answer",
                "technicalScore": 0-100,
                "communicationScore": 0-100,
                "overallScore": 0-100,
                "strengths": ["strength1", "strength2"],
                "improvements": ["improvement1", "improvement2"],
                "sampleCode": "Optional code example if relevant",
                "relatedConcepts": ["concept1", "concept2"]
            }
            
            For non-premium users, format the response as:
            "Feedback: [brief feedback]\n\nCorrect Answer: [concise correct answer]"
            """

            let body: [String: Any] = [
                "model": "gpt-4-turbo",
                "messages": [
                    ["role": "system", "content": systemMessage],
                    ["role": "user", "content": "Question: \(question)\nUser's Answer: \(userAnswer)" + (isPremium ? "\nProvide detailed feedback with JSON." : "\nProvide basic feedback.")]
                ],
                "temperature": 0.7,
                "max_tokens": isPremium ? 1000 : 500
            ]

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                print("Failed to encode request body: \(error.localizedDescription)")
                completion(nil)
                return
            }

            print("Sending request to ChatGPT API...")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error while sending request: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("Unexpected status code: \(httpResponse.statusCode)")
                        completion(nil)
                        return
                    }
                }

                guard let data = data else {
                    print("No data received from ChatGPT API.")
                    completion(nil)
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = jsonResponse["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        
                        if isPremium {
                            if let evaluationData = content.data(using: .utf8),
                               let result = try? JSONDecoder().decode(EvaluationResult.self, from: evaluationData) {
                                completion(result)
                            } else {
                                // Fallback for premium users if JSON parsing fails
                                let basicResult = EvaluationResult(
                                    feedback: content,
                                    technicalScore: 70,
                                    communicationScore: 70,
                                    overallScore: 70,
                                    strengths: ["Good attempt"],
                                    improvements: ["Could be more detailed"],
                                    sampleCode: nil,
                                    relatedConcepts: []
                                )
                                completion(basicResult)
                            }
                        } else {
                            // Non-premium response
                            let basicResult = EvaluationResult(
                                feedback: content,
                                technicalScore: 0,
                                communicationScore: 0,
                                overallScore: 0,
                                strengths: [],
                                improvements: [],
                                sampleCode: nil,
                                relatedConcepts: []
                            )
                            completion(basicResult)
                        }
                    }
                } catch {
                    print("Error decoding ChatGPT API response: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
        }
    

    func generateSampleAnswer(for question: String, completion: @escaping (SampleAnswer?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion(nil)
            return
        }

        let systemMessage = """
        You are an expert SDET instructor. Generate a comprehensive sample answer for the given interview question in JSON format with the following structure:
        {
            "mainAnswer": "Detailed answer",
            "keyPoints": ["point1", "point2", "point3"],
            "codeExample": "Optional code example",
            "bestPractices": ["practice1", "practice2", "practice3"],
            "commonPitfalls": ["pitfall1", "pitfall2", "pitfall3"]
        }
        """

        let body: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": "Generate a sample answer for: \(question)"]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = jsonResponse["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String,
                  let sampleData = content.data(using: .utf8) else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(SampleAnswer.self, from: sampleData)
                completion(result)
            } catch {
                print("Error decoding sample answer: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func processAudio(fileUrl: URL, question: String, isPremium: Bool = false, completion: @escaping (EvaluationResult?) -> Void) {
        transcribeAudio(fileUrl: fileUrl) { transcription in
            guard let transcription = transcription else {
                completion(EvaluationResult(
                    feedback: "Transcription failed.",
                    technicalScore: 0,
                    communicationScore: 0,
                    overallScore: 0,
                    strengths: [],
                    improvements: [],
                    sampleCode: nil,
                    relatedConcepts: []
                ))
                return
            }

            self.evaluateAnswer(question: question, userAnswer: transcription, isPremium: isPremium, completion: completion)
        }
    }
}

// MARK: - Models
struct EvaluationResult: Codable {
    let feedback: String
    let technicalScore: Int
    let communicationScore: Int
    let overallScore: Int
    let strengths: [String]
    let improvements: [String]
    let sampleCode: String?
    let relatedConcepts: [String]
}

struct SampleAnswer: Codable {
    let mainAnswer: String
    let keyPoints: [String]
    let codeExample: String?
    let bestPractices: [String]
    let commonPitfalls: [String]
}
