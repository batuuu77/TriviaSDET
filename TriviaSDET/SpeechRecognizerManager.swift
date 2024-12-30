import AVFoundation

class SpeechRecognizerManager: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var audioFileURL: URL? // Ses kaydını saklamak için
    private let whisperAPIKey = EnvironmentManager.shared.getAPIKey()

    @Published var text = ""
    @Published var isListening = false

    func startListening() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            return
        }

        let inputNode = audioEngine.inputNode
        let hardwareFormat = inputNode.inputFormat(forBus: 0) // Donanımın desteklediği formatı alın
        audioFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("wav")

        do {
            let audioFile = try AVAudioFile(forWriting: audioFileURL!, settings: hardwareFormat.settings)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: hardwareFormat) { buffer, _ in
                do {
                    try audioFile.write(from: buffer)
                } catch {
                    print("Error writing audio buffer: \(error.localizedDescription)")
                }
            }
            audioEngine.prepare()
            try audioEngine.start()
            isListening = true
            print("Started listening. Audio file will be saved to: \(audioFileURL!)")
        } catch {
            print("Error setting up audio recording: \(error.localizedDescription)")
        }
    }



    func stopListening(completion: @escaping (URL?) -> Void) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isListening = false

        guard let audioFileURL = audioFileURL else {
            print("Error: No audio file URL found.")
            completion(nil)
            return
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: audioFileURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            print("Audio file size: \(fileSize) bytes")
            if fileSize > 0 {
                completion(audioFileURL)
            } else {
                print("Error: Audio file is empty.")
                completion(nil)
            }
        } catch {
            print("Error verifying audio file: \(error.localizedDescription)")
            completion(nil)
        }
    }

    public func transcribeAudio(fileUrl: URL, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/audio/transcriptions") else {
            print("Invalid Whisper API URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(whisperAPIKey)", forHTTPHeaderField: "Authorization")
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
                        if transcription.isEmpty || transcription.count < 5 {
                            print("Error: Transcription is too short or invalid.")
                            completion(nil)
                            return
                        }
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
}
