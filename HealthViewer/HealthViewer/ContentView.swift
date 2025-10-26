//
//  ContentView.swift
//  HealthViewer
//
//  Created by A on 10/25/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: HealthViewerDocument
    @State private var size: String?
    @State private var showingExporter: Bool = false
    @State private var result: OutputDocument?
    @State private var filterText: String = "HKQuantityTypeIdentifierHeartRateVariabilitySDNN"
    @State private var exportDate: String?
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
    
    enum Filter: String {
        case hrv = "HKQuantityTypeIdentifierHeartRateVariabilitySDNN"
        case heartRate = "HKQuantityTypeIdentifierHeartRate"
        case sleep = "HKCategoryTypeIdentifierSleepAnalysis"
    }

    var body: some View {
        var parser = Parser()
        if document.text.isEmpty {
            Text("No data yet")
        } else {
            VStack (alignment: .leading){
                Text(size ?? "")
                    .textSelection(.enabled)
                Spacer()
                Text("Filter")
                TextField(Filter.hrv.rawValue, text: $filterText)
                    .onChange(of: filterText) {
                        parser.filter = filterText
                    }
                Menu("Preset Filters") {
                    Button("HRV") {
                        filterText = Filter.hrv.rawValue
                    }
                    Button("Heart Rate") {
                        filterText = Filter.heartRate.rawValue
                    }
                    Button("Sleep") {
                        filterText = Filter.sleep.rawValue
                    }
                }
                Spacer()
                Button("Parse") {
                    let text: String? = $document.text.wrappedValue
                    let data: Data? = text?.data(using: .utf8)
                    size = "Loaded \(data?.count ?? 0) bytes"
                    if (filterText == Filter.sleep.rawValue) {
                        parser = SleepParser()
                    }
                    result = parser.parseData(data)
                    showingExporter = true
                }
                .fileExporter(isPresented: $showingExporter, document: result, defaultFilename: "\(filterText == Filter.hrv.rawValue ? "HRV" : filterText ==  Filter.heartRate.rawValue ? "HeartRate" : filterText == Filter.sleep.rawValue ? "Sleep" : filterText)_data") { result in
                    switch result {
                        case .success(let url):
                            print("Saved to \(url)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                }
            }
            .padding(30)
        }
    }
}

#Preview {
    ContentView(document: .constant(HealthViewerDocument()))
}
