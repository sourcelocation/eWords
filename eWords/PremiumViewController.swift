//
//  PremiumViewController.swift
//  eWords
//
//  Created by iMac on 15.04.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import SwiftMessages

enum RegisteredPurchase: String {
    
    case premium
}

class NetworkActivityIndicatorManager : NSObject {
    
    private static var loadingCount = 0
    
    class func NetworkOperationStarted() {
        if loadingCount == 0 {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    class func networkOperationFinished(){
        if loadingCount > 0 {
            loadingCount -= 1
            
        }
        
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
}

class PremiumViewController: UIViewController {
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {
            self.tabBarController?.selectedIndex = 0
        })
    }
    @IBAction func restoreButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func buyButtonTapped(_ sender: UIButton) {
        
//        SwiftyStoreKit.purchaseProduct("com.neumark.eWords.premium", quantity: 1, atomically: true) { result in
//            switch result {
//            case .success(let purchase):
//                print("Purchase Success: \(purchase.productId)! 22")
//            case .error(let error):
//                switch error.code {
//                case .unknown: print("Unknown error. Please contact support")
//                case .clientInvalid: print("Not allowed to make the payment")
//                case .paymentCancelled: break
//                case .paymentInvalid: print("The purchase identifier was invalid")
//                case .paymentNotAllowed: print("The device is not allowed to make the payment")
//                case .storeProductNotAvailable: print("The product is not available in the current storefront")
//                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
//                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
//                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
//                default: print((error as NSError).localizedDescription)
//                }
//            }
//        }
        purchase(.premium, atomically: false)
    }
    
    func purchase(_ purchase: RegisteredPurchase, atomically: Bool) {
        
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct("com.neumark.eWords.premium", atomically: atomically) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            print("Purchase done")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
