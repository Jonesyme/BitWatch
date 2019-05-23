//
//  DetailHeaderCell.swift
//  BitWatch
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import CoinDeskAPI

class DetailHeaderCell: UITableViewCell {
    
    // MARK: class functions
    public class var reuseIdentifier: String { return "detailHeaderCell" }
    public class var cellHeight: CGFloat { return 130.0 }
    
    // MARK: view outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    // MARK: view lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.text = "-"
        sourceLabel.text = "-"
    }
    
    // MARK: public functions
    public func updateView(detailSelection: DetailViewSelection) {
        switch detailSelection {
        case .live:
            dateLabel.text = "Today"
            sourceLabel.attributedText = NSAttributedString(string: "Live", attributes: [NSAttributedString.Key.foregroundColor: UIColor.BWStatusGreen])
        case .historic(let date):
            dateLabel.text = date.getShortString()
            sourceLabel.attributedText = NSAttributedString(string: "Close", attributes: [NSAttributedString.Key.foregroundColor: UIColor.BWStatusRed])
        }
    }

}
