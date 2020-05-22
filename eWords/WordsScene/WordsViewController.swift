//
//  WordsViewController.swift
//  eWords2
//
//  Created by Matthew on 17.02.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit
import GoogleMobileAds

class WordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WordsViewControllerDelegate {
    @IBOutlet weak var plusButton: UIBarButtonItem!
    @IBAction func showButtonPressed(_ sender: UIBarButtonItem) {
        showTranslation = !showTranslation
        if showTranslation {
            sender.title = "Hide"
        } else {
            sender.title = "Show"
        }
        tableView1.reloadData()
    }
    @IBAction func reverseButtonPressed(_ sender: UIBarButtonItem) {
        reverseLabels()
    }
    @IBAction func shuffleButtonPressed(_ sender: UIBarButtonItem) {
        shuffleWords()
    }
    @IBAction func sortButtonPressed(_ sender: UIBarButtonItem) {
        sortWords()
    }
    @IBAction func addWordButtonPressed(_ sender: UIBarButtonItem) {
        present(buildAlert(), animated: true, completion: nil)
    }
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var adBanner: GADBannerView!
    var isViewingAllWords = false
    var showTranslation = true
    var words: [Word]? {
        get {
            return GeneralData.sharedInstance.userWords ?? []
        }
        set(newValue) {
            GeneralData.sharedInstance.userWords = newValue
        }
    }
    var collectionName = ""
    var collectionWords: [Word]?
    var areLabelsReversed: Bool {
        get {
            return GeneralData.sharedInstance.areLabelsReversed
        }
        set(newValue) {
            GeneralData.sharedInstance.areLabelsReversed = newValue
        }
    }
    var rememberedWord:Word?
    var indexPathRowPressed: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableView(notification:)), name: Notification.Name("reloadAllWords"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(notification:)), name: Notification.Name("reloadWordsTable"), object: nil)
        title = collectionName
        adBanner.adUnitID = "ca-app-pub-6804648379784599/9944641111"
        adBanner.rootViewController = self
        adBanner.load(GADRequest())
        self.view.bringSubviewToFront(adBanner)
        tableView1.dataSource = self
        tableView1.delegate = self
        if collectionWords != nil && isViewingAllWords == false {
            plusButton.isEnabled = false
        }
    }
    @objc func reloadTableView(notification: Notification) {
        collectionWords = getAllWords()
        tableView1.reloadData()
    }
    @objc func reloadData(notification: Notification) {
        tableView1.reloadData()
    }
    
    func presentAlert() {
        present(buildAlert(), animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (collectionWords?.count ?? words?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return collectionWords == nil || (isViewingAllWords && words!.contains(where: { (word) -> Bool in
            return word === collectionWords?[indexPath.row]
        }) )
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            GeneralData.sharedInstance.favoriteWords = GeneralData.sharedInstance.favoriteWords?.filter({ (word) -> Bool in
                if isViewingAllWords == false {
                    return word !== words?[indexPath.row]
                } else {
                    return word !== collectionWords?[indexPath.row]
                }
            })
            if isViewingAllWords {
                GeneralData.sharedInstance.userWords = GeneralData.sharedInstance.userWords?.filter({ (word) -> Bool in
                    return word !== collectionWords?[indexPath.row]
                })
                collectionWords = getAllWords()
            } else {
               words?.remove(at: indexPath.row)
            }
            self.tableView1.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = collectionWords?[indexPath.row] ?? words?[indexPath.row]
        if showTranslation == false {
            let cell = tableView1.dequeueReusableCell(withIdentifier: "cellWithoutTranslation") as! WithoutTranslationTableViewCell
            if !(areLabelsReversed) {
                cell.wordLabel.text = word?.foreignWord
            } else {
                cell.wordLabel.text = word?.nativeWord
            }
            cell.speakButton.addTarget(self, action: #selector(speakWord(_:)), for: .touchUpInside)
            cell.speakButton.tag = indexPath.row
            if word?.isFavorite ?? false {
                cell.star.setImage(UIImage(named: "starFilled"), for: [])
            } else {
                cell.star.setImage(UIImage(named: "starEmpty"), for: [])
            }
            cell.star.addTarget(self, action: #selector(starPressed(sender:)), for: .touchUpInside)
            cell.star.tag = indexPath.row
            return cell
        } else {
            let cell = tableView1.dequeueReusableCell(withIdentifier: "cellWithTranslation") as! WithTranslationTableViewCell
            if !(areLabelsReversed) {
                cell.foreignWordLabel.text = word?.foreignWord
                cell.nativeWordLabel.text = word?.nativeWord
            } else {
                cell.foreignWordLabel.text = word?.nativeWord
                cell.nativeWordLabel.text = word?.foreignWord
            }
            cell.speakButton.addTarget(self, action: #selector(speakWord(_:)), for: .touchUpInside)
            cell.speakButton.tag = indexPath.row
            if word?.isFavorite ?? false {
                cell.star.setImage(UIImage(named: "starFilled"), for: [])
            } else {
                cell.star.setImage(UIImage(named: "starEmpty"), for: [])
            }
            cell.star.addTarget(self, action: #selector(starPressed(sender:)), for: .touchUpInside)
            cell.star.tag = indexPath.row
            return cell
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView1.reloadData()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var titleMessage = ""
        if areLabelsReversed {
            if collectionWords == nil {
               titleMessage = words?[indexPath.row].foreignWord ?? ""
            } else {
                titleMessage = collectionWords?[indexPath.row].foreignWord ?? ""
            }
        } else {
            if collectionWords == nil {
               titleMessage = words?[indexPath.row].nativeWord ?? ""
            } else {
                titleMessage = collectionWords?[indexPath.row].nativeWord ?? ""
            }
        }
        let answerAlert = UIAlertController(title: titleMessage, message: "", preferredStyle: .alert)
        self.present(answerAlert, animated: true) {
            answerAlert.view.superview?.isUserInteractionEnabled = true
            answerAlert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
            if GeneralData.sharedInstance.autoDismissAnswer {
                DispatchQueue.main.asyncAfter(deadline: .now() + GeneralData.sharedInstance.autoDismissTime / 10 - 0.2) {
                    answerAlert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showTranslation {
            return 60
        } else {
            return 43.5
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        indexPathRowPressed = row
        performSegue(withIdentifier: "showAnswer", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? AnswerViewController
        vc?.word = (collectionWords ?? words ?? [])[indexPathRowPressed ?? 0]
        vc?.words = collectionWords ?? words ?? []
        if collectionWords == nil {
            vc?.isShowingUserWords = true
        }
    }
    
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func starPressed(sender: UIButton) {
        let word = (collectionWords ?? words ?? [])[sender.tag]
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
            sender.setImage(UIImage(named: "starFilled"), for: [])
        } else {
            sender.setImage(UIImage(named: "starEmpty"), for: [])
        }
    }
    
    @objc func speakWord(_ sender: UIButton) {
        let word = (collectionWords ?? words ?? [])[sender.tag].foreignWord
        let utterance = AVSpeechUtterance(string: word ?? "")
        utterance.voice = AVSpeechSynthesisVoice(language: GeneralData.sharedInstance.foreignLanguageCode ?? "en-US")
        let synth = AVSpeechSynthesizer()
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }
        synth.speak(utterance)
    }
    
    func buildAlert() -> UIAlertController {
        var message = ""
        if words?.count ?? 0 < 10 {
            message = "Enter a new word and it's translation"
        }
        let alert = UIAlertController(title: "Add a new word", message: message, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            var languageName = ""
            for language in GeneralData.sharedInstance.languageData {
                if language[1] == GeneralData.sharedInstance.foreignLanguageCode {
                    languageName = language[3]
                    textField.placeholder = languageName
                    textField.text = self.rememberedWord?.foreignWord ?? ""
                    textField.autocapitalizationType = .sentences
                    textField.autocorrectionType = .yes
                    return
                }
            }
            
        }
        alert.addTextField { (textField2) in
            var languageName = ""
            for language in GeneralData.sharedInstance.languageData {
                if language[1] == GeneralData.sharedInstance.nativeLanguageCode {
                    languageName = language[3]
                    textField2.placeholder = languageName
                    textField2.text = self.rememberedWord?.nativeWord ?? ""
                    textField2.autocapitalizationType = .sentences
                    textField2.autocorrectionType = .yes
                    return
                }
            }
        }
        
        let textFields = alert.textFields
        
        alert.addAction(.init(title: "OK", style: .default, handler: { (alert) in
            let foreignText = textFields?[0].text ?? ""
            let nativeText = textFields?[1].text ?? ""
            let word = Word()
            word.foreignWord = foreignText
            word.nativeWord = nativeText
            self.addWord(word: word)
            self.rememberedWord = nil
        }))
        alert.actions[0].isEnabled = false
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            alert.actions[0].isEnabled = !(textFields?[0].text!.isEmpty ?? true) && !(textFields?[1].text!.isEmpty ?? true)
        }
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[1], queue: OperationQueue.main) { (notification) -> Void in
            alert.actions[0].isEnabled = !(textFields?[0].text!.isEmpty ?? true) && !(textFields?[1].text!.isEmpty ?? true)
        }
        alert.addAction(.init(title: "Dictionary", style: .default, handler: { (alert) in
            let foreignText = textFields?[0].text ?? ""
            let nativeText = textFields?[1].text ?? ""
            let word = Word()
            word.foreignWord = foreignText
            word.nativeWord = nativeText
            self.rememberedWord = word
            var wordToLookInDictionary = ""
            if word.foreignWord != "" {
                wordToLookInDictionary = word.foreignWord ?? ""
            } else {
                wordToLookInDictionary = word.nativeWord ?? ""
            }
            if ReferenceLibraryViewController.dictionaryHasDefinition(forTerm: wordToLookInDictionary ) {
                let ref: ReferenceLibraryViewController = ReferenceLibraryViewController(term: wordToLookInDictionary )
                ref.delegate = self
                self.present(ref, animated: false, completion: nil)
            } else {
                let alert = UIAlertController(title: "Meaning", message: "Couldn't find meaning for word \"\(wordToLookInDictionary )\". Go to Settings -> General -> Dictionaries, and then download dictionaries", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    func addWord(word:Word) {
        if isViewingAllWords == false {
            if words == nil {
                words = [word]
            } else {
                words?.insert(word, at: 0)
            }
        } else {
            var words = GeneralData.sharedInstance.userWords
            if words == nil {
                words = [word]
            } else {
                words?.insert(word, at: 0)
            }
            GeneralData.sharedInstance.userWords = words
            self.collectionWords = getAllWords()
        }
        tableView1.beginUpdates()
        tableView1.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView1.endUpdates()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.tableView1.reloadData()
        }
        
    }
    func shuffleWords() {
        if collectionWords == nil {
            words?.shuffle()
        } else {
            collectionWords?.shuffle()
        }
        tableView1.reloadData()
    }
    func sortWords() {
        if words != nil, collectionWords == nil {
            if areLabelsReversed {
                words = words!.sorted{ $0.nativeWord!.lowercased() < $1.nativeWord!.lowercased() }
                tableView1.reloadData()
            } else {
                words = words!.sorted{ $0.foreignWord!.lowercased() < $1.foreignWord!.lowercased() }
                tableView1.reloadData()
            }
        } else if collectionWords != nil {
            if areLabelsReversed {
                collectionWords = collectionWords!.sorted{ $0.nativeWord!.lowercased() < $1.nativeWord!.lowercased() }
                tableView1.reloadData()
            } else {
                collectionWords = collectionWords!.sorted{ $0.foreignWord!.lowercased() < $1.foreignWord!.lowercased() }
                tableView1.reloadData()
            }
        }
    }
    func reverseLabels() {
        areLabelsReversed = !(areLabelsReversed)
        tableView1.reloadData()
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
