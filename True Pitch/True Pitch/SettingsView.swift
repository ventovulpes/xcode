//
//  SettingsView.swift
//  True Pitch
//
//  Created by A on 8/4/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query var attempts: [AttemptItem]
    
    @AppStorage("useSquareSound") var useSquareSound: Bool = true
    @AppStorage("usePianoSound") var usePianoSound: Bool = true
    
    @AppStorage("octave2") var octave2: Bool = true
    @AppStorage("octave3") var octave3: Bool = true
    @AppStorage("octave4") var octave4: Bool = true
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        Form {
            Section (header: Text("Note Sounds")) {
                Toggle("Square Sound", isOn: $useSquareSound)
                Toggle("Piano Sound", isOn: $usePianoSound)
            }
            /*
            Section (header: Text("Octave")) {
                Toggle("C2-B2", isOn: $octave2)
                Toggle("C3-B3", isOn: $octave3)
                Toggle("C4-B4", isOn: $octave4)
            }
             */
            Section (header: Text("Data")) {
                Button(action: {
                                showAlert = true
                            }) {
                                Text("Delete All Data")
                                    .foregroundColor(Color.red)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("This action will delete all your past attempts."),
                                    primaryButton: .destructive(Text("Delete")) {
                                        deleteAllData()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
            }
        }
        .navigationTitle("Settings")
    }
    private func deleteAllData() {
        for attempt in attempts {
            context.delete(attempt)
        }

        do {
            try context.save()
        } catch {
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    //SettingsView(attempts: <#[AttemptItem]#>)
}
