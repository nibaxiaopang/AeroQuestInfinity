//
//  WelcomeVC.swift
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//


import UIKit

class AeroQuestWelcomeViewController: UIViewController {

    //MARK: - Declare IBOutlets
    
    @IBOutlet weak var playButton: UIButton!
    
    //MARK: - Declare Variables
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aeroQuestNeedShowAdsLocalData()
    }
    
    //MARK: - Functions
    private func aeroQuestNeedShowAdsLocalData() {
        guard self.aeroQuestNeedShowAdsView() else {
            return
        }
        self.playButton.isHidden = true
        aeroQuestGetAdsData { adsData in
            if let adsData = adsData {
                if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                    UIViewController.aeroQuestSetUserDefaultKey(userDefaultKey)
                    if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                        self.aeroQuestShowAdView(locDic[2] as! String)
                    } else {
                        UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                        self.aeroQuestShowAdView(adsUr)
                    }
                    return
                }
            }
            self.playButton.isHidden = false
        }
    }
    
    private func aeroQuestGetAdsData(completion: @escaping ([Any]?) -> Void) {
        
        let url = URL(string: "https://open.znpbfuk\(self.mainHostUrl())/open/aeroQuestGetAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appKey": "3fa7c12724eb407b9999b659e19dc8aa",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "",
            "appLocalized": UIDevice.current.localizedModel ,
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                            completion(adsData)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }
    
    //MARK: - Declare IBAction
    
}
