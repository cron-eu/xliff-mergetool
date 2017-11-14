//
//  XliffFile.swift
//  XliffConverter
//
//  Created by Remus Lazar on 21.09.17.
//  Copyright © 2017 cron.eu. All rights reserved.
//

import Foundation

public struct XliffFile {
    
    public init(xmlURL: URL) throws {
        self.filename = xmlURL.lastPathComponent
        xmlDocument = try XMLDocument(contentsOf: xmlURL, options: [])
    }
    
    public enum XliffParseError: Error {
        case malformedHeader
    }
    
    struct TransUnit {
        let xmlElement: XMLElement
        let fileName: String
        
        var id: String { return xmlElement.attribute(forName: "id")!.stringValue! }
        
        var sourceElement: XMLElement { return xmlElement.elements(forName: "source").first! }
        var source: String { return sourceElement.stringValue! }

        var targetElement: XMLElement {
            if let existingElement = xmlElement.elements(forName: "target").first {
                return existingElement
            } else {
                let element = XMLElement(name: "target")
                xmlElement.insertChild(element, at: 1)
                return element
            }
        }
        var target: String { return targetElement.stringValue! }
        
        init(_ xmlElement: XMLElement) {
            self.xmlElement = xmlElement
            let fileElement = xmlElement.parent!.parent as! XMLElement
            guard fileElement.name == "file" else {
                fatalError("XLIFF structure error")
            }
            guard let fileName = fileElement.attribute(forName: "original")?.stringValue else {
                fatalError("XLIFF structure error, original attribute of the file element is missing")
            }
            self.fileName = fileName
        }
    }
    
    var transUnits: [TransUnit] {
        return try! xmlDocument.rootElement()!.nodes(forXPath: "//trans-unit").map { TransUnit($0 as! XMLElement) }
    }
    
    let filename: String
    
    public var targetLanguage: String? {
        didSet {
            if let targetLanguage = targetLanguage {
                xmlDocument.rootElement()!.elements(forName: "file").forEach { (file) in
                    file.addAttribute(XMLNode.attribute(withName: "target-language", stringValue: targetLanguage) as! XMLNode)
                }
            }
        }
    }
    
    private let xmlDocument: XMLDocument
}

extension XliffFile: CustomStringConvertible {
    public var description: String {
        return "file: \(filename): \(transUnits.count) trans-unit(s)"
    }
}

extension XliffFile.TransUnit: Equatable {
   static func ==(lhs: XliffFile.TransUnit, rhs: XliffFile.TransUnit) -> Bool {
        return lhs.id == rhs.id && lhs.fileName == rhs.fileName
    }
}

extension XliffFile.TransUnit: CustomStringConvertible {
    var description: String {
        return "[\(id)] \(source)"
    }
}

extension XliffFile {
    public var xmlData: Data {
        return xmlDocument.xmlData(options: [.nodePrettyPrint])
    }
}

extension XliffFile {
    
    /// generic merge function: find all matching transUnits in the current file and apply the handler
    func merge(from source: XliffFile, handler: (_ sourceTransUnit: TransUnit, _ toMergeTransUnit: TransUnit) -> Void) {
        let sourceTransunits = source.transUnits
        transUnits.forEach { transUnit in
            if let matchingTranlatedTransunit = sourceTransunits.first(where: { $0 == transUnit }) {
                // if we were able to found a match, take the translated unit and set it as source
                handler(transUnit, matchingTranlatedTransunit)
            }
        }
    }
    
    /// Modify the file in place and merge existing translations from the supplied file
    public func mergeExistingTranslations(from source: XliffFile) {
        merge(from: source) { (transUnit, matchingTranlatedTransunit) in
            transUnit.targetElement.setStringValue(matchingTranlatedTransunit.target, resolvingEntities: false)
        }
    }
    
    /// Modify the file in place and merge existing translations in the supplied file as source (cross translate)
    public func mergeTargetIntoSource(from source: XliffFile) {
        merge(from: source) { (transUnit, matchingTranlatedTransunit) in
            transUnit.sourceElement.setStringValue(matchingTranlatedTransunit.target, resolvingEntities: false)
        }
    }
}
