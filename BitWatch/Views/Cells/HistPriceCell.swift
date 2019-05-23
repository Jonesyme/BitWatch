//
//  HistPriceCell.swift
//  BitWatch
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import CoinDeskAPI

class HistPriceCell: UITableViewCell {

    // MARK: class functions
    public class var reuseIdentifier: String { return "histPriceCell" }
    public class var cellHeight: CGFloat { return 55.0 }
    
    // MARK: view outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: view lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.text = "-"
        priceLabel.text = "-"
    }
    
    public func updateView(price: Price) {
        dateLabel.text = price.dateString
        priceLabel.attributedText = price.priceString(3, symbol:"$")
    }
}
