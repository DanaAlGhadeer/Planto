//
//  TodayRemainder.swift
//  Planto
//
//  Created by Dana AlGhadeer on 23/10/2025.
//

import SwiftUI

struct TodayReminder: View {
    // Allow an optional initial plant to prefill/add on first appear
    var initialPlant: Plant? = nil

    // MARK: - App state (list of plants)
    @State private var plants: [Plant] = [] // start empty
    @State private var selectedPlant: Plant? = nil


    // MARK: - Sheet form bindings (shared with SetRemainderSheet)
    @State private var showingAddSheet = false
    @State private var newPlantName: String = ""
    @State private var newRoom: Room = .bedroom
    @State private var newLight: Light = .fullSun
    @State private var newWateringDays: WateringDays = .everyDay
    @State private var newWater: Water = .ml20to50

    // Track if we've already handled initialPlant to avoid duplicates on re-appear
    @State private var didApplyInitialPlant = false

    // MARK: - computed values
    private var wateredCount: Int {
        plants.filter { $0.isWatered }.count
    }

    private var progressFraction: Double {
        guard plants.count > 0 else { return 0.0 }
        return Double(wateredCount) / Double(plants.count)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Plants 🌱")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 12)

                        Divider()
                            .background(Color.gray.opacity(0.6))
                    }
                    .padding(.horizontal, 16)

                    // Subtitle + progress
                    VStack(spacing: 10) {
                        Text(progressSubtitle)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))

                        // progress bar with left mint fill and gray background
                        GeometryReader { geo in
                            // We subtract the same horizontal padding applied to this section (16 on each side)
                            // so the fill width aligns visually with the outer padding.
                            let availableWidth = max(0, geo.size.width - 32)
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .frame(height: 8)
                                    .foregroundColor(Color(white: 0.12))

                                Capsule()
                                    .frame(width: availableWidth * CGFloat(progressFraction), height: 8)
                                    .foregroundColor(Color.mint)
                                    .animation(.easeInOut(duration: 0.25), value: progressFraction)
                            }
                        }
                        .frame(height: 8) // constrain GeometryReader height
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 18)

                    // Plants list (only shown when there are plants)
                    if !plants.isEmpty {
                        List {
                            ForEach($plants) { $plant in
                                

                                PlantRowView(
                                    plant: $plant,
                                    onToggleWatered: { toggleWatered(for: plant) }
                                    
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .onTapGesture {
                                    selectedPlant = $plant.wrappedValue
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        withAnimation { deletePlant(id: plant.id) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .listRowInsets(EdgeInsets()) // better spacing control
                        }
                        .listStyle(.plain)
                        .background(Color.clear)
                        .scrollContentBackground(.hidden) // keep black background
                        .padding(.top, 6)
                    }

                    Spacer(minLength: 40)
                }
            }
            // Floating plus button (optional: keep to allow adding more from here)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    // prepare defaults for the sheet
                    resetNewPlantFields()
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .frame(width: 60, height: 60)
                        .background(Color.mint)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                        .padding(.trailing, 22)
                        .padding(.bottom, 22)
                }
            }
            .navigationBarHidden(true)
            // Apply initialPlant exactly once
            .onAppear {
                guard !didApplyInitialPlant else { return }
                if let initial = initialPlant {
                    withAnimation {
                        plants = [initial]
                    }
                }
                didApplyInitialPlant = true
            }
            // MARK: - Sheet
            .sheet(item: $selectedPlant) { plant in
                EditReminderSheet(plant: $plants[plants.firstIndex(of: plant)!],
                                  onSave: { updatedPlant in
                                      // Automatically updates because it's bound
                                  },
                                  onDelete: { plantToDelete in
                                      plants.removeAll { $0.id == plantToDelete.id }
                                  })
            }
            
            // ✅ MARK: - Sheet for adding a new plant
            .sheet(isPresented: $showingAddSheet) {
                EditReminderSheet(
                    plant: <#Binding<Plant>#>, name: $newPlantName,
                    room: $newRoom,
                    light: $newLight,
                    wateringDays: $newWateringDays,
                    water: $newWater,
                    onSave: {_ in 
                        let newPlant = Plant(
                            name: newPlantName,
                            room: newRoom,
                            light: newLight,
                            wateringDays: newWateringDays,
                            water: newWater,
                            isWatered: false
                        )
                        plants.append(newPlant)
                        showingAddSheet = false
                    },
                    onCancel: {
                        showingAddSheet = false
                    }
                )
            }

        } // NavigationStack
        .accentColor(Color.mint) // tint color for controls
    }

    // MARK: - Helpers

    private var progressSubtitle: String {
        if plants.isEmpty {
            return "Your plants are waiting for a sip 💧"
        } else if wateredCount == plants.count {
            return "\(wateredCount) of your plants feel loved today ✨"
        } else {
            return "\(wateredCount) of your plants feel loved today"
        }
    }

    private func toggleWatered(for plant: Plant) {
        guard let idx = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[idx].isWatered.toggle()
    }

    private func deletePlant(id: UUID) {
        plants.removeAll { $0.id == id }
    }

    private func resetNewPlantFields() {
        newPlantName = ""
        newRoom = .bedroom
        newLight = .fullSun
        newWateringDays = .everyDay
        newWater = .ml20to50
    }
}

// MARK: - Plant Row View

fileprivate struct PlantRowView: View {
    @Binding var plant: Plant
    var onToggleWatered: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // small location row
            HStack(spacing: 6) {
                Image(systemName: "location")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("in \(plant.room.title)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 16)

            HStack(alignment: .center, spacing: 12) {
                // Leading circle -> toggles watered
                Button {
                    onToggleWatered()
                } label: {
                    if plant.isWatered {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color.mint)
                    } else {
                        Circle()
                            .strokeBorder(Color.gray, lineWidth: 2)
                            .frame(width: 26, height: 26)
                            .foregroundColor(.clear)
                    }
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)

                // Name + badges
                VStack(alignment: .leading, spacing: 6) {
                    Text(plant.name)
                        .font(.title2)
                        .foregroundColor(plant.isWatered ? Color.gray.opacity(0.6) : .white)
                        .bold()

                    HStack(spacing: 8) {
                        // Light badge (icon + text)
                        HStack(spacing: 6) {
                            Image(systemName: plant.light.iconName)
                            Text(plant.light.title)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        // Water badge
                        HStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                            Text(plant.water.title)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Spacer()
            }
            .padding(.vertical, 12)

            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.leading, 16)
        }
        .background(Color.clear)
    }
}

// MARK: - Light enum extension for SF symbol icon mapping
private extension Light {
    // return an SF Symbol name based on light case
    var iconName: String {
        switch self {
        case .fullSun: return "sun.max.fill"
        case .partialSun: return "cloud.sun.fill"
        case .lowLight: return "moon.fill"
        }
    }
}

// MARK: - Preview

struct TodayReminder_Previews: PreviewProvider {
    static var previews: some View {
        TodayReminder()
            .preferredColorScheme(.dark)
    }
}
