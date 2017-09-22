//
//  main.swift
//  XliffConverter
//
//  Created by Remus Lazar on 21.09.17.
//  Copyright © 2017 cron.eu. All rights reserved.
//

import Foundation
import XLIFFMergeTool

guard CommandLine.argc == 3 else {
    print("Usage: \(CommandLine.arguments.first!) <devlang.xliff> <translated.xliff>")
    exit(1)
}

do {
    let devlangXML = try XliffFile(xmlURL: URL(fileURLWithPath: CommandLine.arguments[1]))
    let translatedXML = try XliffFile(xmlURL: URL(fileURLWithPath: CommandLine.arguments[2]))
    
    print("Developer Language XLIFF loaded: \(devlangXML)")
    print("Translated Language XLIFF loaded: \(translatedXML)")

    devlangXML.mergeTargetIntoSource(from: translatedXML)
    
    let output = String(data: devlangXML.xmlData, encoding: .utf8)!
    print(output)
    
} catch {
    print(error)
}

