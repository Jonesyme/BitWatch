//
//  TodayViewController.swift
//  BitWidget
//
//  Created by Mike Jones on 5/23/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import NotificationCenter
import CoinDeskAPI

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: view outlets
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: internal members
    internal var timer: Timer? = nil
    
    // MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchLivePrice()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    // MARK: widget specific
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let _ = CoinDeskService.fetchLivePrice(currency: .USD) { [weak self] result in
            switch result {
            case .error(_):
                completionHandler(.failed)
            case .success(let result):
                self?.priceLabel.attributedText = result.price.priceString(3, symbol: "$")
                completionHandler(.newData)
            }
        }
    }
    
    // MARK: internal functions
    @objc internal func fetchLivePrice() {
        let _ = CoinDeskService.fetchLivePrice(currency: .USD) { [weak self] result in
            switch result {
            case .error(let error):
                print("Live price fetch error: \(error.localizedDescription)")
            case .success(let result):
                self?.priceLabel.attributedText = result.price.priceString(3, symbol: "$")
            }
        }
        // re-fetch every 10 seconds
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.fetchLivePrice), userInfo: nil, repeats: false)
    }
    
}
