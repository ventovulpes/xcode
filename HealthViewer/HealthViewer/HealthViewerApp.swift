//
//  HealthViewerApp.swift
//  HealthViewer
//
//  Created by A on 10/25/25.
//

import SwiftUI

@main
struct HealthViewerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: HealthViewerDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
