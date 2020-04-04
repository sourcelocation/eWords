//
//  WordsViewController.swift
//  eWords2
//
//  Created by Matthew on 17.02.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit
import AVFoundation

class WordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WordsViewControllerDelegate {
    func presentAlert() {
        present(buildAlert(), animated: true, completion: nil)
    }
    
    @IBOutlet weak var plusButton: UIBarButtonItem!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = collectionName
        tableView1.dataSource = self
        tableView1.delegate = self
        if collectionWords != nil {
            plusButton.isEnabled = false
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionWords?.count ?? words?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return collectionWords == nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            GeneralData.sharedInstance.favoriteWords = GeneralData.sharedInstance.favoriteWords?.filter({ (word) -> Bool in
                return word !== words?[indexPath.row]
            })
            print(GeneralData.sharedInstance.favoriteWords ?? [])
            words?.remove(at: indexPath.row)
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
        print(GeneralData.sharedInstance.favoriteWords ?? [])
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
        let alert = UIAlertController(title: "Add a new word", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Foreign language's word"
            textField.text = self.rememberedWord?.foreignWord ?? ""
            textField.autocapitalizationType = .sentences
        }
        alert.addTextField { (textField2) in
            textField2.placeholder = "Native language's word"
            textField2.text = self.rememberedWord?.nativeWord ?? ""
            textField2.autocapitalizationType = .sentences
        }
        
        let textFields = alert.textFields
        
        alert.addAction(.init(title: "Add", style: .default, handler: { (alert) in
            let foreignText = textFields?[0].text ?? ""
            let nativeText = textFields?[1].text ?? ""
            let word = Word()
            word.foreignWord = foreignText
            word.nativeWord = nativeText
            self.addWord(word: word)
            self.rememberedWord = nil
        }))
        alert.addAction(.init(title: "Dictionary", style: .default, handler: { (alert) in
            let foreignText = textFields?[0].text ?? ""
            let nativeText = textFields?[1].text ?? ""
            let word = Word()
            word.foreignWord = foreignText
            word.nativeWord = nativeText
            self.rememberedWord = word
            if ReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word.foreignWord ?? "Error") {
                let ref: ReferenceLibraryViewController = ReferenceLibraryViewController(term: word.foreignWord ?? "Error")
                ref.delegate = self
                self.present(ref, animated: false, completion: nil)
            } else {
                let alert = UIAlertController(title: "Meaning", message: "Couldn't find meaning for word \"\(word.foreignWord ?? "Error")\". Go to Settings -> General -> Dictionaries, and then download dictionaries", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    func addWord(word:Word) {
        if words == nil {
            words = [word]
        } else {
           words?.append(word)
        }
        print(words ?? "No words")
        tableView1.reloadData()
        
        let word = Word()
        word.foreignWord = "Apple"
        word.nativeWord = "Яблоко"
        
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
            words = words!.sorted{ $0.foreignWord!.lowercased() < $1.foreignWord!.lowercased() }
            tableView1.reloadData()
        } else if collectionWords != nil {
            collectionWords = collectionWords!.sorted{ $0.foreignWord!.lowercased() < $1.foreignWord!.lowercased() }
            tableView1.reloadData()
        }
    }
    func reverseLabels() {
        areLabelsReversed = !(areLabelsReversed)
        tableView1.reloadData()
    }

}
