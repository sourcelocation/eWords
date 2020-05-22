//
//  ExamResultsViewController.swift
//  eWords
//
//  Created by iMac on 23.04.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class ExamResultsViewController: UIViewController, UITableViewDataSource {
    var wrongAnswers:[Word]?
    var totalWordsCount = 0
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var wrongAnswersCountLabel: UILabel!
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var percantageRightAnswersLabel: UILabel!
    @IBOutlet weak var mark: UILabel!
    @IBAction func markWordsAsFavorites(_ sender: UIButton) {
        for word in wrongAnswers ?? [] {
            if !word.isFavorite {
                if GeneralData.sharedInstance.favoriteWords == nil {
                    GeneralData.sharedInstance.favoriteWords = []
                }
                GeneralData.sharedInstance.favoriteWords?.append(word)
            }
        }
        sender.setTitle("Success!", for: [])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let percantage = 100.0 / Double(totalWordsCount) * Double((totalWordsCount - (wrongAnswers?.count ?? 0)))
        percantageRightAnswersLabel.text = "\(Int(percantage))% of all answers are right"
        wrongAnswersCountLabel.text = "\(totalWordsCount - (wrongAnswers?.count ?? 0))/\(totalWordsCount) answers right"
        // Do any additional setup after loading the view.
        
        if percantage >= 85 {
            mark.text = "A"
        } else if percantage >= 70 {
            mark.text = "B"
        } else if percantage >= 55 {
            mark.text = "C"
        } else if percantage >= 40 {
            mark.text = "D"
        } else {
            mark.text = "F :("
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wrongAnswers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = wrongAnswers?[indexPath.row].foreignWord
        return cell
    }

}
