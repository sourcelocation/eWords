//
//  AppDelegate.swift
//  eWords2
//
//  Created by Matthew on 17.02.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneralData.sharedInstance.autoDismissAnswer = UserDefaults.standard.bool(forKey: "autoDismissAnswer")
        loadUserWords()
        GeneralData.sharedInstance.collectionsData = GeneralData.sharedInstance.readJson() as! [String : [[String : String]]]
        // Override point for customization after application launch.
        runConverter2()
        if UserDefaults.standard.string(forKey: "appVersion") != "1.3" && UserDefaults.standard.string(forKey: "appVersion") != nil && UserDefaults.standard.string(forKey: "appVersion") != "1.4" {
            runConverter()
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                UserDefaults.standard.set("1.4", forKey: "appVersion")
            }
        }
        if UserDefaults.standard.string(forKey: "appVersion") == "1.3" {
            runConverter2()
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                UserDefaults.standard.set(version, forKey: "appVersion")
            }
        }
        if UserDefaults.standard.object(forKey: "appVersion") == nil {
            // Первый запуск
            GeneralData.sharedInstance.boughtCollections = ["People and things", "Conversation"]
            GeneralData.sharedInstance.firstTimeLaunched = true
            UserDefaults.standard.set(GeneralData.sharedInstance.boughtCollections, forKey: "boughtCollectionsNew")

        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(version, forKey: "appVersion")
        }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func runConverter() {
        let oldUserWords:[[String:String]] = UserDefaults.standard.array(forKey: "words")! as! [[String:String]]
        var newUserWords:[Word] = []
        for word in oldUserWords {
            let newWord:Word? = Word()
            newWord?.foreignWord = word["english"]
            newWord?.nativeWord = word["russian"]
            newUserWords.append(newWord!)
        }
        GeneralData.sharedInstance.userWords = newUserWords
        saveUserWords()
        //         UserDefaults.standard.array(forKey: "words") = nil
    }
    
    func runConverter2() {
        let userWordsData = UserDefaults.standard.data(forKey: "userWords")
        let favoriteData = UserDefaults.standard.data(forKey: "favorites")
        if userWordsData != nil {
            let userWordsArray = try? JSONDecoder().decode([Word].self, from: userWordsData!)
            GeneralData.sharedInstance.userWords = userWordsArray
        }
        if favoriteData != nil {
            let favoriteArray = try? JSONDecoder().decode([Word].self, from: favoriteData!)
            GeneralData.sharedInstance.favoriteWords = favoriteArray
        }
        saveUserWords()
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveUserWords()
    }
    func saveUserWords(){
        let userWordsData = try? JSONEncoder().encode(GeneralData.sharedInstance.allUserWords)
        let favoritesData = try? JSONEncoder().encode(GeneralData.sharedInstance.favoriteWords)
        UserDefaults.standard.set(userWordsData, forKey: "allUserWords")
        UserDefaults.standard.set(favoritesData, forKey: "allFavorites")
        UserDefaults.standard.set(GeneralData.sharedInstance.nativeLanguageCode, forKey: "nativeLang")
        UserDefaults.standard.set(GeneralData.sharedInstance.foreignLanguageCode, forKey: "foreignLang")
    }
    func loadUserWords(){
        let userWordsData = UserDefaults.standard.data(forKey: "allUserWords")
        let favoriteData = UserDefaults.standard.data(forKey: "allFavorites")
        if userWordsData != nil {
            let userWordsArray = try? JSONDecoder().decode([String:[Word]].self, from: userWordsData!)
            GeneralData.sharedInstance.allUserWords = userWordsArray
        }
        if favoriteData != nil {
            let favoriteArray = try? JSONDecoder().decode([String:[Word]].self, from: favoriteData!)
            GeneralData.sharedInstance.allFavoriteWords = favoriteArray
        }
        if UserDefaults.standard.string(forKey: "foreignLang") != nil {
            GeneralData.sharedInstance.foreignLanguageCode = UserDefaults.standard.string(forKey: "foreignLang")
        }
        if UserDefaults.standard.string(forKey: "nativeLang") != nil {
            GeneralData.sharedInstance.nativeLanguageCode = UserDefaults.standard.string(forKey: "nativeLang")
        }
        if UserDefaults.standard.array(forKey: "boughtCollectionsNew") != nil {
            GeneralData.sharedInstance.boughtCollections = UserDefaults.standard.array(forKey: "boughtCollectionsNew") as! [String]
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        saveUserWords()
    }
    
}

