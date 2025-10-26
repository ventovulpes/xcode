//
//  SleepParser.swift
//  HealthViewer
//
//  Created by A on 10/25/25.
//

import Foundation

struct SleepRecord {
    var type: String
    var value: String
    var date: Date
    var startTime: Date
    var endTime: Date
}

final class SleepParser: Parser {
    private(set) var sleepRecords: [SleepRecord] = []
    
    private lazy var dateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
    
    let dateFormatter = DateFormatter()

    let timeFormatter = DateFormatter()
    
    override init() {
        dateFormatter.dateFormat = "MM-dd-yy"
        timeFormatter.dateFormat = "HH:mm:ss"
        super.init()
    }
    
    func parse(_ data: Data) throws -> [SleepRecord] {
        sleepRecords.removeAll()
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw parser.parserError ?? NSError(domain: "XML", code: 1)
        }
        return sleepRecords
    }
    
    override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        guard elementName == "Record" else { return }
        
        guard let type = attributeDict["type"] else { return }
        if !type.hasPrefix("HKCategoryTypeIdentifierSleepAnalysis") { return }
        
        guard
            let valueString = attributeDict["value"],
            let value = valueString == "HKCategoryValueSleepAnalysisInBed" ? "In Bed" :
                valueString == "HKCategoryValueSleepAnalysisAwake" ? "Awake" :
                valueString == "HKCategoryValueSleepAnalysisAsleepREM" ? "REM Sleep" :
                valueString == "HKCategoryValueSleepAnalysisAsleepCore" ? "Core Sleep" :
                valueString == "HKCategoryValueSleepAnalysisAsleepDeep" ? "Deep Sleep" : "Unknown",
            let date = dateAndTimeFormatter.date(from: attributeDict["startDate"] ?? ""),
            let startTime = dateAndTimeFormatter.date(from: attributeDict["startDate"] ?? ""),
            let endTime = dateAndTimeFormatter.date(from: attributeDict["endDate"] ?? "")
            
        else { return }
        
        sleepRecords.append(SleepRecord(type: type, value: value, date: date, startTime: startTime, endTime: endTime))
    }
    
    override func parseData(_ data: Data?) -> OutputDocument {
        do {
            sleepRecords = try parse(data!)
            let header = "type,value,date,startTime,endTime\n"
            let csvBody = sleepRecords.map { "\($0.type),\($0.value),\(dateFormatter.string(from: $0.date)),\(timeFormatter.string(from: $0.startTime)),\(timeFormatter.string(from: $0.endTime))" }.joined(separator: "\n")
            let csv = header + csvBody
            let out: OutputDocument = OutputDocument(text: csv)
            return out
        } catch {
            return OutputDocument()
        }
    }
}
