//
//  AttemptDetailsView.swift
//  True Pitch
//
//  Created by A on 8/1/25.
//

import SwiftUI
import SwiftData

struct AttemptDetailsView: View {
    
    var attempt: AttemptItem
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    init(_ attempt: AttemptItem) {
        self.attempt = attempt
    }
    
    var body: some View {
        List {
            Section(header: Text("Attempt Details")) {
                VStack (alignment: .leading) {
                    Text("Note")
                        .font(.caption)
                    Text(Notes.allNoteNames[attempt.normalNote])
                }
                VStack (alignment: .leading) {
                    Text("Result")
                        .font(.caption)
                    Text(attempt.result ? "Correct" : "Incorrect")
                }
                VStack (alignment: .leading) {
                    Text("Guess")
                        .font(.caption)
                    Text(Notes.allNoteNames[attempt.normalGuess])
                }
                VStack (alignment: .leading) {
                    Text("Date")
                        .font(.caption)
                    Text(dateFormatter.string(from: attempt.date))
                }
                VStack (alignment: .leading) {
                    Text("First Attempt")
                        .font(.caption)
                    Text(attempt.isFirstAttempt ? "Yes" : "No")
                }
            }
        }
        .navigationTitle("Details")
    }
}

#Preview {
    //AttemptDetailsView()
}
