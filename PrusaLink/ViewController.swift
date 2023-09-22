//
//  ViewController.swift
//  PrusaLink
//
//  Created by George Waters on 9/5/23.
//

import UIKit
import SwiftUI
import Combine
import WebKit

class ViewController: UIViewController {
    
    let REQUEST_TIMEOUT: TimeInterval = 30
    
    var ipAddressChanged = false
        
    weak var logoView: UIView!
    var logoConstraint: NSLayoutConstraint!

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    weak var loadingWebView: WKWebView?
    
    lazy var bundledHTML: String = Bundle.main.loadResource("main", withExension: ".html")!
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addPullToRefresh()
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        let logoView = getLogoView()
        navigationItem.titleView = logoView
        logoView.isHidden = true
        self.logoView = logoView
        
        addLoadingWebView()
        
        loadPrinterWebsite()
        
        Settings.global.$ipAddress
            .receive(on: DispatchQueue.global(qos: .default))
            .debounce(for: .seconds(1), scheduler: RunLoop.current)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.ipAddressChanged = true
            }.store(in: &cancellables)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLogoConstraint()
        self.logoView.isHidden = false
    }
    
    @IBAction func settingsBarButtonItemPressed(_ sender: UIBarButtonItem) {
        let settingsHostingController = UIHostingController(rootView: SettingsSwiftUIView())
        navigationController?.pushViewController(settingsHostingController, animated: true)
    }
    
    func loadPrinterWebsite() {
        guard let ipAddress = Settings.global.ipAddress else {
            webView.loadHTMLString(getHTMLFor(
                header: "No IP Address Set",
                body: ["Click the gear icon to set the IP Address of the printer."]
            ), baseURL: nil)
            return
        }
        
        guard validateIPAddress(ipToValidate: ipAddress),
              let prusalinkURL = URL(string: "http://\(ipAddress)/") else {
            webView.loadHTMLString(getHTMLFor(
                header: "IP Address Invalid",
                body: ["Click the gear icon to enter a valid local IP Address for the printer."]
            ), baseURL: nil)
            return
        }
        
        ipAddressChanged = false
        webView.load(URLRequest(url: prusalinkURL, timeoutInterval: REQUEST_TIMEOUT))
    }
    
    func refreshPrinterWebsite() {
        if webView.url == nil || webView.url?.absoluteString == "about:blank" || ipAddressChanged {
            loadPrinterWebsite()
        } else {
            guard let url = webView.url else {
                return
            }
            let refreshRequest = URLRequest(url: url, timeoutInterval: REQUEST_TIMEOUT)
            webView.load(refreshRequest)
        }
    }
    
    @objc func pullToRefresh(sender: UIRefreshControl) {
       refreshPrinterWebsite()
    }
    
    func addPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(sender:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    func getLogoView() -> UIView {
        let logo = UIImage(named: "Logo")
        let logoView = UIImageView(image: logo)
        logoView.clipsToBounds = false
        logoView.contentMode = .scaleAspectFill
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor, multiplier: 4.153).isActive = true
        
        let containerView = UIView(frame: .zero)
        containerView.clipsToBounds = true
        containerView.isOpaque = false
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(logoView)
        
        containerView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: logoView.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: logoView.heightAnchor, constant: 4).isActive = true
        
        logoConstraint = containerView.centerYAnchor.constraint(equalTo: logoView.centerYAnchor, constant: 8)
        logoConstraint.isActive = true
                
        return containerView
    }
    
    func addLoadingWebView() {
        let loadingWebView = WKWebView(frame: .zero)
        loadingWebView.isOpaque = false
        loadingWebView.backgroundColor = UIColor(named: "BackgroundColor")
        loadingWebView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingWebView)
        
        loadingWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loadingWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loadingWebView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        loadingWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        loadingWebView.loadHTMLString(getHTMLFor(header: "Loading PrusaLink", body: nil, activityIndicator: true), baseURL: nil)
        
        self.loadingWebView = loadingWebView
    }
    
    func getHTMLFor(header: String, body: [String]?, activityIndicator: Bool = false) -> String {
        let activityIndicatorHTML = """
        <span class="loading">
            <span class="loading-dot"></span>
            <span class="loading-dot"></span>
            <span class="loading-dot"></span>
            <span class="loading-dot"></span>
        </span>
        """
        var htmlString = ""
        htmlString = "<h1>\(header)\(activityIndicator ? activityIndicatorHTML : "")</h1>"
        if let body = body {
            for p in body {
                htmlString += "<p>\(p)</p>"
            }
        }
        return bundledHTML.replacingOccurrences(of: "{{ body }}", with: htmlString)
    }
    
    func validateIPAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) != 1 {
            // IPv4 peer.
            return false
        }
        
        return ipToValidate.contains(/(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/)
    }
}

extension ViewController: WKNavigationDelegate {
    func removeAllCredentials() {
        let allCredentials = URLCredentialStorage.shared.allCredentials
        allCredentials.forEach { (protectionSpace: URLProtectionSpace, credentialDict: [String : URLCredential]) in
            credentialDict.forEach { (credentialKey: String, credential: URLCredential) in
                URLCredentialStorage.shared.remove(credential, for: protectionSpace)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        removeAllCredentials() // Not needed anymore because we only store the credential for the session
        
        guard let username = Settings.global.username else {
            completionHandler(.performDefaultHandling, nil)
            webView.loadHTMLString(getHTMLFor(
                header: "No Username Set",
                body: ["Click the gear icon to enter a valid username for the printer."]
            ), baseURL: nil)
            
            if let loadingWebView = loadingWebView {
                loadingWebView.removeFromSuperview()
            }
            return
        }
        
        guard let password = Settings.global.password else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            webView.loadHTMLString(getHTMLFor(
                header: "No Password Set",
                body: ["Click the gear icon to enter a valid password for the printer."]
            ), baseURL: nil)
            
            if let loadingWebView = loadingWebView {
                loadingWebView.removeFromSuperview()
            }
            return
        }
        
        let mk4Credentials = URLCredential(user: username, password: password, persistence: .forSession)
        
        if challenge.previousFailureCount < 3 {
            completionHandler(.useCredential, mk4Credentials)
        } else {
            completionHandler(.performDefaultHandling, nil)
            webView.loadHTMLString(getHTMLFor(
                header: "Unable to Login",
                body: ["Logging in to the printer with the provided credentials failed. Please check the username and password and try again."]
            ), baseURL: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished Loading")
        if let refreshControl = webView.scrollView.refreshControl,
           refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        if let loadingWebView = loadingWebView {
            loadingWebView.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Webview Failed")
        print(error)
        let error = error as NSError
        webView.loadHTMLString(getHTMLFor(
            header: "Loading PrusaLink Failed",
            body: [error.localizedDescription, "Error Domain: \(error.domain)", "Code: \(error.code)"]
        ), baseURL: nil)
        
        if let loadingWebView = loadingWebView {
            loadingWebView.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Webview Failed")
        print(error)
        let error = error as NSError
        webView.loadHTMLString(getHTMLFor(
            header: "Loading PrusaLink Failed",
            body: [error.localizedDescription, "Error Domain: \(error.domain)", "Code: \(error.code)"]
        ), baseURL: nil)
        
        if let loadingWebView = loadingWebView {
            loadingWebView.removeFromSuperview()
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("Webview Process Terminated")
        webView.loadHTMLString(getHTMLFor(
            header: "Loading PrusaLink Failed",
            body: ["Content process terminated."]
        ), baseURL: nil)
        
        if let loadingWebView = loadingWebView {
            loadingWebView.removeFromSuperview()
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func updateLogoConstraint() {
        let logoViewOffset = view.safeAreaInsets.top - logoView.frame.height - 20
        logoConstraint.constant =  min(0, logoViewOffset + webView.scrollView.contentOffset.y)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateLogoConstraint()
    }
}

