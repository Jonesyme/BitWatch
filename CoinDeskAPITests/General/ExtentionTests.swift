//
//  ExtentionTests.swift
//  BitWatchTests
//
//  Created by Mike Jones on 5/23/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//


import XCTest
@testable import CoinDeskAPI

class ExtentionTests: XCTestCase {
    
    override func setUp() {}

    func testDateCreationFromString() {
        let testDate = Date.getDate(string: "2019-05-20")
        let testStr = testDate.getString()
        XCTAssert(testStr == "2019-05-20")
    }
    
    func testDateShortString() {
        let testDate = Date.getDate(string: "2019-05-20")
        let testStr = testDate.getShortString()
        XCTAssert(testStr == "May 20, 2019")
    }
    
    func testFloatPrettyString1() {
        let testFloat:Float = 100.001
        let testStr = testFloat.getPrettyString(2, symbol: "$")
        XCTAssert(testStr.string == "$ 100.00")
    }
    
    func testFloatPrettyString2() {
        let testFloat:Float = 1001.003
        let testStr = testFloat.getPrettyString(3, symbol: "$")
        XCTAssert(testStr.string == "$ 1,001.003")
    }
}
