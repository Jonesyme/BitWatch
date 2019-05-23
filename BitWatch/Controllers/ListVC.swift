//
//  ListVC.swift
//  BitWatch
//
//  Created by Mike Jones on 5/22/19.
//  Copyright © 2019 Mike Jones. All rights reserved.
//

import UIKit
import CoinDeskAPI

class ListVC: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: internal members
    internal var histPrices:[Price] = Array()  // historic price cache going back 1-week
    internal var livePrice:Price? = nil        // live price cache
    internal var livePriceTimer: Timer? = nil  // live price refresh timer
    
    // MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchLivePrice()
        self.fetchWeeklyPrices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // re-fetch live price every 60 seconds
        livePriceTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.fetchLivePrice), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // invalidate refresh timer
        livePriceTimer?.invalidate()
    }

    @objc internal func fetchLivePrice() {
        let _ = CoinDeskService.fetchLivePrice(currency: .USD) { [weak self] result in
            switch result {
            case .error(let error):
                print("Live price fetch error: \(error.localizedDescription)")
            case .success(let result):
                self?.livePrice = result.price
                self?.tableView.reloadSections(IndexSet.init(arrayLiteral: 0), with: .automatic)
            }
        }
    }
    
    internal func fetchWeeklyPrices() {
        CoinDeskService.fetchHistoricWeeklyPrices(currency: .USD) { [weak self] result in
            switch result {
            case .error(let error):
                print("Weekly price fetch error: \(error.localizedDescription)")
            case .success(let result):
                self?.histPrices = result.priceArray
                self?.tableView.reloadSections(IndexSet.init(arrayLiteral: 1), with: .automatic)
            }
        }
    }
}

// MARK - UITableView Delegates
extension ListVC : UITableViewDelegate, UITableViewDataSource  {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return LivePriceCell.cellHeight
        } else {
            return HistPriceCell.cellHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return histPrices.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // live price cell
            guard let cell:LivePriceCell = tableView.dequeueReusableCell(withIdentifier:LivePriceCell.reuseIdentifier, for: indexPath) as? LivePriceCell else {
                assertionFailure("Unable to dequeue a proper LivePriceCell")
                return UITableViewCell()
            }
            if let livePrice = livePrice {
                cell.updateView(price: livePrice)
            }
            return cell
        } else {
            // historical price cell
            guard let cell:HistPriceCell = tableView.dequeueReusableCell(withIdentifier:HistPriceCell.reuseIdentifier, for: indexPath) as? HistPriceCell else {
                assertionFailure("Unable to dequeue a proper HistPriceCell")
                return UITableViewCell()
            }
            
            let price:Price = histPrices[indexPath.row]
            cell.updateView(price: price)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // create new DetailVC instance
        let storyboard = UIStoryboard(name:"Main", bundle:nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: DetailVC.storyboardID) as? DetailVC else {
            return
        }
        
        // aggregate user-selected options
        var detailSelection: DetailViewSelection
        if indexPath.section == 0 {
            detailSelection = .live
        } else {
            detailSelection = .historic(date: histPrices[indexPath.row].date)
        }
        
        // push DetailVC onto NavStack
        tableView.deselectRow(at: indexPath, animated: true)
        detailVC.selection = detailSelection
        navigationController?.pushViewController(detailVC, animated: true)
    }
        
}

