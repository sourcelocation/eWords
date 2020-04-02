//
//  CollectionsViewController.swift
//  eWords2
//
//  Created by Matthew on 08.03.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit

class CollectionsViewController: UICollectionViewController {
    var imagesOfCollections = ["Actions":"run", "Time": "stopwatch", "Properties":"reduce", "Conversation":"discussion", "People and things":"handle-with-care"]
    var words: [Word]? {
        get {
            return GeneralData.sharedInstance.userWords ?? []
        }
        set(newValue) {
            GeneralData.sharedInstance.userWords = newValue
        }
    }
    var isEditingCollections = false
    var justLaunchedApp = true
    var numberOfBoughtCollections = 0
    var selectedIndexPath: IndexPath? = nil
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        isEditingCollections.toggle()
        if isEditingCollections {
            sender.title = "Done"
        } else {
            sender.title = "Edit"
        }
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performSegue(withIdentifier: "showWordsNoAnim", sender: nil)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if selectedIndexPath?.row == 0 || justLaunchedApp {
            let destination = segue.destination as! WordsViewController
            justLaunchedApp = false
            destination.collectionWords = nil
        } else if selectedIndexPath?.row == 1 {
            let destination = segue.destination as! WordsViewController
            destination.collectionWords = getAllWords()
        } else if selectedIndexPath?.row == collectionView.numberOfItems(inSection: 0) - 1 {
            
        } else {
            let destination = segue.destination as! WordsViewController
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            let cellsCollectionNumber = (selectedIndexPath?.row ?? 2) - 2
            let collectionData = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: GeneralData.sharedInstance.collectionsData[boughtCollections[cellsCollectionNumber]]!)
            destination.collectionWords = collectionData
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        numberOfBoughtCollections = GeneralData.sharedInstance.boughtCollections.count
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        if indexPath.row == 0 {
            performSegue(withIdentifier: "showCollection", sender: nil)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "showCollection", sender: nil)
        } else if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            // Buy collections cell
            performSegue(withIdentifier: "shop", sender: nil)
        } else {
            performSegue(withIdentifier: "showCollection", sender: nil)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return numberOfBoughtCollections + 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionsViewCell
        cell.deleteButton.alpha = 0
        if indexPath.row == 0 {
            cell.nameOfCollectionLabel.text = "My words"
            cell.imageView.image = UIImage(named: "words")
            cell.countLabel.alpha = 1
            cell.countLabel.text = "\(words?.count ?? 0)"
        } else if indexPath.row == 1 {
            cell.nameOfCollectionLabel.text = "All words"
            cell.imageView.image = UIImage(named: "allWords")
            cell.countLabel.alpha = 1
            cell.countLabel.text = "\(getAllWords().count)"
            cell.deleteButton.alpha = 0
        } else if indexPath.row == collectionView.numberOfItems(inSection: 0) - 1 {
            cell.nameOfCollectionLabel.text = "Buy collections"
            cell.imageView.image = UIImage(named: "shop")
            cell.countLabel.alpha = 0
            cell.deleteButton.alpha = 0
        } else {
            //Ячейка коллекции
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            let cellsCollectionNumber = indexPath.row - 2
            cell.nameOfCollectionLabel.text = boughtCollections[cellsCollectionNumber]
            let collectionsShort = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: GeneralData.sharedInstance.collectionsData[boughtCollections[cellsCollectionNumber]]!)
            cell.countLabel.text = String(collectionsShort.count)
            if isEditingCollections {
                cell.deleteButton.alpha = 1
            }
            cell.imageView.image = UIImage(named: imagesOfCollections[cell.nameOfCollectionLabel.text ?? ""] ?? "")
            cell.deleteButton.addTarget(self, action: #selector(deleteCollection(sender:)), for: .touchUpInside)
            cell.deleteButton.tag = indexPath.row
        }
        return cell
    }
    @objc func deleteCollection(sender: UIButton) {
        let indexPathRow = sender.tag
        GeneralData.sharedInstance.boughtCollections.remove(at: indexPathRow - 2)
        numberOfBoughtCollections = GeneralData.sharedInstance.boughtCollections.count
        collectionView.reloadData()
        
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
