import UIKit
import AVFoundation

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var showTranslation = true
    var userWords: [Word]? {
        get {
            return GeneralData.sharedInstance.userWords ?? []
        }
        set(newValue) {
            GeneralData.sharedInstance.userWords = newValue
        }
    }
    var favorites: [Word]?
    var areLabelsReversed: Bool {
        get {
            return GeneralData.sharedInstance.areLabelsReversed
        }
        set(newValue) {
            GeneralData.sharedInstance.areLabelsReversed = newValue
        }
    }
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
    @IBOutlet weak var tableView1: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView1.dataSource = self
        tableView1.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let word = favorites?[indexPath.row]
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
        favorites = GeneralData.sharedInstance.favoriteWords
        tableView1.reloadData()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var titleMessage = ""
        if areLabelsReversed {
            titleMessage = favorites?[indexPath.row].foreignWord ?? ""
        } else {
            titleMessage = favorites?[indexPath.row].nativeWord ?? ""
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
        vc?.word = favorites?[indexPathRowPressed ?? 0]
        vc?.words = favorites
    }
    @objc func alertControllerBackgroundTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func starPressed(sender: UIButton) {
        let word = favorites![sender.tag]
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
        print(GeneralData.sharedInstance.favoriteWords)
    }
    
    @objc func speakWord(_ sender: UIButton) {
        let word = favorites?[sender.tag].foreignWord
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
    func shuffleWords() {
        favorites?.shuffle()
        tableView1.reloadData()
    }
    func sortWords() {
        if areLabelsReversed {
            favorites = favorites!.sorted{ $0.nativeWord!.lowercased() < $1.nativeWord!.lowercased() }
            tableView1.reloadData()
        } else {
            favorites = favorites!.sorted{ $0.foreignWord!.lowercased() < $1.foreignWord!.lowercased() }
            tableView1.reloadData()
        }
    }
    func reverseLabels() {
        areLabelsReversed = !(areLabelsReversed)
        tableView1.reloadData()
    }

}

