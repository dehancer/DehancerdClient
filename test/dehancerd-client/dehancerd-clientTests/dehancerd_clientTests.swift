//
//  dehancerd_clientTests.swift
//  dehancerd-clientTests
//
//  Created by denn on 03/02/2019.
//  Copyright © 2019 Dehacer. All rights reserved.
//

import XCTest
@testable import dehancerd_client
import ed25519
import ObjectMapper
import DehancerdClient

struct Config {
    
    static let mode = DehancerdClient.Session.OpenMode.reuse
    
    static let url =  URL(string: "http://127.0.0.1:8042/v1/api")!
    
    //
    // Test api access token generator
    // shoild be add in dehancerd db
    //
    static let accessPair = try! Pair(secretPhrase: "dehancerd test api")
    
    //
    // Api client name
    //
    static let accessName = "Test Api"
    
    //
    // Client unique id
    //
    static let cuid = try! Pair(secretPhrase: "dehancerd test client")
}


class dehancerd_clientTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
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
