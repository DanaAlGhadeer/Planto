//
//  PlantoApp.swift
//  Planto
//
//  Created by Dana AlGhadeer on 19/10/2025.
//

import SwiftUI

@main
struct PlantoApp: App {
    
    @StateObject private var store = PlantStore()
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView()
            }
            .onAppear {
                NotificationManager.instance.requestAuthorization()
            }
            .environmentObject(store)
        }
    }
}
