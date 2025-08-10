//
//  ContentView.swift
//  True Pitch
//
//  Created by A on 7/30/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query var attempts: [AttemptItem]
    
    var numCorrect: Int {
        attempts.filter{$0.result}.count
    }
    var totalAttempts: Int {
        attempts.count
    }
    
    let flashTransitionTime: Double = 0.2
    let maxFlashOpacity: Double = 0.25
    
    @AppStorage("isFirstAttempt") var isFirstAttempt: Bool = true
    @AppStorage("useSquareSound") private var useSquareSound: Bool = true
    @AppStorage("usePianoSound") private var usePianoSound: Bool = true
    
    @State var soundType: Int? = nil
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Toggle(isOn: $isFirstAttempt) {
                        }
                        .tint(Color.accentColor)
                        Spacer()
                        NavigationLink(destination: GraphsView()) {
                            Image(systemName: "chart.bar")
                        }
                        NavigationLink(destination: HistoryView()) {
                            Image(systemName: "list.bullet")
                                .fontWeight(.bold)

                                    
                        }
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                        }
                    }
                    Spacer()
                    Text("\(numCorrect)/\(totalAttempts)")
                        .font(.largeTitle)
                    let percentage: Double = Double(numCorrect)/Double(totalAttempts)*100
                    Text(String(format: "%.2f", totalAttempts == 0 ? 0.00 : percentage) + "%")
                        .font(.title3)
                    LazyVGrid(columns: columns) {
                        ForEach(Notes.allNoteNames, id: \.self) { note in
                            Button(action: {
                                answerButton(for: note)
                            }) {
                                Text(note)
                                    .font(.largeTitle)
                                    .frame(maxWidth: .infinity)
                                    .containerRelativeFrame(.vertical) { size, axis in
                                        size * 0.1
                                    }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.bottom, 20.0)
                    HStack {
                        Button(action: {nextNote()}) {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.largeTitle)
                                .padding(.top, 10.0)
                                .padding(.bottom, 10.0)
                        }
                        Button(action: {playNote()}) {
                            Text("Play")
                                .frame(maxWidth: .infinity)
                                .font(.largeTitle)
                                .padding(10.0)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                }
                .padding(20.0)
                Color.green
                    .opacity(flashGreenTrigger ? maxFlashOpacity : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: flashTransitionTime), value: flashGreenTrigger)
                Color.red
                    .opacity(flashRedTrigger ? maxFlashOpacity: 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: flashTransitionTime), value: flashRedTrigger)
            }
        }
        .accentColor(.teal)
    }
    
    let sounds = Sounds()
    
    let flashDuration: Double = 0.25
    @State var currentNoteID = Int.random(in: -11..<12)
    var currentNote: String {
        return Notes.allNoteNames[currentNoteID >= 0 ? currentNoteID % 12 : (12 - (abs(currentNoteID) % 12))]
    }
    
    
    @State var flashGreenTrigger = false
    @State var flashRedTrigger = false
    
    private func answerButton(for button : String) {
        if button == currentNote {
            addToHistory(noteID: currentNoteID)
            correctAnswer()
        } else {
            addToHistory(result: false, noteID: currentNoteID, guess: Notes.allNoteNames.firstIndex(where: { $0 == button}))
            redFlash()
        }
        
        if (isFirstAttempt) { isFirstAttempt = false }
    }
    
    private func correctAnswer() {
        greenFlash()
        
        nextNote()
    }
    
    private func playNote() {
        if (soundType == nil) {
            if (useSquareSound && usePianoSound) {
                soundType = Int.random(in: 0...1) == 0 ? 0 : 1
            } else if (useSquareSound) {
                soundType = 0
            } else if (usePianoSound) {
                soundType = 1
            } else {
                soundType = -1
            }
        }
        
        sounds.play(soundType: soundType!, pitch: currentNoteID)
    }
    
    private func nextNote() {
        soundType = nil
        let lastNote = currentNoteID
        while lastNote == currentNoteID {
            currentNoteID = Int.random(in: -11..<24)
        }
        playNote()
    }
    
    private func addToHistory(result: Bool = true, noteID: Int, guess: Int? = nil) {
        
        let attempt = AttemptItem(result: result, note: noteID, guess: guess, date: Date(), isFirstAttempt: isFirstAttempt)
        context.insert(attempt)
    }
    
    private func greenFlash() {
        flashGreenTrigger = true
        DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
            self.flashGreenTrigger = false
        }
    }
    
    private func redFlash() {
        flashRedTrigger = true
        DispatchQueue.main.asyncAfter(deadline: .now() + flashDuration) {
            self.flashRedTrigger = false
        }
    }
}

#Preview {
    ContentView()
}
