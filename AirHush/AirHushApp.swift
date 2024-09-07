//
//  AirHushApp.swift
//  AirHush
//
//  Created by Max Veerhoek on 13/05/2024.
//

import SwiftUI
import ServiceManagement

@main
struct AirHushApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
  @StateObject private var networkManager = NetworkManager()
  @State private var launchAtStartup = false // Track if the app launches at startup
  
  init() {
    // Check if the app is set to launch at startup when the app starts
    if #available(macOS 13.0, *) {
      let appService = SMAppService.mainApp
      launchAtStartup = appService.status == .enabled
    }
  }
  
  var body: some Scene {
    MenuBarExtra("Network Manager", systemImage: "wifi") {
      // Toggle for enabling/disabling network monitoring
      Toggle("Monitoring", isOn: $networkManager.isMonitoring)
      
      Divider()
      
      Toggle("Launch at Startup", isOn: $launchAtStartup)
        .onChange(of: launchAtStartup) { value in
          toggleLaunchAtStartup(value)
        }
      
      Divider()
      
      Button("Quit") {
        NSApplication.shared.terminate(nil)
      }
    }
  }
    
    // Function to toggle launch at startup
    func toggleLaunchAtStartup(_ shouldLaunch: Bool) {
      if #available(macOS 13.0, *) {
        let appService = SMAppService.mainApp
        do {
          if shouldLaunch {
            try appService.register()
            print("Application set to launch at startup.")
          } else {
            try appService.unregister()
            print("Application removed from startup.")
          }
        } catch {
          print("Failed to set application as a login item: \(error)")
        }
      }
    }
}
