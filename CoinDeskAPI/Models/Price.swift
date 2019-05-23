//
//  Price.swift
//  CoinDeskAPI
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import Foundation
import UIKit

//
// MARK: - Simplified models for use with CoinDeskService
//

// weekly price array
public struct WeeklyPriceList {
    public var priceArray: [Price]
    public var currency: CDCurrency
    public var fetchedAt: Date
}

// single day price
public struct DailyPrice {
    public var price: Price
    public var currency: CDCurrency
    public var fetchedAt: Date
}

// shared price model
public struct Price {
    public var date: Date
    public var price: Float
    
    public var dateString: String {
        return date.getShortString()
    }
    
    // redundant helper function
    public func priceString(_ decimals: Int = 3, symbol: String = "$") -> NSAttributedString {
        return price.getPrettyString(decimals, symbol: symbol)
    }

}

