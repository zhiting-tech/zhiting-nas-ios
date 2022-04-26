//
//  webViewController.swift
//  ZhiTingNas
//
//  Created by macbook on 2021/11/4.
//

import UIKit
import WebKit

class WebViewController: BaseViewController {

    var link: String
    var webViewTitle: String?
        
    init(link:String) {
        /// 处理编码问题
        self.link = link
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var webView: WKWebView!

    private lazy var progress: UIProgressView = {
        let progres = UIProgressView.init(progressViewStyle: .default)
        progres.frame = CGRect(x: 0, y: 0, width: Screen.screenWidth, height: 1.5)
        progres.progress = 0
        progres.progressTintColor = .custom(.blue_2da3f6)
        progres.trackTintColor = UIColor.clear
        return progres
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.webViewTitle
        setupWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func setupWebView() {
        
        webView = WKWebView(frame: .zero)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
                
        view.addSubview(webView)
        webView.addSubview(progress)
        
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Screen.k_nav_height)
            make.left.right.bottom.equalToSuperview()
        }
        
        progress.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1.5)
        }
        
        if let linkURL = URL(string: link) {
            webView.load(URLRequest(url: linkURL))
        }
    
    }
    
    
    override func navPop() {
        if webView.canGoBack {
            webView.goBack()
        }else{
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progress.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = ""
        if let webViewTitle = webViewTitle {
            title = webViewTitle
        }

    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progress.isHidden = true
        progress.progress = 0
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        decisionHandler(.allow)
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            challenge.sender?.use(credential, for: challenge)
            // 证书校验通过
            completionHandler(.useCredential, credential)
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }

}

extension WebViewController: WKUIDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progress.alpha = 1.0
            let animal = webView.estimatedProgress > Double(progress.progress)
            progress.setProgress(Float(webView.estimatedProgress), animated: animal)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progress.alpha = 0
                }) { (finished) in
                    self.progress.setProgress(0, animated: false)
                }
            }
        }
    }
    
}
