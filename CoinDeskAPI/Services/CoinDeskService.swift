//
//  CoinDeskService.swift
//  CoinDeskAPI
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import Foundation

//
// CoinDeskService
//   Provides a clean interface layer between our bitcoin app/widget and our CoinDeskAPI framework that
//   executes the outbound web-service calls. This way, API changes don't invoke UI rewrites and vice versa.
//

public enum PriceResponse<T> {
    case success(T)
    case error(Error)
}
public typealias CompletionHandler<T> = (PriceResponse<T>) -> Void

// MARK - CoinDesk Service
final public class CoinDeskService {

    // fetch ondemand a week's worth of historic prices for a single currency
    public class func fetchHistoricWeeklyPrices(currency: CDCurrency, callback: @escaping CompletionHandler<WeeklyPriceList>) {
        
        let today = Date()
        let oneWeekAgo = today.addingTimeInterval(-60*60*24*7)
        // fetch historical prices
        let _ = WSSession().get(CDEndpoint.historical(index:.USDCNY, currency:currency, Start:oneWeekAgo, End:today), responseType: CDHistResponse.self) { result in
            switch result {
            case .error(let error):
                callback(.error(error))
            case .success(let response):
                // convert response to our simplified model
                var priceArr:[Price] = Array()
                for (dateString, priceFloat) in response.bpi {
                    priceArr.append(Price(date: Date.getDate(string: dateString), price: priceFloat))
                }
                // sort historical prices by date
                priceArr = priceArr.sorted(by:{$0.date > $1.date})
                let result = WeeklyPriceList(priceArray: priceArr, currency: currency, fetchedAt: Date())
                callback(.success(result))
            }
        }
    }
    
    // fetch ondemand a historic price for a single day/currency
    public class func fetchHistoricDailyPrice(date: Date, currency: CDCurrency, callback: @escaping CompletionHandler<DailyPrice>) -> URLSessionDataTask? {
        let task = WSSession().get(CDEndpoint.historical(index:.USDCNY, currency:currency, Start:date, End:date), responseType: CDHistResponse.self) { result in
            switch result {
            case .error(let error):
                callback(.error(error))
            case .success(let response):
                // convert response to our simplified model
                var priceArr:[Price] = Array()
                for (dateString, priceFloat) in response.bpi {
                    priceArr.append(Price(date: Date.getDate(string: dateString), price: priceFloat))
                }
                let result = DailyPrice(price: priceArr[0], currency: currency, fetchedAt: Date())
                callback(.success(result))
            }
        }
        task?.resume()
        return task // return task so caller can cancel
    }
    
    // fetch a live price and invoke price delegate upon completion
    public class func fetchLivePrice(currency: CDCurrency, callback: @escaping CompletionHandler<DailyPrice>) -> URLSessionDataTask? {
        let task = WSSession().get(CDEndpoint.current(currency), responseType: CDLiveResponse.self) { result in
            switch result {
            case .error(let error):
                callback(.error(error))
            case .success(let response):
                // convert response to our simplified model
                var resultPrice:DailyPrice? = nil
                for (code, priceDaily) in response.bpi {
                    if code == currency.rawValue {
                        let price = Price(date: Date(), price: priceDaily.rateFloat)
                        resultPrice = DailyPrice(price: price, currency: currency, fetchedAt: Date())
                    }
                }
                if let result = resultPrice {
                    callback(.success(result))
                } else {
                    callback(.error(WSError.unknownError))
                }
            }
        }
        task?.resume()
        return task // return task so caller can cancel
    }
    
}
