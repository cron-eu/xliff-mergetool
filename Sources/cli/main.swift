//
//  main.swift
//  XliffConverter
//
//  Created by Remus Lazar on 21.09.17.
//  Copyright © 2017 cron.eu. All rights reserved.
//

import Foundation
import XLIFFMergeTool
import CommandLineKit

let cli = CommandLineKit.CommandLine()

enum Operation: String {
    case mergeTarget  = "mergeExistingTranslations"
    case mergeTargetIntoSource = "mergeTargetIntoSource"
    case info = "info"
}

let devLangPath = StringOption(shortFlag: "d", longFlag: "dev-lang", required: true,
                               helpMessage: "Path to the (auto-generated) Development Language XLIFF File")
let mergePath = StringOption(shortFlag: "m", longFlag: "merge-from", required: true,
                             helpMessage: "Path to the (partially) translated XLIFF File")
let help = BoolOption(shortFlag: "h", longFlag: "help",
                      helpMessage: "Prints a help message.")
let op = EnumOption<Operation>(shortFlag: "o", longFlag: "operation", required: true,
                               helpMessage: "Merge operation: mergeExistingTranslations | mergeTargetIntoSource | info")
let targetLanguageParameter = StringOption(shortFlag: "t", longFlag: "target-language", required: false,
                               helpMessage: "target-language to be set for all files in the generated XLIFF, e.g. de, en, fr, ..")

cli.setOptions(devLangPath, mergePath, help, op, targetLanguageParameter)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

guard let operation = op.value else {
    exit(EX_USAGE)
}

do {
    var devlangXML = try XliffFile(xmlURL: URL(fileURLWithPath: devLangPath.value!))
    let translatedXML = try XliffFile(xmlURL: URL(fileURLWithPath: mergePath.value!))

    func output() {
        if let targetLanguage = targetLanguageParameter.value {
            devlangXML.targetLanguage = targetLanguage
        }
        let output = String(data: devlangXML.xmlData, encoding: .utf8)!
        print(output)
    }
    
    switch operation {
    case .mergeTarget:
        devlangXML.mergeExistingTranslations(from: translatedXML)
        output()
    case .mergeTargetIntoSource:
        devlangXML.mergeTargetIntoSource(from: translatedXML)
        output()
    case .info:
        print("Developer Language XLIFF: \(devlangXML)")
        print("Translated Language XLIFF: \(translatedXML)")
    }
    
} catch {
    print(error)
}

