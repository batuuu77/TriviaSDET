import Foundation
import AVFoundation

class WhisperSpeechRecognizer {
    private let apiKey = EnvironmentManager.shared.getAPIKey()
    
    public func transcribeAudio(fileUrl: URL, completion: @escaping (String?) -> Void) {
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
        let fileName = fileUrl.lastPathComponent
        print("Sending file: \(fileName)")

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)

        do {
            let audioData = try Data(contentsOf: fileUrl)
            print("Audio data size: \(audioData.count) bytes")
            body.append(audioData)
        } catch {
            print("Error reading audio file: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Add the required 'model' parameter
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error while sending request: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received from Whisper API.")
                completion(nil)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Whisper API JSON Response: \(jsonResponse)")
                    if let transcription = jsonResponse["text"] as? String {
                        completion(transcription)
                    } else {
                        print("Error: 'text' field is missing in Whisper API response.")
                        completion(nil)
                    }
                } else {
                    print("Error: Unable to parse Whisper API response as JSON.")
                    completion(nil)
                }
            } catch {
                print("Error decoding Whisper API response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    
    private func createMultipartFormData(audioData: Data, boundary: String) -> Data {
        var body = Data()
        let fieldName = "file"
        let fileName = "audio.m4a"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
