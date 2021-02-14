//
//  Extentions.swift
//  CoinDeskAPI
//
//  Created by Mike Jones on 5/23/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import Foundation

// MARK - Date extensions
extension Date {
    
    public func getString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    public func getShortString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
    
    public static func getDate(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: string) else {
            assert(false, "CoinDeskAPI: unable to parse date from string")
            return Date()
        }
        return date
    }
}


// MARK - Float extensions
extension Float {
    
    // format price string with attributed font size and baseline adjustment for the decimal portion
    public func getPrettyString(_ decimals: Int = 3, symbol: String) -> NSAttributedString {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol + ""
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        
        let full = formatter.string(from: NSNumber.init(value: self))
        let parts = full!.split(separator: ".").map(String.init)

        let prefixFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0)]
        let postfixFont = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0), NSAttributedString.Key.baselineOffset: 5.0] as [NSAttributedString.Key : Any]
        
        let string = NSMutableAttributedString(string: (parts[0] + "."), attributes: prefixFont)
        string.append(NSAttributedString(string: parts[1], attributes: postfixFont))
        return string
    }
}
