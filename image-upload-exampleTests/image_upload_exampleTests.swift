//
//  image_upload_exampleTests.swift
//  image-upload-exampleTests
//
//  Created by Peter Keller on 12/7/18.
//  Copyright © 2018 Peter Keller. All rights reserved.
//

import XCTest
@testable import image_upload_example

class image_upload_exampleTests: XCTestCase {
    
    var locImage: LocImage!

    override func setUp() {
        super.setUp()
        locImage = LocImage(imageDict: ["created": "2018-12-10 10:05:01" as AnyObject])
    }

    override func tearDown() {
        super.tearDown()
        locImage = nil
    }

    func testExample() {
        XCTAssert(locImage.created_at > 86400)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
