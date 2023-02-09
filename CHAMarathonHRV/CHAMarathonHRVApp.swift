//
//  CHAMarathonHRVApp.swift
//  CHAMarathonHRV
//
//  Created by Alex Cruikshank on 1/21/23.
//

import SwiftUI

@main
struct CHAMarathonHRVApp: App {
  @StateObject private var dataManager = DataManager()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(dataManager)
    }
  }
}
