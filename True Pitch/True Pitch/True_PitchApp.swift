//
//  True_PitchApp.swift
//  True Pitch
//
//  Created by A on 7/30/25.
//

import SwiftUI
import SwiftData

@main
struct True_PitchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: AttemptItem.self)
    }
}
