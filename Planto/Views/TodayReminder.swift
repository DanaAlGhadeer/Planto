//
//  TodayRemainder.swift
//  Planto
//
//  Created by Dana AlGhadeer on 23/10/2025.
//

import SwiftUI

struct TodayReminder: View {

    
    @EnvironmentObject private var store: PlantStore
    
    
    // MARK: - Sheet form bindings (shared with SetRemainderSheet)
    @State private var showingAddSheet = false
    @State private var newPlantName: String = ""
    @State private var newRoom: Room = .bedroom
    @State private var newLight: Light = .fullSun
    @State private var newWateringDays: WateringDays = .everyDay
    @State private var newWater: Water = .ml20to50
    
    
    @State private var selectedPlant: Plant? = nil
    
    @State private var editPlantName: String = ""
    @State private var editRoom: Room = .bedroom
    @State private var editLight: Light = .fullSun
    @State private var editWateringDays: WateringDays = .everyDay
    @State private var editWater: Water = .ml20to50
    
    
    
    // MARK: - Body
    var body: some View {
        
        ZStack(alignment: .bottomTrailing) {
            // Background
            Color(.systemBackground).ignoresSafeArea()
            
            
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("My Plants 🌱")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 12)
                
                Divider()
                    .background(Color.grey)
                
                //All DONE STATE
                if store.isAllDone {
                    AllDoneView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    VStack(spacing: 12) {
                        Text(store.statusLine)
                            .font(.callout)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        ThickProgress(value: store.progressVal)
                            .frame(height: 8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 14)
                    List {
                        ForEach(store.plants) {
                            plant in
                            PlantRow(
                                plant: plant,
                                onToggle: {store.toggleWatered(for: plant.id)},
                                onTapName: { beginEdit(plant)}
                            )
                        }
                        .onDelete(perform: store.remove)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .padding(.horizontal, 16)
            
            //Floating plus [+] button (always visible)
            Button {
                beginAdd()
            } label : {
                Image(systemName: "plus")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 32)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.mintG)
            .padding()
            .accessibilityLabel("Add plant")
            
        }
        
        //  MARK: - Sheet for adding a new plant (use SetReminderSheet)
        .sheet(isPresented: $showingAddSheet) {
            SetReminderSheet(
                mode: .add,
                plantName: $newPlantName,
                room: $newRoom,
                light: $newLight,
                wateringDays: $newWateringDays,
                water: $newWater,
                onSave: { newPlant in
                    store.add(newPlant)
                }
            )
        }
        
        // MARK: - Sheet for editing a plant
        
        .sheet(item: $selectedPlant){ plant in
            SetReminderSheet(
                mode: .edit,
                plantName: $editPlantName,
                room: $editRoom,
                light: $editLight,
                wateringDays: $editWateringDays,
                water: $editWater,
                onSave: { updated in
                    var copy = updated
                    copy.id = plant.id
                    copy.lastWateredAt = plant.lastWateredAt
                    copy.isWatered = plant.isWatered
                    
                    store.update(copy)
                    
                },
                onDelete: {
                    store.remove(id: plant.id)
                }
            )
        }
        .onAppear{ store.refreshDailyState()}
    }
    //MARK: - help manage the draft/edit

    private func beginAdd() {
        
        newPlantName = ""
        newRoom = .bedroom
        newLight = .fullSun
        newWateringDays = .everyDay
        newWater = .ml20to50
        showingAddSheet = true
    }
    
    private func beginEdit(_ plant: Plant){
        selectedPlant = plant
        
        editPlantName = plant.name
        editRoom = plant.room
        editLight = plant.light
        editWateringDays = plant.wateringDays
        editWater = plant.water
   
    }
}


// MARK: - Row View

//One row in the list: leading checkmark, name (tap to edit), and small badges.
struct PlantRow: View {
    let plant: Plant
    let onToggle: () -> Void
    let onTapName: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Checkmark toggle
            Button(action: onToggle) {
                Image(systemName: plant.isWateredToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .foregroundColor(plant.isWatered ? .mintG : .grey)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {

                // ROOM LINE (above the name)
                HStack(spacing: 6) {
                    Image(systemName: "location")
                        .font(.caption)
                        .foregroundColor(.grey)
                    Text("in \(plant.room.title)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.grey)
                }

                // NAME (tap to edit)
                Button(action: onTapName) {
                    Text(plant.name)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(plant.isWatered ? .grey : .white)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)

                // TAGS: colored sun + water
                HStack(spacing: 8) {
                    LightTag(text: plant.light.title)   // yellow-ish
                    WaterTag(text: plant.water.title)   // blue-ish
                }
                .font(.caption)
            }

            Spacer()
        }
    }
}

// MARK: - Thick Progress (like your design)

struct ThickProgress: View {
    let value: Double   // expected 0...1

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.15))
                Capsule()
                    .fill(Color.mintG)
                    .frame(width: max(0, geo.size.width * value))
                    .animation(.easeInOut(duration: 0.35), value: value)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}

struct LightTag: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sun.max")
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dGrey)
        )
        .foregroundColor(.limeG) // icon+text tint
    }
}

struct WaterTag: View {
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "drop")
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dGrey)
        )
       
        .foregroundColor(.lBlue)
    }
}

// MARK: - All Done View

struct AllDoneView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("donePlanto")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
            Text("All Done!🎉")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("All Reminders Completed")
                .font(.system(size: 16))
                .foregroundColor(.grey)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)

    }
}

