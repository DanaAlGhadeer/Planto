//
//  SetRemainderSheet.swift
//  Planto
//
//  Created by Dana AlGhadeer on 23/10/2025.
//

import SwiftUI


struct SetReminderSheet: View {
    var mode: SheetMode
    
    //MARK: - Binding
    // Two-way binding Values shared with the parent
    @Binding var plantName: String
    @Binding var room: Room
    @Binding var light: Light
    @Binding var wateringDays: WateringDays
    @Binding var water: Water

    // Callback to notify parent when a plant is saved
    var onSave: (Plant) -> Void
    var onDelete: (() -> Void)? = nil
    
    // Access the environment's dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss
    
    @State private var showValidationAlert = false


    // Checks if plant name is filled
    var canSave: Bool {
        return !plantName.trimmingCharacters(in: .whitespaces).isEmpty
        // ^ True if plantName is not just spaces
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
                            onSave(newPlant)
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
                    
                    if mode == .edit {
                        Button(role: .destructive) {
                            onDelete?()
                            dismiss()
                        } label: {
                            Text("Delete Reminder")
                                .foregroundColor(Color.redDel)
                                .frame(width: 400)
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

