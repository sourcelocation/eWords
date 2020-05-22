//
//  ExamSelectViewController.swift
//  eWords
//
//  Created by iMac on 15.04.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ExamSelectViewController: UIViewController, GADRewardedAdDelegate {
    
    @IBOutlet weak var writeAnAnswerView: UIView!
    @IBOutlet weak var checkYourselfView: UIView!
    @IBOutlet weak var fourAnswersView: UIView!
    var examType = ""
    var rewardedAd: GADRewardedAd?
    var hadWatchedAnAd = false
    var isThereAnErrorForAd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-6804648379784599/9998114378")
        rewardedAd?.load(DFPRequest()) { error in
            if let error = error {
                // Handle ad failed to load case.
                print(error)
                self.isThereAnErrorForAd = true
            } else {
            
          }
        }
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.writeAnAnswerViewTapped))
        self.writeAnAnswerView.addGestureRecognizer(gesture)
        let gesture2 = UITapGestureRecognizer(target: self, action:  #selector(self.checkYourselfViewTapped))
        self.checkYourselfView.addGestureRecognizer(gesture2)
        let gesture3 = UITapGestureRecognizer(target: self, action:  #selector(self.fourAnswersViewTapped))
        self.fourAnswersView.addGestureRecognizer(gesture3)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        if !GeneralData.sharedInstance.premiumVersion {
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "premium")
//            present(vc, animated: true, completion: nil)
//        }
    }
    
    @objc func writeAnAnswerViewTapped(sender : UITapGestureRecognizer) {
        examType = "WriteAnAnswer"
        showAlert()
    }
    @objc func checkYourselfViewTapped(sender : UITapGestureRecognizer) {
        examType = "CheckYourself"
        showAlert()
    }
    @objc func fourAnswersViewTapped(sender : UITapGestureRecognizer) {
        examType = "FourAnswers"
        showAlert()
    }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "Watch an ad", message: "To start an exam you need to watch a small ad. Would you like to continue?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "Yes", style: .default, handler: { (alert) in
            self.showAd()
        }))
        present(alert, animated: true, completion: nil)
    }
    func showAd() {
        self.hadWatchedAnAd = false
        if isThereAnErrorForAd {
            self.hadWatchedAnAd = false
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(self.examType)VC")
            self.present(vc, animated: true, completion: nil)
            return
        }
        if self.rewardedAd?.isReady == true {
            self.rewardedAd?.present(fromRootViewController: self, delegate:self)
        }
    }
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        startExam()
    }
    func startExam() {
        hadWatchedAnAd = true
    }
    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if hadWatchedAnAd {
            hadWatchedAnAd = false
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(examType)VC")
            present(vc, animated: true, completion: nil)
            
            self.rewardedAd = GADRewardedAd(adUnitID: "ca-app-pub-6804648379784599/9998114378")
            self.rewardedAd?.load(DFPRequest()) { error in
                if let error = error {
                    // Handle ad failed to load case.
                    print(error)
                    self.isThereAnErrorForAd = true
                }
            }
        }
    }

}


