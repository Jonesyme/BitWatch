//
//  CDEndpoint.swift
//  CoinDeskAPI
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import Foundation
import UIKit

//
// MARK: - CoinDesk WebService Endpoint
//

// MARK: - CoinDesk specific ENUMs
public enum CDIndex : String {
    case USDCNY = "USD/CNY"
    case CNYUSD = "CNY/USD"
}
public enum CDCurrency : String {
    case BTC = "BTC"
    case USD = "USD"
    case CNY = "CNY"
    case GBP = "GBP"
    case EUR = "EUR"
    case Default = ""
}

// MARK: - CoinDesk Endpoint
public enum CDEndpoint {
    case current(_ code: CDCurrency)
    case historical(index: CDIndex, currency: CDCurrency, Start: Date, End: Date)
}

extension CDEndpoint : WSEndpointProtocol {

    public var scheme: String {
        return "https"
    }
    public var host: String {
        return "api.coindesk.com"
    }

    public var path: String {
        switch self {
        case .current(let currencyCode):
            if currencyCode == .Default {
                return "/v1/bpi/currentprice.json"
            } else {
                return "/v1/bpi/currentprice/" + currencyCode.rawValue + ".json"
            }
        case .historical(_, _, _, _):
            return "/v1/bpi/historical/close.json"
        }
    }
    
    public var params: [URLQueryItem] {
        switch self {
        case .current(_):
            return []
        case .historical(let index, let currency, let start, let end):
            return [URLQueryItem(name: "index", value: index.rawValue),
                    URLQueryItem(name: "currency", value: currency.rawValue),
                    URLQueryItem(name: "start", value: start.getString()),
                    URLQueryItem(name: "end", value: end.getString())]
        }
    }
    
    public func decode<T:Decodable>(with data: Data, decodingType: T.Type) -> WSResponse<T> {
        do {
            let decodedObject = try JSONDecoder().decode(T.self, from: data)
            return .success(decodedObject)
        } catch {
            return .error(WSError.parseError(error))
        }
    }
}

