//
//  SetRemainderSheet.swift
//  Planto
//
//  Created by Dana AlGhadeer on 23/10/2025.
//

import SwiftUI

struct SetRemainderSheet: View {
    //MARK: - Binding
    // Two-way binding Values shared with the parent
    @Binding var plantName: String
    @Binding var room: Room
    @Binding var light: Light
    @Binding var wateringDays: WateringDays
    @Binding var water: Water

    // Callback to notify parent when a plant is saved
    var onSave: ((Plant) -> Void)? = nil
    
    // Controls
    @Environment(\.dismiss) private var dismiss // Access the environment's dismiss action to close the sheet
    @State private var showValidationAlert = false


    // Checks if plant name is filled
    var canSave: Bool {
        return !plantName.trimmingCharacters(in: .whitespaces).isEmpty // True if plantName is not just spaces
    }
    //MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 80) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 32)
                    }
                    .buttonStyle(.glass)

                    Text("Set Reminder")
                        .font(.system(size: 17, weight: .bold))

                    Button(action: {
                        if canSave {
                            // Build a Plant and notify parent
                            let newPlant = Plant(
                                name: plantName,
                                room: room,
                                light: light,
                                wateringDays: wateringDays,
                                water: water,
                                isWatered: false
                            )
                            onSave?(newPlant)
                            // Dismiss the sheet
                            dismiss()
                        } else { // If invalid
                            showValidationAlert = true // Show alert asking for a plant name
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 32)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.mintG)
                    .disabled(!canSave) // Disable the button when form is invalid
                    
                }
                .padding(.top, 10)

                //MARK: - Form
                Form {
                    Section {
                        LabeledContent("Plant Name") {
                            TextField("Pothos", text: $plantName)
                                .textInputAutocapitalization(.words) // Capitalize words for names
                                .disableAutocorrection(true) // Disable autocorrect for names
                                .submitLabel(.done) // Show "Done" on the keyboard
                                .onSubmit { // Handle keyboard "Done"
                                    if canSave {
                                        // Same behavior as tapping save
                                        let newPlant = Plant(
                                            name: plantName,
                                            room: room,
                                            light: light,
                                            wateringDays: wateringDays,
                                            water: water,
                                            isWatered: false
                                        )
                                        onSave?(newPlant)
                                        dismiss()
                                    } else {
                                        showValidationAlert = true // Show validation alert
                                    }
                                }
                        }
                    }

                    Section {
                        LabeledContent {
                            Picker("", selection: $room) {
                                ForEach(Room.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        } label: {
                            Label("Room", systemImage: "location")
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(.white)
                        }

                        LabeledContent {
                            Picker("", selection: $light) {
                                ForEach(Light.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        } label: {
                            Label("Light", systemImage: "sun.max")
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(.white)
                        }
                    }

                    Section {
                        LabeledContent {
                            Picker("", selection: $wateringDays) {
                                ForEach(WateringDays.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        } label: {
                            Label("Watering Days", systemImage: "drop")
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(.white)
                        }

                        LabeledContent {
                            Picker("", selection: $water) {
                                ForEach(Water.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        } label: {
                            Label("Water", systemImage: "drop")
                                .symbolRenderingMode(.monochrome)
                                .foregroundColor(.white)
                        }
                    }
                }
            }

            //MARK: -  Alert if name empty
            .alert("Please enter a plant name.", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }


            .presentationDetents([.large])
        }
    }
}

// MARK: - Enums and Model

struct Plant: Identifiable, Equatable, Codable {
    var id: UUID
    var name: String
    var room: Room
    var light: Light
    var wateringDays: WateringDays
    var water: Water
    var isWatered: Bool

    init(id: UUID = UUID(),
         name: String,
         room: Room,
         light: Light,
         wateringDays: WateringDays,
         water: Water,
         isWatered: Bool = false) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.wateringDays = wateringDays
        self.water = water
        self.isWatered = isWatered
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, room, light, wateringDays, water, isWatered
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        room = try container.decode(Room.self, forKey: .room)
        light = try container.decode(Light.self, forKey: .light)
        wateringDays = try container.decode(WateringDays.self, forKey: .wateringDays)
        water = try container.decode(Water.self, forKey: .water)
        isWatered = try container.decodeIfPresent(Bool.self, forKey: .isWatered) ?? false
    }
}

enum WateringDays: CaseIterable, Identifiable, Codable {
    case everyDay, every2Days, every3Days, onceWeek, every10Days, every2Weeks
    var id: Self { self }
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
}

enum Room: CaseIterable, Identifiable, Codable {
    case bedroom, livingroom, kitchen, balcony, bathroom
    var id: Self { self }
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

enum Water: CaseIterable, Identifiable, Codable {
    case ml20to50, ml50to100, ml100to200, ml200to300
    var id: Self { self }
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
