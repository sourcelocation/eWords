//
//  StatisticsTableViewController.swift
//  eWords
//
//  Created by iMac on 27.03.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UITableViewController {

    var collectionData:[String:[Word]] = [:]
    var sharedInstance = GeneralData.sharedInstance
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        for (key, collection) in sharedInstance.collectionsData {
            let smallCollection = sharedInstance.makeCollectionDataSmaller(collection: collection)
            collectionData[key] = smallCollection
        }
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GeneralData.sharedInstance.boughtCollections.count + 3
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        if indexPath.row == 0 {
            cell.textLabel?.text = "My words"
            cell.detailTextLabel?.text = "\(GeneralData.sharedInstance.userWords?.count ?? 0)"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Favorites"
            cell.detailTextLabel?.text = "\(GeneralData.sharedInstance.favoriteWords?.count ?? 0)"
        } else if indexPath.row >= 2 && indexPath.row < tableView.numberOfRows(inSection: 0) - 1 {
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            guard let collectionData = GeneralData.sharedInstance.collectionsData[boughtCollections[indexPath.row - 2]] else { return cell }
            let collectionArray = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: collectionData)
            cell.textLabel?.text = boughtCollections[indexPath.row - 2]
            cell.detailTextLabel?.text = "\(collectionArray.count)"
        } else {
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            var countOfWords = 0
            if boughtCollections.count != 0 {
                for index in 0...boughtCollections.count - 1 {
                    guard let collectionData = GeneralData.sharedInstance.collectionsData[boughtCollections[index]] else { return cell }
                    let collectionArray = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: collectionData)
                    countOfWords += collectionArray.count
                }
            }
            countOfWords += GeneralData.sharedInstance.userWords?.count ?? 0
            cell.textLabel?.text = "All words"
            cell.detailTextLabel?.text = "\(countOfWords)"
            cell.textLabel?.textColor = .init(red: 0, green: 0.55, blue: 0, alpha: 1)
        }
        return cell
    }

}
