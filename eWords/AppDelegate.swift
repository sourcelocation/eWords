//
//  AppDelegate.swift
//  eWords2
//
//  Created by Matthew on 17.02.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        GeneralData.sharedInstance.collectionsData = GeneralData.sharedInstance.readJson() as! [String : [[String : String]]]
        // Override point for customization after application launch.
        loadUserWords()
        if UserDefaults.standard.object(forKey: "appVersion") != nil {
            runConverter()
        }
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
        let userWordsData = try? JSONEncoder().encode(GeneralData.sharedInstance.userWords)
        let favoritesData = try? JSONEncoder().encode(GeneralData.sharedInstance.favoriteWords)
        UserDefaults.standard.set(userWordsData, forKey: "userWords")
        UserDefaults.standard.set(favoritesData, forKey: "favorites")
    }
    func loadUserWords(){
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
    }

}

