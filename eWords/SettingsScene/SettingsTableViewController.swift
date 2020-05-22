//
//  SettingsTableViewController.swift
//  eWords
//
//  Created by iMac on 15.04.2020.
//  Copyright © 2020 iMac. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var cellTitleNames = ["Version","Statistics","Native language","Foreign language","Flash cards tempo","Auto-hide info","Auto-hide info time","Help"]
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cellTitleNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        cell.titleLabel?.text = cellTitleNames[indexPath.row]
        cell.customDetailLabel.text = ""
        if cellTitleNames[indexPath.row] == "Version" {
            cell.titleLabel?.text = cellTitleNames[indexPath.row]
            var versionNumber = Bundle.main.releaseVersionNumber
            if (Int(Bundle.main.buildVersionNumber!) == nil) {
                versionNumber = "\(versionNumber ?? "Unknown"), \(Bundle.main.buildVersionNumber ?? "Unknown")"
            }
            cell.customDetailLabel?.text = versionNumber
            cell.customImageView?.image = UIImage(named: cellTitleNames[indexPath.row])
            return cell
        }
        if cellTitleNames[indexPath.row] == "Foreign language" {
            var languageName = ""
            for language in GeneralData.sharedInstance.languageData {
                if language[1] == GeneralData.sharedInstance.foreignLanguageCode, languageName == "" {
                    languageName = language[3]
                }
            }
            cell.titleLabel?.text = cellTitleNames[indexPath.row]
            cell.customDetailLabel?.text = languageName
            cell.customImageView?.image = UIImage(named: cellTitleNames[indexPath.row])
            return cell
        }
        if cellTitleNames[indexPath.row] == "Native language" {
            var languageName = ""
            for language in GeneralData.sharedInstance.languageData {
                if language[1] == GeneralData.sharedInstance.nativeLanguageCode, languageName == "" {
                    languageName = language[3]
                }
            }
            cell.titleLabel?.text = cellTitleNames[indexPath.row]
            cell.customDetailLabel?.text = languageName
            cell.customImageView?.image = UIImage(named: cellTitleNames[indexPath.row])
            return cell
        }
        if indexPath.row == 4 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cardTempo") as! SliderTableViewCell
            cell2.slider.value = Float(GeneralData.sharedInstance.cardsTempo * 10)
            cell2.textTitle?.text = cellTitleNames[indexPath.row]
            cell2.slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
            cell2.imageViewIcon?.image = UIImage(named: cellTitleNames[indexPath.row])
            return cell2
        }
        if indexPath.row == 5 {
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(GeneralData.sharedInstance.autoDismissAnswer, animated: false)
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
        }
        if indexPath.row == 6 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cardTempo") as! SliderTableViewCell
            cell2.slider.value = Float(GeneralData.sharedInstance.autoDismissTime)
            cell2.slider.maximumValue = 20
            cell2.slider.minimumValue = 3
            cell2.sliderValueLabel.text = "\((Double(cell2.slider.value) / 10).rounded(toPlaces: 1))s"
            cell2.textTitle?.text = cellTitleNames[indexPath.row]
            cell2.slider.addTarget(self, action: #selector(sliderValueChanged2(sender:)), for: .valueChanged)
            cell2.imageViewIcon?.image = UIImage(named: cellTitleNames[indexPath.row])
            return cell2
        }
        if indexPath.row == 7 {
            cell.textLabel?.textColor = .systemBlue
        }
        if cellTitleNames[indexPath.row] != "Version" {
           cell.accessoryType = .disclosureIndicator
        }
        cell.customImageView?.image = UIImage(named: cellTitleNames[indexPath.row])
        return cell
    }
    @objc func switchChanged(_ sender : UISwitch!){
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        UserDefaults.standard.set(sender.isOn, forKey: "autoDismissAnswer")
        GeneralData.sharedInstance.autoDismissAnswer = sender.isOn
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    @objc func sliderValueChanged(sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! SliderTableViewCell
        cell.sliderValueLabel.text = "\((Double(cell.slider.value) / 10).rounded(toPlaces: 1))s"
        GeneralData.sharedInstance.cardsTempo = Double(cell.slider.value / 10)
    }
    @objc func sliderValueChanged2(sender: UIButton) {
        let cell = tableView.cellForRow(at: IndexPath(row: 6, section: 0)) as! SliderTableViewCell
        cell.sliderValueLabel.text = "\((Double(cell.slider.value) / 10).rounded(toPlaces: 1))s"
        GeneralData.sharedInstance.autoDismissTime = Double(cell.slider.value)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            UIApplication.shared.open(URL(string: "itms://itunes.apple.com/app/id" + "1492495448")!, options: [:], completionHandler: nil)
        }
        if indexPath.row == 1 {
            performSegue(withIdentifier: "showStats", sender: nil)
        }
        if indexPath.row == 2 {
            let actionSheet = UIAlertController(title: "Change native language", message: "Select your native language. Current language: \(String(describing: GeneralData.sharedInstance.nativeLanguageCode!))", preferredStyle: .actionSheet)
            for language in GeneralData.sharedInstance.languageData {
                let languageName = language[0]
                actionSheet.addAction(.init(title: languageName, style: .default, handler: .some({ (alert) in
                    GeneralData.sharedInstance.nativeLanguageCode = language[1]
                    tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("reloadWordsTable"), object: nil)
                    UserDefaults.standard.set(GeneralData.sharedInstance.nativeLanguageCode, forKey: "nativeLang")
                })))
            }
            actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            present(actionSheet, animated: true, completion: nil)
        }
        if indexPath.row == 3 {
            let actionSheet = UIAlertController(title: "Change foreign language", message: "Select the language you want to learn (Your words will be saved). Current language: \(String(describing: GeneralData.sharedInstance.foreignLanguageCode!))", preferredStyle: .actionSheet)
            for language in GeneralData.sharedInstance.languageData {
                let languageName = language[0]
                actionSheet.addAction(.init(title: languageName, style: .default, handler: .some({ (alert) in
                    GeneralData.sharedInstance.foreignLanguageCode = language[1]
                    tableView.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("reloadWordsTable"), object: nil)
                    UserDefaults.standard.set(GeneralData.sharedInstance.foreignLanguageCode, forKey: "nativeLang")
                })))
            }
            actionSheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            present(actionSheet, animated: true, completion: nil)
        }
        if indexPath.row == 7 {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
            present(vc, animated: true, completion: nil)
        }
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}
