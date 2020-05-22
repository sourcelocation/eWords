//
//  Data.swift
//  eWords2
//
//  Created by Matthew on 17.02.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//
import UIKit

class GeneralData {
    static let sharedInstance = GeneralData()
    var userWords: [Word]? {
        get {
            return allUserWords?[foreignLanguageCode!]
        } set(value) {
            if allUserWords != nil {
                allUserWords?[foreignLanguageCode!] = value
            } else {
                if value != nil {
                    allUserWords = [foreignLanguageCode!:value!]
                }
            }
        }
    }
    var favoriteWords: [Word]? {
        get {
            return allFavoriteWords?[foreignLanguageCode!]
        } set(value) {
            if allFavoriteWords != nil {
                allFavoriteWords?[foreignLanguageCode!] = value
            } else {
                if value != nil {
                    allFavoriteWords = [foreignLanguageCode!:value!]
                }
            }
        }
    }
    var cardsTempo = 0.7
    var foreignLanguageCode: String?
    var nativeLanguageCode: String?
    var areLabelsReversed: Bool = false
    var boughtCollections: [String] = []
    var allFavoriteWords: [String:[Word]]?
    var collectionsData: [String:[[String:String]]] = [:]
    var premiumVersion = false
    var premiumCost = "$1.99"
    var autoDismissAnswer = true
    var autoDismissTime = 10.0
    var allUserWords: [String:[Word]]?
    var languageData: [[String]] = [["English (US)", "en-US", "en", "English"],
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
    func makeCollectionDataSmaller(collection: [[String:String]]) -> [Word] {
        let nativeShortCode = GeneralData.sharedInstance.nativeLanguageCode?[0..<2] ?? "ru"
        let foreignShortCode = GeneralData.sharedInstance.foreignLanguageCode?[0..<2]  ?? "en"
        var newCollectionData: [Word] = []
        for wordInDifferentLangs in collection {
            let word = Word()
            word.nativeWord = wordInDifferentLangs[nativeShortCode]
            word.foreignWord = wordInDifferentLangs[foreignShortCode]
            newCollectionData.append(word)
        }
        return newCollectionData
        
    }
    var firstTimeLaunched = false
    func readJson() -> [String:Any] {
        do {
            if let file = Bundle.main.url(forResource: "Words", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    return object
                } else if json is [Any] {
                    // json is an array
                    return [:]
                } else {
                    print("JSON is invalid")
                    return [:]
                }
            } else {
                print("no file")
                return [:]
            }
        } catch {
            print(error.localizedDescription)
            return [:]
        }
    }
}

class Word: ReflectedStringConvertible, Codable {
    var foreignWord: String?
    var nativeWord: String?
    var isFavorite:Bool {
        for word in GeneralData.sharedInstance.favoriteWords ?? [] {
            if word.foreignWord == foreignWord {
                if word.nativeWord == nativeWord {
                    return true
                }
            }
        }
        return false
    }
}

public protocol ReflectedStringConvertible : CustomStringConvertible { }

extension ReflectedStringConvertible {
  public var description: String {
    let mirror = Mirror(reflecting: self)
    
    var str = "\(mirror.subjectType)("
    var first = true
    for (label, value) in mirror.children {
      if let label = label {
        if first {
          first = false
        } else {
          str += ", "
        }
        str += label
        str += ": "
        str += "\(value)"
      }
    }
    str += ")"
    
    return str
  }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
