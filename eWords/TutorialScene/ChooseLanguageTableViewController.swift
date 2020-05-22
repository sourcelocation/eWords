//
//  ChooseLanguageTableViewController.swift
//  eWords
//
//  Created by iMac on 30.03.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit
import SwiftMessages

class ChooseLanguageTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let languages = GeneralData.sharedInstance.languageData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return languages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = languages[indexPath.row][0]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        GeneralData.sharedInstance.foreignLanguageCode = languages[indexPath.row][1]
        NotificationCenter.default.post(name: Notification.Name("reloadAllWords"), object: nil)
        UserDefaults.standard.set(GeneralData.sharedInstance.foreignLanguageCode, forKey: "foreignLang")
        performSegue(withIdentifier: "choose2", sender: nil)
    }
}
