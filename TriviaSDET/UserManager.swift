import Foundation
import UIKit
import SwiftUI
import KeychainSwift

class UserManager: ObservableObject {
    @Published var dailyQuestionsAsked: Int
    @Published var isPremium: Bool
    @Published var hasSeenIntroToday: Bool
    private let maxDailyQuestions = 5
    private let calendar = Calendar.current
    private let keychain = KeychainSwift()
    
    // App-specific prefix for keychain keys
    private let appPrefix = "bg.TriviaSDET"
    
    // Keys for storage with proper app-specific prefixes
    private var deviceIdKey: String { appPrefix + "device.identifier" }
    private var questionsKey: String { appPrefix + "questions.daily.count" }
    private var dateKey: String { appPrefix + "questions.last.date" }
    private var premiumKey: String { appPrefix + "user.premium.status" }
    private var introDateKey: String { appPrefix + "intro.last.date" }
    
    init() {
        // Initialize properties first
        self.dailyQuestionsAsked = 0
        self.isPremium = false
        self.hasSeenIntroToday = false
        
        // Load premium status
        self.isPremium = keychain.getBool(premiumKey) ?? false
        
        // Load or reset questions
        if shouldResetDailyQuestions() {
            self.dailyQuestionsAsked = 0
            saveDailyQuestions()
        } else {
            self.dailyQuestionsAsked = Int(keychain.get(questionsKey) ?? "0") ?? 0
        }
        
        // Check intro status last (after questions are loaded)
        if let lastIntroDateString = keychain.get(introDateKey),
           let lastIntroDate = ISO8601DateFormatter().date(from: lastIntroDateString) {
            self.hasSeenIntroToday = calendar.isDateInToday(lastIntroDate)
        }
        
        print("UserManager initialized with \(dailyQuestionsAsked) questions asked")
    }
    
    private func shouldResetDailyQuestions() -> Bool {
        guard let lastDateString = keychain.get(dateKey),
              let lastDate = ISO8601DateFormatter().date(from: lastDateString) else {
            return true
        }
        return !calendar.isDate(lastDate, inSameDayAs: Date())
    }
    
    func canAskMoreQuestions() -> Bool {
        return isPremium || dailyQuestionsAsked < maxDailyQuestions
    }
    
    func incrementQuestionsAsked() {
        if !isPremium {
            dailyQuestionsAsked += 1
            saveDailyQuestions()
        }
    }
    
    func markIntroAsSeen() {
        hasSeenIntroToday = true
        keychain.set(ISO8601DateFormatter().string(from: Date()), forKey: introDateKey)
    }
    
    private func saveDailyQuestions() {
        keychain.set(String(dailyQuestionsAsked), forKey: questionsKey)
        keychain.set(ISO8601DateFormatter().string(from: Date()), forKey: dateKey)
    }
    
    func remainingQuestions() -> Int {
        return maxDailyQuestions - dailyQuestionsAsked
    }
    
    func setPremiumStatus(isPremium: Bool) {
        self.isPremium = isPremium
        keychain.set(isPremium, forKey: premiumKey)
    }
    
    func getNextResetTime() -> Date {
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return now
        }
        return calendar.startOfDay(for: tomorrow)
    }
    
    func getTimeUntilReset() -> String {
        let now = Date()
        let resetTime = getNextResetTime()
        let difference = calendar.dateComponents([.hour, .minute], from: now, to: resetTime)
        
        if let hours = difference.hour, let minutes = difference.minute {
            return "\(hours)h \(minutes)m"
        }
        return "Soon"
    }
    func checkSubscriptionStatus() {
        if let expirationDate = UserDefaults.standard.object(forKey: "subscriptionExpirationDate") as? Date {
            isPremium = expirationDate > Date()
        }
    }}
