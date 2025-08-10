//
//  AttemptItem.swift
//  True Pitch
//
//  Created by A on 7/31/25.
//

import Foundation
import SwiftData

@Model
class AttemptItem: Identifiable {
    
    var id: String
    var result: Bool
    var note: Int
    var normalNote: Int {
        (note >= 0 ? note % 12 : (12 - (abs(note) % 12)))
    }
    var guess: Int?
    var normalGuess: Int {
        (guess! >= 0 ? guess! % 12 : (12 - (abs(guess!) % 12)))
    }
    var date: Date
    var isFirstAttempt: Bool
    
    init(result: Bool, note: Int, guess: Int?, date: Date, isFirstAttempt: Bool) {
        
        self.id = UUID().uuidString
        self.result = result
        self.note = note
        self.guess = (guess == nil ? note : guess)
        self.date = date
        self.isFirstAttempt = isFirstAttempt
    }
}
