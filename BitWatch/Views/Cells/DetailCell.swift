//
//  DetailCell.swift
//  BitWatch
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import CoinDeskAPI

class DetailCell: UITableViewCell {

    // MARK: class functions
    public class var reuseIdentifier: String { return "detailCell" }
    public class var cellHeight: CGFloat { return 75.0 }
    
    // MARK: view outlets
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: view lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        currencyLabel.text = "-"
        priceLabel.text = "-"
    }
    
    // MARK: public functions
    public func updateView(currency: CDCurrency, priceString: NSAttributedString) {
        currencyLabel.text = currency.rawValue
        priceLabel.attributedText = priceString
    }

}
