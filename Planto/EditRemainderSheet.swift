//
//  EditRemainderSheet.swift
//  Planto
//
//  Created by Dana AlGhadeer on 24/10/2025.
//
import SwiftUI

struct EditReminderSheet: View {
    // MARK: - Binding
    @Binding var plant: Plant  // We pass the whole plant to edit

    // MARK: - Callbacks
    var onSave: ((Plant) -> Void)? = nil
    var onDelete: ((Plant) -> Void)? = nil

    // MARK: - Controls
    @Environment(\.dismiss) private var dismiss
    @State private var showValidationAlert = false
    @State private var showDeleteAlert = false

    // MARK: - Helpers
    var canSave: Bool {
        !plant.name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                HStack(spacing: 80) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 32)
                    }
                    .buttonStyle(.glass)

                    Text("Edit Reminder")
                        .font(.system(size: 17, weight: .bold))

                    Button(action: {
                        if canSave {
                            onSave?(plant)
                            dismiss()
                        } else {
                            showValidationAlert = true
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 32)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.mintG)
                    .disabled(!canSave)
                }
                .padding(.top, 10)

                // Form
                Form {
                    Section {
                        LabeledContent("Plant Name") {
                            TextField("Pothos", text: $plant.name)
                                .textInputAutocapitalization(.words)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                        }
                    }

                    Section {
                        LabeledContent {
                            Picker("", selection: $plant.room) {
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
                            Picker("", selection: $plant.light) {
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
                            Picker("", selection: $plant.wateringDays) {
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
                            Picker("", selection: $plant.water) {
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

                    // Delete Button Section
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete Reminder")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            // Alerts
            .alert("Please enter a plant name.", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }

            .alert("Delete this reminder?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete?(plant)
                    dismiss()
                }
            }

            .presentationDetents([.large])
        }
    }
}

