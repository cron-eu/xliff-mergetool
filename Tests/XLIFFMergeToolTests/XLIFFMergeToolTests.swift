import XCTest
@testable import XLIFFMergeTool

class XLIFFMergeToolTests: XCTestCase {

    var source: XliffFile!
    var merge: XliffFile!
    var bundle: Bundle!

    override func setUp() {
        super.setUp()
        self.bundle = Bundle(for: type(of: self))
        print(bundle.bundlePath)
        source = try! XliffFile(xmlURL: bundle.url(forResource: "messages", withExtension: "xlf", subdirectory: "fixtures")!)
        merge = try! XliffFile(xmlURL: bundle.url(forResource: "messages.de", withExtension: "xlf", subdirectory: "fixtures")!)
    }
    
    func testMergeExistingTranslations() {
        source.mergeExistingTranslations(from: merge)
        let expected = try! XliffFile(xmlURL: bundle.url(forResource: "messages-merged", withExtension: "xlf", subdirectory: "fixtures")!)
        XCTAssertEqual(source.xmlData, expected.xmlData)
    }

    func testMergeTargetIntoSource() {
        source.mergeTargetIntoSource(from: merge)
        let expected = try! XliffFile(xmlURL: bundle.url(forResource: "messages-target-into-source", withExtension: "xlf", subdirectory: "fixtures")!)
        XCTAssertEqual(source.xmlData, expected.xmlData)
    }

    static var allTests = [
        ("testMergeExistingTranslations", testMergeExistingTranslations),
        ("testMergeTargetIntoSource", testMergeTargetIntoSource),
    ]
}
