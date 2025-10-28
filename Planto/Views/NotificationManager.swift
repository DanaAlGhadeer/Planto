//
//  NotificationManager.swift
//  Planto
//
//  Created by Dana AlGhadeer on 28/10/2025.
//

import Foundation
import UserNotifications


final class NotificationManager {
    static let instance = NotificationManager()
    private init() {}
    
    // Ask user for permission
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Notifications allowed" : "❌ Notifications denied")
            }
        }
    }
    
    // Schedule by plant name and a human-readable days string (like your screenshot)
    func scheduleNotification(for plantName: String, after intervalDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your \(plantName) buddy!"
        content.sound = .default
        
        let seconds = daysToSeconds(intervalDays)
        
        // Repeating time-interval trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
//    // Convenience that uses your WateringDays enum directly
//    func schedule(for plant: Plant) {
//        let content = UNMutableNotificationContent()
//        content.title = "Water \(plant.name)"
//        content.body = "Time to water your plant in \(plant.room.title). \(plant.water.title) recommended."
//        content.sound = .default
//        
//        let seconds = Double(plant.wateringDays.intervalDays)
//
//
//        // Use a stable identifier per plant so we can cancel/update
//        let identifier = "plant.reminder.\(plant.id.uuidString)"
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request)
//    }
//    
//    func cancel(for plantID: UUID) {
//        let identifier = "plant.reminder.\(plantID.uuidString)"
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
//    }
//    
//    func cancelAll() {
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//    }
    
    // Map strings like in your screenshot. You can ignore this if you use WateringDays directly.
    private func daysToSeconds(_ days: Int) -> Double {
        switch days {
        case 1:
            return 10
        case 2:
            return 2 * 24 * 60 * 60
        case 3:
            return 3 * 24 * 60 * 60
        case  7:
            return 7 * 24 * 60 * 60
        case 10:
            return 10 * 24 * 60 * 60
        case 14:
            return 14 * 24 * 60 * 60
        default:
            return 24 * 60 * 60
        }
    }
    
    }
