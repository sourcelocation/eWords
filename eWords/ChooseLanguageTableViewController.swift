//
//  ChooseLanguageTableViewController.swift
//  eWords
//
//  Created by iMac on 30.03.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class ChooseLanguageTableViewController: UITableViewController {
    
    let languages = [["English (US)", "en-US", "en", "English"],
                     ["English (UK)", "en-GB", "en", "English"],
                     
                     ["Arabic", "ar-SA", "ar", "Arabic"],
                     ["Chinese (S)", "zh-CN", "zh", "Chinese"],
                     ["Chinese (T)", "zh-TW", "zh", "Chinese"],
                     ["Czech", "cs-CZ", "cs", "Czech"],
                     ["Danish", "da-DK", "da", "Danish"],
                     ["Dutch", "nl-NL", "nl", "Dutch"],
                     ["Finnish", "fi-FI", "fi", "Finnish"],
                     ["French", "fr-FR", "fr", "French"],
                     ["German", "de-DE", "de", "German"],
                     ["Greek", "el-GR", "el", "Greek"],
                     ["Hebrew", "he-IL", "he", "Hebrew"],
                     ["Hindi", "hi", "hi", "Hindi"],
                     ["Hungarian", "hu-HU", "hu", "Hungarian"],
                     ["Indonesian", "id-ID", "id", "Indonesian"],
                     ["Italian", "it-IT", "it", "Italian"],
                     ["Japanese", "ja-JP", "ja", "Japanese"],
                     ["Korean", "ko-KR", "ko", "Korean"],
                     ["Norwegian", "no-NO", "no", "Norwegian"],
                     ["Polish", "pl-PL", "pl", "Polish"],
                     ["Portuguese (Brazil)", "pt-BR", "pt", "Portuguese"],
                     ["Portuguese (Portugal)", "pt-PT", "pt", "Portuguese"],
                     ["Romanian", "ro-RO", "ro", "Romanian"],
                     ["Russian", "ru-RU", "ru", "Russian"],
                     ["Slovak", "sk-SK", "sk", "Slovak"],
                     ["Spanish", "es-ES", "es", "Spanish"],
                     ["Swedish", "sv-SE", "sv", "Swedish"],
                     ["Thai", "th-TH", "th", "Thai"],
                     ["Turkish", "tr-TR", "tr", "Turkish"],
                     ["Other", "en-US", "en" , "Foreign language's"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return languages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = languages[indexPath.row][0]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GeneralData.sharedInstance.foreignLanguageCode = languages[indexPath.row][1]
        GeneralData.sharedInstance.nativeLanguageCode = Locale.current.languageCode
        self.dismiss(animated: true, completion: nil)
    }
    
}
