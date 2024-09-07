//
//  NetworkManager.swift
//  AirHush
//
//  Created by Max Veerhoek on 13/05/2024.
//

import Foundation
import Network
import CoreWLAN

class NetworkManager: ObservableObject {
  @Published var isMonitoring: Bool {
    didSet {
      // Save the isMonitoring value to UserDefaults whenever it changes
      UserDefaults.standard.set(isMonitoring, forKey: "isMonitoring")
    }
  }
  
  private var monitor: NWPathMonitor?
  private var wifiInterface: CWInterface?
  
  init() {
    // Load the isMonitoring value from UserDefaults when the app starts
    self.isMonitoring = UserDefaults.standard.bool(forKey: "isMonitoring")
    wifiInterface = CWWiFiClient.shared().interface()
    startMonitoring()
  }
  
  func startMonitoring() {
    monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    monitor?.pathUpdateHandler = { path in
      if self.isMonitoring {
        if path.usesInterfaceType(.wiredEthernet) {
          // Ethernet is active
          self.disableWiFiAndHideIcon()
        } else {
          // Wi-Fi is active or no Ethernet
          self.enableWiFiAndShowIcon()
        }
      }
    }
    monitor?.start(queue: queue)
  }
  
  func stopMonitoring() {
    monitor?.cancel()
    monitor = nil
  }
  
  func toggleMonitoring() {
    isMonitoring.toggle()
    if isMonitoring {
      startMonitoring()
    } else {
      stopMonitoring()
    }
  }
  
  func disableWiFiAndHideIcon() {
    guard let wifiInterface = wifiInterface else { return }
    do {
      try wifiInterface.setPower(false)
    } catch {
      print("Error disabling WiFi: \(error)")
    }
    
//    // Hide the Wi-Fi icon
//    runAppleScript(named: "HideWiFiIcon")
//    
//    // Restart SystemUIServer to apply changes
//    restartSystemUIServer()
  }
  
  func enableWiFiAndShowIcon() {
    guard let wifiInterface = wifiInterface else { return }
    do {
      try wifiInterface.setPower(true)
    } catch {
      print("Error enabling WiFi: \(error)")
    }
  }
}
