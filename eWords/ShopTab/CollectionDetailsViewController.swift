//
//  CollectionDetailsViewController.swift
//  eWords2
//
//  Created by Matthew on 18.03.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit

class CollectionDetailsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var imageOfCollection: UIImageView!
    @IBOutlet weak var collectionNameTitle: UILabel!
    var titleOfCollection:String?
    var imageName:String?
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Success!", message: "Your collection was successfully added to your Collections tab!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
        GeneralData.sharedInstance.boughtCollections.append(titleOfCollection ?? "Error")
        print(GeneralData.sharedInstance.boughtCollections)
    }
    @IBOutlet weak var tableView1: UITableView!
    
    var shortCollectionData:[Word]?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView1.dataSource = self
        print(shortCollectionData)
        collectionNameTitle.text = titleOfCollection
        imageOfCollection.image = UIImage(named: imageName ?? "")
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.row == 3 {
            cell.textLabel?.text = "And \((shortCollectionData?.count ?? 0) - 3) more..."
        } else {
            cell.textLabel?.text = shortCollectionData?[indexPath.row].foreignWord
        }
        
        return cell
    }

}
