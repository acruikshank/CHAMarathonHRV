//
//  ContentView.swift
//  CHAMarathonHRV
//
//  Created by Alex Cruikshank on 1/21/23.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var dataManager: DataManager

  var body: some View {
        VStack {
            Text("Hello, world!")
        }
        .padding()
//        .onAppear {
//          dataManager.startScanning()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
