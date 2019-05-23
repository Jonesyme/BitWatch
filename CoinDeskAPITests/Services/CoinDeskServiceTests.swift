//
//  CoinDeskServiceTests.swift
//  CoinDeskAPITests
//
//  Created by Mike Jones on 5/23/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import XCTest
@testable import CoinDeskAPI

class CoindDeskServiceTests: XCTestCase {
    
    override func setUp() {
        
    }

    func testHistoricWeeklyPriceFetch() {
        let testExpectation = expectation(description: "Historic Weekly Price fetch")
        CoinDeskService.fetchHistoricWeeklyPrices(currency: .USD) { result in
            switch result {
            case .error(let error):
                print("Weekly price fetch error: \(error.localizedDescription)")
            case .success(let result):
                XCTAssertNotNil(result.priceArray)
                testExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testHistoricDailyPriceFetch() {
        let testExpectation = expectation(description: "Historic Daily Price fetch")
        let _ = CoinDeskService.fetchHistoricDailyPrice(date: Date.getDate(string: "2019-05-10"), currency:.USD) { result in
            switch result {
            case .error(let error):
                print("Weekly price fetch error: \(error.localizedDescription)")
            case .success(let result):
                let str = result.price.priceString(3, symbol: "$")
                XCTAssert(str.string=="$ 6,375.562")
                testExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func testLivePriceFetch() {
        let testExpectation = expectation(description: "Historic Daily Price fetch")
        let _ = CoinDeskService.fetchLivePrice(currency: .USD) { result in
            switch result {
            case .error(let error):
                print("Weekly price fetch error: \(error.localizedDescription)")
            case .success(let result):
                let str = result.price.priceString()
                XCTAssertNotNil(str.string)
                testExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
