//
//  GraphsView.swift
//  True Pitch
//
//  Created by A on 7/31/25.
//

import SwiftUI
import SwiftData
import Charts

struct GraphsView: View {
    @Environment(\.modelContext) public var context
    
    @Query(sort: [SortDescriptor(\AttemptItem.date, order: .reverse)])
    var attempts: [AttemptItem]
    var firstAttempts: [AttemptItem] {
        attempts.filter {
            $0.isFirstAttempt
        }
    }
    
    var percentageByDate: [Date: Double] {
        let grouped = Dictionary(grouping: attempts) {
            Calendar.current.startOfDay(for: $0.date)
        }

        return grouped.mapValues { group in
            let correct = group.filter(\.result).count
            return (Double(correct) / Double(group.count))
        }
    }
    
    var percentageByNote: [String: Double] {
        let grouped = Dictionary(grouping: attempts) {
            Notes.allNoteNames[$0.normalNote]
        }
        
        return grouped.mapValues { group in
            let correct = group.filter(\.result).count
            return (Double(correct) / Double(group.count))
        }
    }
    
    var firstAttemptPercentageByNote: [String: Double] {
        let grouped = Dictionary(grouping: attempts.filter{ $0.isFirstAttempt }) {
            Notes.allNoteNames[$0.normalNote]
        }
        
        return grouped.mapValues { group in
            let correct = group.filter{ $0.result && $0.isFirstAttempt }.count
            return (Double(correct) / Double(group.count))
        }
    }
    
    var movingAverage: [Date: Double] {
        let sortedDates = percentageByDate.keys.sorted()
        
        var result = [Date: Double]()
            var valuesWindow = [Double]()

        for (_, date) in sortedDates.enumerated() {
                let currentValue = percentageByDate[date] ?? 0
                valuesWindow.append(currentValue)

                if valuesWindow.count > movingAverageDays {
                    valuesWindow.removeFirst()
                }

                let avg = valuesWindow.reduce(0, +) / Double(valuesWindow.count)
                result[date] = avg
            }

            return result
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    @AppStorage("movingAverageDays") var movingAverageDays: Int = 7
    
    var body: some View {
        List {
            Section ("Overall") {
                Chart {
                    ForEach(Notes.allNoteNames, id: \.self) { note in
                        let percentage = percentageByNote[note] ?? 0.0
                        BarMark(
                            x: .value("Note", note),
                            y: .value("Percentage", percentage)
                        )
                    }
                }
                .padding()
                .chartYScale(domain: 0...1)
            }
            Section ("First Attempt") {
                Chart {
                    ForEach(Notes.allNoteNames, id: \.self) { note in
                        let percentage = firstAttemptPercentageByNote[note] ?? 0.0
                        BarMark(
                            x: .value("Note", note),
                            y: .value("Percentage", percentage)
                        )
                    }
                }
                .padding()
                .chartYScale(domain: 0...1)
            }
            Section ("Percentage By Day") {
                Chart {
                    ForEach(Array(percentageByDate).sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        BarMark(
                            x: .value("Date", dateFormatter.string(from:key)),
                            y: .value("Percentage", value)
                        )
                    }
                }
                .padding()
                .chartYScale(domain: 0...1)
            }
            Section ("Moving Average") {
                VStack {
                    Chart {
                        ForEach(Array(movingAverage), id: \.key) { key, value in
                            LineMark(
                                x: .value("Date", dateFormatter.string(from:key)),
                                y: .value("Percentage", value)
                            )
                        }
                    }
                    .padding()
                    if percentageByDate.count > 0
                    {
                        Stepper(value: $movingAverageDays, in: 1...percentageByDate.count) {
                            Text("\(movingAverageDays) day sliding window")
                        }
                    }
                }
            }
        }
        .navigationTitle("Graphs")
        .toolbar() {
            NavigationLink(destination: DataByNoteView()) {
                Image(systemName: "music.note")
            }
        }
    }
}

#Preview {
    GraphsView()
}
