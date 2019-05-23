//
//  LivePriceCell.swift
//  BitWatch
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import CoinDeskAPI

class LivePriceCell: UITableViewCell {
    
    // MARK: class functions
    public class var reuseIdentifier: String { return "livePriceCell" }
    public class var cellHeight: CGFloat { return 150.0 }
    
    // MARK: view outlets
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: view lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        priceLabel.text = "-"
    }
    
    // MARK: public functions
    public func updateView(price: Price) {
        priceLabel.attributedText = price.priceString(3)
    }
}
