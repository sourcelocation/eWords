//
//  AnswerViewController.swift
//  eWords2
//
//  Created by Matthew on 15.03.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit
import AVFoundation

class AnswerViewController: UIViewController {
    var word: Word?
    var words: [Word]?
    var indexOfWord: Int = 0
    var isShowingUserWords = false
    @IBOutlet weak var starButton: UIBarButtonItem!
    @IBOutlet weak var foreignLabel: UILabel!
    @IBOutlet weak var nativeLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func speakButtonPressed(_ sender: UIButton) {
        let wordToSpeak = word?.foreignWord
        let utterance = AVSpeechUtterance(string: wordToSpeak ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: GeneralData.sharedInstance.foreignLanguageCode ?? "en-US")
        let synth = AVSpeechSynthesizer()
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        synth.speak(utterance)
    }
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        present(buildAlert(), animated: true, completion: nil)
    }
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        indexOfWord += 1
        if indexOfWord > (words?.count ?? 1) - 1 {
            indexOfWord = 0
        }
        updateLabels()
    }
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        indexOfWord -= 1
        if indexOfWord < 0 {
            indexOfWord = (words?.count ?? 1) - 1
        }
        updateLabels()
    }
    @IBAction func translationsButtonPressed(_ sender: UIButton) {
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word?.foreignWord ?? "Error") {
            let ref: UIReferenceLibraryViewController = UIReferenceLibraryViewController(term: word?.foreignWord ?? "Error")
            self.present(ref, animated: false, completion: nil)
        } else {
            let alert = UIAlertController(title: "Meaning", message: "Couldn't find meaning for word \"\(word?.foreignWord ?? "Error")\". Go to Settings -> General -> Dictionaries, and then download dictionaries", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func starButtonPressed(_ sender: UIBarButtonItem) {
        let word = words![indexOfWord]
        let results = GeneralData.sharedInstance.favoriteWords?.filter({ (favoriteWord) -> Bool in
            return favoriteWord.foreignWord == word.foreignWord && favoriteWord.nativeWord == word.nativeWord
        })
        if results?.count ?? 0 > 0 {
            GeneralData.sharedInstance.favoriteWords = GeneralData.sharedInstance.favoriteWords?.filter({ (favoriteWord) -> Bool in
                return favoriteWord.foreignWord != word.foreignWord && favoriteWord.nativeWord != word.nativeWord
            })
        } else {
            if GeneralData.sharedInstance.favoriteWords != nil {
                GeneralData.sharedInstance.favoriteWords?.append(word)
            } else {
                GeneralData.sharedInstance.favoriteWords = [word]
            }
        }
        if word.isFavorite {
            sender.image = UIImage(named: "starFilled")
        } else {
            sender.image = UIImage(named: "starEmpty")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        editButton.isEnabled = isShowingUserWords
        indexOfWord = words?.firstIndex{$0 === word} ?? 0
        updateLabels()
        if word?.isFavorite ?? false {
            starButton.image = UIImage(named: "starFilled")
        } else {
            starButton.image = UIImage(named: "starEmpty")
        }
    }
    func updateLabels() {
        word = words?[indexOfWord]
        foreignLabel.text = word?.foreignWord
        nativeLabel.text = word?.nativeWord
        title = "Info"
    }
    func buildAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Edit this word", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Foreign language's word"
            textField.text = self.words?[self.indexOfWord].foreignWord
            textField.autocapitalizationType = .sentences
            textField.autocorrectionType = .yes
        }
        alert.addTextField { (textField2) in
            textField2.placeholder = "Native language's word"
            textField2.text = self.words?[self.indexOfWord].nativeWord
            textField2.autocorrectionType = .yes
            textField2.autocapitalizationType = .sentences
        }
        
        let textFields = alert.textFields
        
        alert.addAction(.init(title: "Edit", style: .default, handler: { (alert) in
            let foreignText = textFields?[0].text ?? ""
            let nativeText = textFields?[1].text ?? ""
            let word = Word()
            word.foreignWord = foreignText
            word.nativeWord = nativeText
            let oldFavoriteWords = GeneralData.sharedInstance.favoriteWords
            GeneralData.sharedInstance.favoriteWords = GeneralData.sharedInstance.favoriteWords?.filter({ (word1) -> Bool in
                return word1 !== self.words?[self.indexOfWord]
            })
            GeneralData.sharedInstance.userWords?.remove(at: self.indexOfWord)
            GeneralData.sharedInstance.userWords?.insert(word, at: self.indexOfWord)
            if oldFavoriteWords as AnyObject? !== GeneralData.sharedInstance.favoriteWords as AnyObject? {
                GeneralData.sharedInstance.favoriteWords?.append(word)
            }
            self.words = GeneralData.sharedInstance.userWords
            self.updateLabels()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }

}
