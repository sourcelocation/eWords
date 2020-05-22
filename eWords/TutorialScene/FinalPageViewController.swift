//
//  FinalPageViewController.swift
//  eWords
//
//  Created by iMac on 08.04.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class FinalPageViewController: UIViewController {

    @IBOutlet weak var closeTutorialButton: UIButton!
    @IBAction func closeTutorial(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasViewedTutorial")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeTutorialButton.isEnabled = true
    }

}
