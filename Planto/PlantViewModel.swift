//
//  PlantViewModel.swift
//  Planto
//
//  Created by Dana AlGhadeer on 26/10/2025.
//

import SwiftUI
import Combine

@MainActor
final class PlantStore: ObservableObject {
    @Published var plants: [Plant] = []{
        didSet {
            save()
        }
      
    }
        init() {
            load()
            refreshDailyState()
//            // After loading saved plants, re-create notifications for them
//            Task { @MainActor in
//                for p in plants {
//                    NotificationManager.instance.schedule(for: p)
//                }
//            }
        }
        
        func add(_ plant: Plant){
            plants.append(plant)
            // Schedule repeating notification for this plant
            NotificationManager.instance.scheduleNotification(for: plant.name, after: plant.wateringDays.intervalDays)
        }
        
        func update(_ plant: Plant){
            guard let i = plants.firstIndex(where: { $0.id == plant.id}) else { return }
            plants[i] = plant
//            // Replace existing notification with updated interval/content
//            NotificationManager.instance.cancel(for: plant.id)
//            NotificationManager.instance.schedule(for: plant)
        }
        
        func remove(at offsets: IndexSet){
            let removed = offsets.map { plants[$0] }
            plants.remove(atOffsets: offsets)
//            for p in removed {
//                NotificationManager.instance.cancel(for: p.id)
//            }
        }
        
        func remove(id: UUID){
            if let i = plants.firstIndex(where: { $0.id == id}) {
                let removed = plants[i]
                plants.remove(at: i)
//                NotificationManager.instance.cancel(for: removed.id)
            }
        }
        
        // MARK: - checkmark & daily logic
        func toggleWatered(for plantID: UUID) {
            guard let i = plants.firstIndex(where: { $0.id == plantID }) else { return }
            if plants[i].isWateredToday {
                plants[i].isWatered = false
                plants[i].lastWateredAt = nil
            } else {
                plants[i].isWatered = true
                plants[i].lastWateredAt = Date()
            }
//            // Optional: reschedule to keep “interval since last water” feel
//            let plant = plants[i]
//            NotificationManager.instance.cancel(for: plant.id)
//            NotificationManager.instance.schedule(for: plant)
        }
        
        func refreshDailyState() {
            for i in plants.indices {
                if plants[i].isWatered && !plants[i].isWateredToday {
                    plants[i].isWatered = false
                }
            }
        }

        //MARK: for TodayReminder
        
        var completedCount: Int {
            plants.filter { $0.isWateredToday}.count
        }
     
        var progressVal: Double {
            guard !plants.isEmpty else { return 0 }
            return Double(completedCount) / Double(plants.count)
        }
        
        var statusLine: String {
            let n = completedCount
            return n==0
            ? "Your plants are waiting for a sip 💦"
            : "\(n) of your plants feel loved today ✨"
        }
        
        var isAllDone: Bool {
            !plants.isEmpty && completedCount == plants.count
        }
        
        // MARK: - Simple Persistence (JSON on disk)
        private var saveUrl: URL {
            let fm = FileManager.default
            let dir = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
            return dir.appendingPathComponent("plants.json")
        }
        
        private func load(){
            let url = saveUrl
            guard FileManager.default.fileExists(atPath: url.path) else {
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([Plant].self, from: data)
                self.plants = decoded
            } catch {
                self.plants = []
            }
        }
        
        private func save(){
            do {
                let data = try JSONEncoder().encode(self.plants)
                try data.write(to: saveUrl)
            } catch {
                // Ignore write errors for now
            }
        }
    }


