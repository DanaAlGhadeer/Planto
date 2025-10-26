//
//  ContentView.swift
//  Planto
//
//  Created by Dana AlGhadeer on 19/10/2025.
//

import SwiftUI

struct ContentView: View {
    //UI state
    @State private var showSetReminderSheet = false
    @State private var goToTodayReminder = false
    
    //Form state
    @State private var plantName = ""
    @State private var room: Room = .bedroom
    @State private var wateringDays: WateringDays = .everyDay
    @State private var water: Water = .ml20to50
    @State private var light: Light = .fullSun
    
    @State private var createdPlant: Plant? = nil
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .topLeading){
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12){
                        Text("My Plants 🌱")
                            .foregroundColor(.white)
                            .font(.system(size: 34, weight: .bold, design: .default ))
                        
                        Divider()
                            .background(Color.gray)
                    }
                    .padding(.leading, 8)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                    
                    Image("planto")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 164, height: 200)
                    
                    Text("Start your plant journey!")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Now all your plants will be in one place and we will help you take care of them :) 🪴")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    Button(action: {
                        showSetReminderSheet.toggle()
                    })  {
                        Text("Set Plant Remainder")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(Color.white)
                            .frame(width: 280, height: 41)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.mintG)
                    .padding(.bottom, 140)
                }
            }
            // Navigate to TodayReminder once a plant is created
            .navigationDestination(isPresented: $goToTodayReminder) {
                TodayReminder(initialPlant: createdPlant)
            }
        }
        // Present the SetRemainderSheet
        .sheet(isPresented: $showSetReminderSheet){
            SetRemainderSheet(
                plantName: $plantName,
                room: $room,
                light: $light,
                wateringDays: $wateringDays,
                water: $water,
                onSave: { plant in
                    // Capture the created plant
                    createdPlant = plant
                    // Reset form state for next time
                    plantName = ""
                    room = .bedroom
                    light = .fullSun
                    wateringDays = .everyDay
                    water = .ml20to50
                    // Trigger navigation to TodayReminder
                    goToTodayReminder = true
                }
            )
        }
    }
}

#Preview {
    NavigationStack{ ContentView() }
}
