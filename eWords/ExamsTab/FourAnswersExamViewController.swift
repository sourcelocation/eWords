//
//  WriteAnAnswerViewController.swift
//  eWords
//
//  Created by iMac on 23.04.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class FourAnswersExamViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func exitExamButtonPressed(_ sender: UIButton) {
        if endedExam {
            dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Are you sure?", message: "All progress will be lost.", preferredStyle: .alert)
            alert.addAction(.init(title: "Exit", style: .destructive, handler: { (alert) in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    //        if sender.tag == 1 {
    //            wrongWords.append(randomWord!)
    //        }
    //
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet var answerViews: [UIView]!
    @IBOutlet var answerTextLabels: [UILabel]!
    var endedExam = false
    var questionIndex = -1
    
    var wrongWords:[Word] = []
    var notAnsweredWords:[Word]?
    var selectedCollection = ""
    var totalWords = 0
    var initialWords:[Word]?
    var isQuestionOnForeignLanguage = false
    var randomWord: Word?
    var hadStartedExam = false
    var randomAnswerCardIndex = 1
    @IBAction func endNowButtonPressed(_ sender: UIButton) {
        let resultsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExamResults") as! ExamResultsViewController
        resultsVC.wrongAnswers = self.wrongWords
        resultsVC.totalWordsCount = totalWords - (notAnsweredWords?.count ?? 0) - 1
        endedExam = true
        present(resultsVC, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        for answerView in answerViews! {
            let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.answerTapped(_:)))
            answerView.addGestureRecognizer(gesture)
            answerView.clipsToBounds = true
            answerView.layer.cornerRadius = 15
            answerView.layer.borderColor = UIColor.black.cgColor
            answerView.layer.borderWidth = 2
        }
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if hadStartedExam == false {
            let actionSheet =  UIAlertController(title: "Choose a collection", message: "Please, choose a collection for the exam", preferredStyle: .actionSheet)
            actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: { (alert) in
                self.dismiss(animated: true, completion: nil)
            }))
            if GeneralData.sharedInstance.userWords != nil {
                actionSheet.addAction(.init(title: "My words", style: .default, handler: { (alert) in
                    self.selectedCollection = "My words"
                    self.startExam()
                }))
            }
            if GeneralData.sharedInstance.favoriteWords != nil {
                actionSheet.addAction(.init(title: "Favorites", style: .default, handler: { (alert) in
                    self.selectedCollection = "Favorites"
                    self.startExam()
                }))
            }
            if getAllWords() != nil {
                actionSheet.addAction(.init(title: "All words", style: .default, handler: { (alert) in
                    self.selectedCollection = "All words"
                    self.startExam()
                }))
            }
            
            let boughtCollections = GeneralData.sharedInstance.boughtCollections
            for collection in boughtCollections {
                actionSheet.addAction(.init(title: collection, style: .default, handler: { (alert) in
                    self.selectedCollection = collection
                    self.startExam()
                }))
            }
            present(actionSheet, animated: true, completion: nil)
        }
    }
    func startExam() {
        hadStartedExam = true
        if selectedCollection == "My words" {
            notAnsweredWords = GeneralData.sharedInstance.userWords
        } else if selectedCollection == "Favorites" {
            notAnsweredWords = GeneralData.sharedInstance.favoriteWords
        } else if selectedCollection == "All words" {
            notAnsweredWords = getAllWords()
        } else {
            let collectionsData = GeneralData.sharedInstance.collectionsData
            let collectionData = GeneralData.sharedInstance.makeCollectionDataSmaller(collection: collectionsData[selectedCollection]!)
            notAnsweredWords = collectionData
        }
        initialWords = notAnsweredWords
        totalWords = notAnsweredWords!.count
        nextQuestion()
    }
    func nextQuestion() {
        isQuestionOnForeignLanguage = .random()
        questionIndex += 1
        questionNumberLabel.text = "Question \(questionIndex + 1)/\(totalWords)"
        randomWord = notAnsweredWords?.randomElement()
        notAnsweredWords?.removeAll(where: { (word) -> Bool in
            return word === randomWord
        })
        if isQuestionOnForeignLanguage {
            questionLabel.text = randomWord?.foreignWord
        } else {
            questionLabel.text = randomWord?.nativeWord
        }
        randomAnswerCardIndex = .random(in: 1...4)
        for label in answerTextLabels {
            if label.tag == randomAnswerCardIndex {
                if isQuestionOnForeignLanguage {
                    label.text = randomWord?.nativeWord
                } else {
                    label.text = randomWord?.foreignWord
                }
            } else {
                var randomWrongWord = initialWords!.randomElement()
                while randomWrongWord === randomWord! {
                    randomWrongWord = initialWords?.randomElement()
                }
                if isQuestionOnForeignLanguage {
                    label.text = randomWrongWord?.nativeWord
                } else {
                    label.text = randomWrongWord?.foreignWord
                }
            }
        }
    }
    @objc func answerTapped(_ sender: UITapGestureRecognizer) {
        if randomAnswerCardIndex != sender.view?.tag {
            wrongWords.append(randomWord!)
        }
        if questionIndex < totalWords - 1 {
            nextQuestion()
        } else {
            let resultsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ExamResults") as! ExamResultsViewController
            resultsVC.wrongAnswers = self.wrongWords
            resultsVC.totalWordsCount = totalWords
            endedExam = true
            if #available(iOS 13.0, *) {
                self.isModalInPresentation = false
            }
            present(resultsVC, animated: true, completion: nil)
            
        }
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
