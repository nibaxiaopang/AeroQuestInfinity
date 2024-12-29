//
//  PrivacyViewController.swift
//  AeroQuestInfinity
//
//  Created by AeroQuest Infinity on 2024/12/27.
//


@preconcurrency import WebKit

class AeroQuestPrivacyViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate  {

    //MARK: - Declare IBOutlets
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var ppWebView: WKWebView!
    @IBOutlet weak var topCos: NSLayoutConstraint!
    @IBOutlet weak var bottomCos: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    //MARK: - Declare Variables
    var backAction: (() -> Void)?
    var privacyData: [Any]?
    @objc var url: String?
    let aeroQuestPrivacyPolicyUrl = "https://www.termsfeed.com/live/80987776-a8f1-48e6-88f2-13b366f61ff5"
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let confData = privacyData, confData.count > 4 {
            let top = (confData[3] as? Int) ?? 0
            let bottom = (confData[4] as? Int) ?? 0
            
            if top > 0 {
                topCos.constant = view.safeAreaInsets.top
            }
            if bottom > 0 {
                bottomCos.constant = view.safeAreaInsets.bottom
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscape]
    }
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.privacyData = UserDefaults.standard.array(forKey: UIViewController.aeroQuestGetUserDefaultKey())
        initSubViews()
        initNavView()
        initWebView()
        aeroQuestStartLoadWebView()
    }
    
    //MARK: - Functions
    @objc func backClick() {
        backAction?()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - INIT
    private func initSubViews() {
        ppWebView.scrollView.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .black
        ppWebView.backgroundColor = .black
        ppWebView.isOpaque = false
        ppWebView.scrollView.backgroundColor = .black
        indicatorView.hidesWhenStopped = true
    }
    
    private func initNavView() {
        guard let url = url, !url.isEmpty else {
            ppWebView.scrollView.contentInsetAdjustmentBehavior = .automatic
            return
        }
        
        self.backButton.isHidden = true
        navigationController?.navigationBar.tintColor = .systemBlue
        
        if let _ = backAction {
            let image = UIImage(systemName: "xmark")
            let rightButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(backClick))
            navigationItem.rightBarButtonItem = rightButton
        }
    }
    
    private func initWebView() {
        guard let confData = privacyData, confData.count > 7 else { return }
        
        let userContentC = ppWebView.configuration.userContentController
        
        if let ty = confData[18] as? Int, ty == 1 || ty == 2 {
            if let trackStr = confData[5] as? String {
                let trackScript = WKUserScript(source: trackStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentC.addUserScript(trackScript)
            }
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let bundleId = Bundle.main.bundleIdentifier,
               let wgName = confData[7] as? String {
                let inPPStr = "window.\(wgName) = {name: '\(bundleId)', version: '\(version)'}"
                let inPPScript = WKUserScript(source: inPPStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentC.addUserScript(inPPScript)
            }
            
            if let messageHandlerName = confData[6] as? String {
                userContentC.add(self, name: messageHandlerName)
            }
            
            if let messageHandlerName = confData[31] as? String {
                userContentC.add(self, name: messageHandlerName)
            }
        }
        
        else if let ty = confData[18] as? Int, ty == 3 {
            if let trackStr = confData[29] as? String {
                let trackScript = WKUserScript(source: trackStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentC.addUserScript(trackScript)
            }
            
            if let messageHandlerName = confData[6] as? String {
                userContentC.add(self, name: messageHandlerName)
            }
        }
        
        else {
            userContentC.add(self, name: confData[19] as? String ?? "")
        }
        
        ppWebView.navigationDelegate = self
        ppWebView.uiDelegate = self
    }
    
    
    private func aeroQuestStartLoadWebView() {
        let urlStr = url ?? aeroQuestPrivacyPolicyUrl
        guard let url = URL(string: urlStr) else { return }
        
        indicatorView.startAnimating()
        let request = URLRequest(url: url)
        ppWebView.load(request)
    }
    
    private func aeroQuestReloadWebViewData(_ adurl: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let storyboard = self.storyboard,
               let adView = storyboard.instantiateViewController(withIdentifier: "AeroQuestPrivacyViewController") as? AeroQuestPrivacyViewController {
                adView.url = adurl
                adView.backAction = { [weak self] in
                    let close = "window.closeGame();"
                    self?.ppWebView.evaluateJavaScript(close, completionHandler: nil)
                }
                let nav = UINavigationController(rootViewController: adView)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let confData = privacyData, confData.count > 9 else { return }
        
        let name = message.name
        if name == (confData[6] as? String),
           let trackMessage = message.body as? [String: Any] {
            let tName = trackMessage["name"] as? String ?? ""
            let tData = trackMessage["data"] as? String ?? ""
            
            if let ty = confData[18] as? Int, ty == 1 {
                if let data = tData.data(using: .utf8) {
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if tName != (confData[8] as? String) {
                                aeroQuestASendEvent(tName, values: jsonObject)
                                return
                            }
                            if tName == (confData[9] as? String) {
                                return
                            }
                            if let adId = jsonObject["url"] as? String, !adId.isEmpty {
                                aeroQuestReloadWebViewData(adId)
                            }
                        }
                    } catch {
                        aeroQuestASendEvent(tName, values: [tName: data])
                    }
                } else {
                    aeroQuestASendEvent(tName, values: [tName: tData])
                }
            } else if let ty = confData[18] as? Int, ty == 2 {
                aeroQuestAfSendEvents(tName, paramsStr: tData)
            } else {
                if tName == confData[28] as? String {
                    if let url = URL(string: tData),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else {
                    aeroQuestAfSendEvent(withName: tName, value: tData)
                }
            }
            
        } else if name == (confData[19] as? String) {
            if let messageBody = message.body as? String,
               let dic = aeroQuestJsonToDic(withJsonString: messageBody) as? [String: Any],
               let evName = dic["funcName"] as? String,
               let evParams = dic["params"] as? String {
                
                if evName == (confData[20] as? String) {
                    if let uDic = aeroQuestJsonToDic(withJsonString: evParams) as? [String: Any],
                       let urlStr = uDic["url"] as? String,
                       let url = URL(string: urlStr),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else if evName == (confData[21] as? String) {
                    aeroQuestSendEvents(withParams: evParams)
                }
            }
        } else if name == (confData[31] as? String) {
            if let data = message.body as? [String: Any], let key = data["action"] as? String {
                if key == (confData[32] as? String) , let params = data["params"] as? [String: Any], let url = params["url"] as? String, let back = params["backButtonStyle"] as? Int {
                    let navConfig = params["naviConfig"] as? [String: String]
                    self.aeroQuestReloadWebViewData(url, back: back, title: navConfig?["title"])
                } else if key == (confData[33] as? String), let params = data["params"] as? [String: Any], let url = params["url"] as? String, let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    private func aeroQuestReloadWebViewData(_ adurl: String , back: Int, title: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let storyboard = self.storyboard,
               let adView = storyboard.instantiateViewController(withIdentifier: "AeroQuestPrivacyViewController") as? AeroQuestPrivacyViewController {
                adView.url = adurl
                adView.title = title
                if back == 1 {
                    adView.backAction = { [weak self] in
                        let close = "window.closeGame();"
                        self?.ppWebView.evaluateJavaScript(close, completionHandler: nil)
                    }
                }
                let nav = UINavigationController(rootViewController: adView)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.indicatorView.stopAnimating()
        }
    }
    
    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            UIApplication.shared.open(url)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        if authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        }
    }
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
