//
//  ShopCollectionViewController.swift
//  eWords2
//
//  Created by Matthew on 17.03.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit

class ShopCollectionViewController: UICollectionViewController {

    var imagesOfCollections = ["Actions":"run", "Time": "stopwatch", "Properties":"reduce", "Conversation":"discussion", "People and things":"handle-with-care"]
    var sharedInstance = GeneralData.sharedInstance
    var collectionsData: [String:[[String:String]]]!
    var selectedIndexPath:IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionsData = GeneralData.sharedInstance.collectionsData
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let keys = collectionsData.keys
        return keys.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ShopTableViewCell
        let keys = Array(collectionsData.keys)
        cell.imageView.image = UIImage(named: imagesOfCollections[keys[indexPath.row]] ?? "")
        cell.titleLabel.text = keys[indexPath.row]
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "showDetails", sender: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! CollectionDetailsViewController
        let keys = Array(collectionsData.keys)
        let selectedCollectionData = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: collectionsData[keys[selectedIndexPath?.row ?? 0]] ?? [])
        destination.shortCollectionData = selectedCollectionData
        destination.imageName = imagesOfCollections[keys[selectedIndexPath?.row ?? 0]] ?? ""
        destination.titleOfCollection = keys[selectedIndexPath?.row ?? 0]
        
    }
}

class RoundedButtonWithShadow: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2.0
    }
}
