//
//  DataByNoteView.swift
//  True Pitch
//
//  Created by A on 8/3/25.
//

import SwiftUI
import SwiftData

struct DataByNoteView: View {
    @Query var attempts: [AttemptItem]
    
    var body: some View {
        List {
            let data = Dictionary(grouping: attempts) {
                Notes.allNoteNames[$0.normalNote]
            }
            
            ForEach(Notes.allNoteNames, id: \.self) { note in
                let correct = data[note]?.filter{ $0.result }.count
                let total = data[note]?.count
                Text("\(note): \(correct ?? 0) / \(total ?? 0)")
            }
        }
        .navigationTitle("Data By Note")
    }
}

#Preview {
    DataByNoteView()
}
