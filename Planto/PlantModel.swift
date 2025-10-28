//
//  PlantModel.swift
//  Planto
//
//  Created by Dana AlGhadeer on 26/10/2025.
//
import SwiftUI

struct Plant: Identifiable, Equatable, Codable {
   
    var id: UUID = UUID()
    var name: String
    var room: Room
    var light: Light
    var wateringDays: WateringDays
    var water: Water
    var isWatered: Bool = false
    
    var lastWateredAt: Date? = nil
    
    var isWateredToday: Bool {
        guard let d = lastWateredAt else { return false }
        return Calendar.current.isDateInToday(d)
    }
    
}

enum WateringDays: String, CaseIterable, Identifiable, Codable {
    case everyDay, every2Days, every3Days, onceWeek, every10Days, every2Weeks
    var id: String { rawValue }
    var title: String {
        switch self {
        case .everyDay: return "Every Day"
        case .every2Days: return "Every 2 Days"
        case .every3Days: return "Every 3 Days"
        case .onceWeek: return "Once a Week"
        case .every10Days: return "Every 10 days"
        case .every2Weeks: return "Every 2 weeks"
        }
    }
    
    var intervalDays: Int {
        switch self {
        case .everyDay: return 1
        case.every2Days: return 2
        case.every3Days: return 3
        case.onceWeek: return 7
        case.every10Days: return 10
        case.every2Weeks: return 14
        }
    }
}

enum Room: String, CaseIterable, Identifiable, Codable {
    case bedroom, livingroom, kitchen, balcony, bathroom
    var id: String { rawValue }
    var title: String {
        switch self {
        case .bedroom: return "Bedroom"
        case .livingroom: return "Living Room"
        case .kitchen: return "Kitchen"
        case .balcony: return "Balcony"
        case .bathroom: return "Bathroom"
        }
    }
}

enum Water: String, CaseIterable, Identifiable, Codable {
    case ml20to50, ml50to100, ml100to200, ml200to300
    var id: String { rawValue }
    var title: String {
        switch self {
        case .ml20to50: return "20-50 ml"
        case .ml50to100: return "50-100 ml"
        case .ml100to200: return "100-200 ml"
        case .ml200to300: return "200-300 ml"
        }
    }
}

enum Light: CaseIterable, Identifiable, Codable {
    case fullSun, partialSun, lowLight
    var id: Self { self }
    var title: String {
        switch self {
        case .fullSun: return "Full Sun"
        case .partialSun: return "Partial Sun"
        case .lowLight: return "Low Light"
        }
    }
}

enum SheetMode {
    case add
    case edit
}
