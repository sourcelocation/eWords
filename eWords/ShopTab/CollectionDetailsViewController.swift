//
//  CollectionDetailsViewController.swift
//  eWords2
//
//  Created by Matthew on 18.03.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit
import SwiftMessages

class CollectionDetailsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var imageOfCollection: UIImageView!
    @IBOutlet weak var collectionNameTitle: UILabel!
    var titleOfCollection:String?
    var imageName:String?
    @IBAction func buyButtonPressed(_ sender: UIButton) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        
        if GeneralData.sharedInstance.boughtCollections.contains(titleOfCollection ?? "Error") {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            let view = MessageView.viewFromNib(layout: .cardView)
            view.configureTheme(.error)
            view.configureDropShadow()
            view.button?.backgroundColor = .clear
            view.button?.setTitle("", for: [])
            view.configureContent(title: "Already bought!", body: "Your collection is in your Collections tab!")
            view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
            SwiftMessages.show(config:config, view: view)
            return
        }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.success)
        view.configureDropShadow()
        view.button?.backgroundColor = .clear
        view.button?.setTitle("", for: [])
        view.configureContent(title: "Success!", body: "Your collection was successfully added to your Collections tab!")
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.show(config:config, view: view)
        UserDefaults.standard.set(GeneralData.sharedInstance.boughtCollections, forKey: "boughtCollectionsNew")
        GeneralData.sharedInstance.boughtCollections.append(titleOfCollection ?? "Error")
        print(GeneralData.sharedInstance.boughtCollections)
    }
    @IBOutlet weak var tableView1: UITableView!
    
    var shortCollectionData:[Word]?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView1.dataSource = self
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
