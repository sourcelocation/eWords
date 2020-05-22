//
//  ChangeCollectionTableViewController.swift
//  eWords
//
//  Created by iMac on 28.03.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class ChangeCollectionTableViewController: UITableViewController {

    var cardsViewController: CardsViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GeneralData.sharedInstance.boughtCollections.count + 3
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 0 {
            cell.textLabel?.text = "My words"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Favorites"
        } else if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            cell.textLabel?.text = "All words"
        } else {
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            let cellsCollectionNumber = indexPath.row - 2
            let collectionsShort = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: GeneralData.sharedInstance.collectionsData[boughtCollections[cellsCollectionNumber]]!)
            cardsViewController?.words = collectionsShort
            cell.textLabel?.text = boughtCollections[indexPath.row - 2]
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row == 0 { // Check if tapped on cell with title "My words"
            cardsViewController?.words = GeneralData.sharedInstance.userWords
        } else if row == 1 { // Check if tapped on cell with title "Favorites"
            cardsViewController?.words = GeneralData.sharedInstance.favoriteWords
        } else if row == tableView.numberOfRows(inSection: 0) - 1 { // Check if tapped on cell with title "All words"
            
        } else {
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            let cellsCollectionNumber = indexPath.row - 2
            let collectionsShort = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: GeneralData.sharedInstance.collectionsData[boughtCollections[cellsCollectionNumber]]!)
            cardsViewController?.words = collectionsShort
        }
        cardsViewController?.selectedCollection = tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "My words"
        cardsViewController?.nextWord()
        navigationController?.popViewController(animated: true)
        
    }
    
    func getAllWords() -> [Word] {
        let userWords = GeneralData.sharedInstance.userWords ?? []
        let boughtCollections = GeneralData.sharedInstance.boughtCollections
        var allWords: [Word] = []
        let collectionsData = GeneralData.sharedInstance.collectionsData
        for (nameOfCollection, collection) in collectionsData {
            if boughtCollections.contains(nameOfCollection) {
                let smallCollectionData = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: collection)
                for word in smallCollectionData {
                    allWords.append(word)
                }
            }
        }
        for userWord in userWords {
            allWords.append(userWord)
        }
        return allWords
    }

}
