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
    var userWords: [Word]?
    var foreignLanguageCode: String?
    var nativeLanguageCode: String?
    var areLabelsReversed: Bool = false
    var boughtCollections: [String] = []
    var favoriteWords: [Word]?
    var collectionsData: [String:[[String:String]]] = [:]
    func makeCollectionDataSmaller(collection: [[String:String]]) -> [Word] {
        let nativeShortCode = "ru"
        let foreignShortCode = "en"
        var newCollectionData: [Word] = []
        for wordInDifferentLangs in collection {
            let word = Word()
            word.nativeWord = wordInDifferentLangs[nativeShortCode]
            word.foreignWord = wordInDifferentLangs[foreignShortCode]
            newCollectionData.append(word)
        }
        return newCollectionData
        
    }
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
