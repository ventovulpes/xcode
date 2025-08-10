//
//  HistoryView.swift
//  True Pitch
//
//  Created by A on 7/31/25.
//
import Foundation
import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext) public var context
    
    @Query(sort: [SortDescriptor(\AttemptItem.date, order: .reverse)])
    var attempts: [AttemptItem]
    var firstAttempts: [AttemptItem] {
        attempts.filter {
            $0.isFirstAttempt
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    @AppStorage("filterFirstAttempt") var filterFirstAttempts: Bool = false
    
    var body: some View {
        VStack {
            Text("\(Int(getNumCorrect(filterFirstAttempts ? firstAttempts : attempts)))/\(Int(getTotalAttempts(filterFirstAttempts ? firstAttempts : attempts)))")
            
            let percentage: Double = Double(getNumCorrect(filterFirstAttempts ? firstAttempts : attempts))/Double(getTotalAttempts(filterFirstAttempts ? firstAttempts : attempts))*100
            Text(String(format: "%.2f", getTotalAttempts(attempts) == 0 ? 0.00 : percentage) + "%")
            
            List (filterFirstAttempts ? firstAttempts : attempts) { attempt in
                NavigationLink(destination: AttemptDetailsView(attempt)) {
                    HStack {
                        Image(systemName: attempt.result ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                        Spacer()
                        Text(dateFormatter.string(from: attempt.date))
                        if (attempt.isFirstAttempt) {
                            Image(systemName: "star.fill")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Delete", systemImage: "trash", role: .destructive, action: {
                            deleteAttempt(attempt)
                        })
                    }
                }
            }
            .navigationTitle("History")
            
            Toggle(isOn: $filterFirstAttempts) {
                Text("Filter First Attempts")
            }
            .tint(Color.accentColor)
            .padding(10)
        }
    }
    
    private func deleteAttempt(_ attempt: AttemptItem) {
        context.delete(attempt)
    }
    
    private func getNumCorrect(_ attempts: [AttemptItem]) -> Double {
        return Double(attempts.filter{$0.result}.count)
    }
    
    private func getTotalAttempts(_ attempts: [AttemptItem]) -> Double {
        return Double(attempts.count)
    }
}

#Preview {
    HistoryView()
}
