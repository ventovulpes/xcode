//
//  Parser.swift
//  HealthViewer
//
//  Created by A on 10/25/25.
//

import Foundation

struct Record {
    var type: String
    var value: Double
    var startDate: Date
}

class Parser: NSObject, XMLParserDelegate {
    private(set) var records: [Record] = []
    
    public var filter: String = "HKQuantityTypeIdentifierHeartRateVariabilitySDNN"
    
    private lazy var dateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return formatter
    }()
    
    func parse(_ data: Data) throws -> [Record] {
        records.removeAll()
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse() else {
            throw parser.parserError ?? NSError(domain: "XML", code: 1)
        }
        return records
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        guard elementName == "Record" else { return }
        
        guard let type = attributeDict["type"] else { return }
        if !type.hasPrefix(filter) { return }
        
        guard
            let valueString = attributeDict["value"],
            let value = Double(valueString),
            let date = dateAndTimeFormatter.date(from: attributeDict["startDate"] ?? "")
        else { return }
        
        records.append(Record(type: type, value: value, startDate: date))
    }
    
    func parseData(_ data: Data?) -> OutputDocument {
        do {
            records = try parse(data!)
            let header = "type,value,startDate\n"
            let csvBody = records.map { "\($0.type),\($0.value),\($0.startDate)" }.joined(separator: "\n")
            let csv = header + csvBody
            let out: OutputDocument = OutputDocument(text: csv)
            return out
        } catch {
            return OutputDocument()
        }
    }
}
