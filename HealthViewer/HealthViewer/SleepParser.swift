//
//  SleepParser.swift
//  HealthViewer
//
//  Created by A on 10/25/25.
//

import Foundation

struct SleepRecord {
    var type: String
    var value: SleepType
    var startTime: Date
    var endTime: Date
}

enum SleepType: String {
    case inBed = "HKCategoryValueSleepAnalysisInBed"
    case isAwake = "HKCategoryValueSleepAnalysisAwake"
    case remSleep = "HKCategoryValueSleepAnalysisAsleepREM"
    case coreSleep = "HKCategoryValueSleepAnalysisAsleepCore"
    case deepSleep = "HKCategoryValueSleepAnalysisAsleepDeep"
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
        dateFormatter.dateFormat = "E MM/dd/yy"
        timeFormatter.dateFormat = "hh:mm:ss"
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
            let value = SleepType(rawValue: valueString),
            let startTime = dateAndTimeFormatter.date(from: attributeDict["startDate"] ?? ""),
            let endTime = dateAndTimeFormatter.date(from: attributeDict["endDate"] ?? "")
            
        else { return }
        
        sleepRecords.append(SleepRecord(type: type, value: value, startTime: startTime, endTime: endTime))
    }
    
    override func parseData(_ data: Data?) -> OutputDocument {
        do {
            sleepRecords = try parse(data!)
            let header = "Day,InBed,Awake,REMSleep,CoreSleep,DeepSleep,Start,End\n"
            var csvBody: String = ""
            
            let calendar = Calendar.current
            
            func nightKey(for date: Date) -> Date{
                calendar.startOfDay(for: date.addingTimeInterval(6 * 3600))
            }
            var curNightKey: Date? = nil

            struct SleepSummary {
                var inBed: Double
                var awake: Double
                var rem: Double
                var core: Double
                var deep: Double
            }
            var sleep = SleepSummary(inBed: 0, awake: 0, rem: 0, core: 0, deep: 0)
            var sleepStart = Date()
            var sleepEnd = Date()
            for record in sleepRecords {
                let key = nightKey(for: record.startTime)
                if curNightKey == nil || key != curNightKey {
                    if let k = curNightKey {
                        csvBody +=
                        "\(dateFormatter.string(from: k)), \(sleep.inBed / 60), \(sleep.awake / 60), \(sleep.rem / 60), \(sleep.core / 60), \(sleep.deep / 60), \(timeFormatter.string(from: sleepStart)), \(timeFormatter.string(from: sleepEnd))\n"
                    }
                    curNightKey = key
                    sleep = .init(inBed: 0, awake: 0, rem: 0, core: 0, deep: 0)
                    sleepStart = record.startTime
                }
                let duration = record.endTime.timeIntervalSince(record.startTime)
                switch record.value {
                case SleepType.inBed: sleep.inBed += duration
                case SleepType.isAwake: sleep.awake += duration
                case SleepType.remSleep: sleep.rem += duration
                case SleepType.coreSleep: sleep.core += duration
                case SleepType.deepSleep: sleep.deep += duration
                }
                sleepEnd = record.endTime
            }
            /*
            let header = "type,value,date,startTime,endTime\n"
            let csvBody = sleepRecords.map { "\($0.type),\($0.value),\(dateFormatter.string(from: $0.date)),\(timeFormatter.string(from: $0.startTime)),\(timeFormatter.string(from: $0.endTime))" }.joined(separator: "\n")
            */
            let csv = header + csvBody
            let out: OutputDocument = OutputDocument(text: csv)
            return out
        } catch {
            return OutputDocument()
        }
    }
}
