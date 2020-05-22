//
//  SceneDelegate.swift
//  eWords2
//
//  Created by Matthew on 17.02.2020.
//  Copyright © 2020 iMac Matthew. All rights reserved.
//

import UIKit
import GoogleMobileAds

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loadUserWords()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        saveUserWords()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        saveUserWords()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
//         Called as the scene transitions from the background to the foreground.
//         Use this method to undo the changes made on entering the background.
        saveUserWords()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        saveUserWords()
    }
    
     func saveUserWords(){
           let userWordsData = try? JSONEncoder().encode(GeneralData.sharedInstance.allUserWords)
           let favoritesData = try? JSONEncoder().encode(GeneralData.sharedInstance.favoriteWords)
           UserDefaults.standard.set(userWordsData, forKey: "allUserWords")
           UserDefaults.standard.set(favoritesData, forKey: "favorites")
           UserDefaults.standard.set(GeneralData.sharedInstance.nativeLanguageCode, forKey: "nativeLang")
           UserDefaults.standard.set(GeneralData.sharedInstance.foreignLanguageCode, forKey: "foreignLang")
       }
       func loadUserWords(){
           let userWordsData = UserDefaults.standard.data(forKey: "allUserWords")
           let favoriteData = UserDefaults.standard.data(forKey: "favorites")
           if userWordsData != nil {
               let userWordsArray = try? JSONDecoder().decode([String:[Word]].self, from: userWordsData!)
               GeneralData.sharedInstance.allUserWords = userWordsArray
           }
           if favoriteData != nil {
               let favoriteArray = try? JSONDecoder().decode([Word].self, from: favoriteData!)
               GeneralData.sharedInstance.favoriteWords = favoriteArray
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
}


extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        if let data = object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(type, from: data) {
            return value
        }
        return nil
    }
}
