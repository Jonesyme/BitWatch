//
//  DetailVC.swift
//  BitWatch
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import CoinDeskAPI

// DetailVC selection options
public enum DetailViewSelection {
    case live
    case historic(date:Date)
}
internal struct CurrencyElem {
    var code: CDCurrency
    var symbol: String
}

class DetailVC : UIViewController {
    
    // MARK: class methods
    class var storyboardID: String { return "detailVC" }
    
    // MARK: view outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: public members
    public var selection: DetailViewSelection = .live
    
    // MARK: internal members
    internal var prices:[CDCurrency:NSAttributedString] = [:]
    internal var currencyList:[CurrencyElem] = [CurrencyElem(code: .USD, symbol: "$"),
                                                CurrencyElem(code: .GBP, symbol: "£"),
                                                CurrencyElem(code: .EUR, symbol: "€")]
    internal var downloadTaskArr:[URLSessionDataTask?] = []
    
    // MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchDailyPriceSpread()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // cancel any active download threads
        for taskOpt in downloadTaskArr {
            if let task = taskOpt, task.state == .running {
                task.cancel()
            }
        }
    }
    
    // MARK: internal functions
    internal func fetchDailyPriceSpread() {
        for curr in currencyList {
            switch selection {
            case .live:
                let task = CoinDeskService.fetchLivePrice(currency: curr.code) { [weak self] result in
                    switch result {
                    case .error(let error):
                        print("Live price error: \(error.localizedDescription)")
                    case .success(let result):
                        self?.prices[curr.code] = result.price.priceString(3, symbol: curr.symbol)
                        self?.tableView.reloadData()
                    }
                }
                downloadTaskArr.append(task)
            case .historic(let date):
                let task = CoinDeskService.fetchHistoricDailyPrice(date:date, currency:curr.code) { [weak self] result in
                    switch result {
                    case .error(let error):
                        print("Daily price error: \(error.localizedDescription)")
                    case .success(let result):
                        self?.prices[curr.code] = result.price.priceString(3, symbol: curr.symbol)
                        self?.tableView.reloadData()
                    }
                }
                downloadTaskArr.append(task)
            }
        }
    }
}

// MARK: - TableViewDelegates
extension DetailVC: UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return DetailHeaderCell.cellHeight
        } else {
            return DetailCell.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return currencyList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // faux header cell
            guard let cell:DetailHeaderCell = tableView.dequeueReusableCell(withIdentifier:DetailHeaderCell.reuseIdentifier, for: indexPath) as? DetailHeaderCell else {
                assertionFailure("Unable to dequeue a proper DetailHeaderCell")
                return UITableViewCell()
            }
            cell.updateView(detailSelection: selection)
            return cell
        } else {
            // daily price detail cell
            guard let cell:DetailCell = tableView.dequeueReusableCell(withIdentifier:DetailCell.reuseIdentifier, for: indexPath) as? DetailCell else {
                assertionFailure("Unable to dequeue a proper DetailCell")
                return UITableViewCell()
            }
            let curr = currencyList[indexPath.row]
            guard let priceString = prices[curr.code] else {
                return cell
            }
            cell.updateView(currency: curr.code, priceString: priceString)
            return cell
        }
    }
    
}

