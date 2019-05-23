//
//  CDPriceRecord.swift
//  CoinDeskAPI
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import Foundation

//
// MARK: CoinDesk WebService Models
//

// CoinDesk Historical Price - Response Model
struct CDHistResponse: Codable {
    var time: CDSharedTimeStamp
    var disclaimer: String
    var bpi: [String:Float]
}

// CoinDesk Live Price - Response model
struct CDLiveResponse: Codable {
    var time: CDSharedTimeStamp
    var disclaimer: String
    var bpi: [String:CDLivePrice]
}

struct CDLivePrice: Codable {
    var code: String
    var symbol: String?
    var rate: String
    var description: String
    var rateFloat: Float
    
    enum CodingKeys: String, CodingKey {
        case code, symbol
        case rate
        case description
        case rateFloat = "rate_float"
    }
}

// shared timestamp model
struct CDSharedTimeStamp: Codable {
    var updated: String
    var updatedISO: String
}

