//
//  PrusaWebViewController.swift
//  PrusaLink
//
//  Created by George Waters on 9/5/23.
//

import UIKit
import SwiftUI
import Combine
import WebKit

class PrusaWebViewController: UIViewController {
    
    static let storyboardID = "prusaWebVC"
    
    let REQUEST_TIMEOUT: TimeInterval = 30
    
    @IBOutlet weak var webView: WKWebView!
    
    weak var loadingWebView: WKWebView?
    
    lazy var bundledHTML: String = Bundle.main.loadResource("main", withExension: ".html")!
    
    var cancellables: Set<AnyCancellable> = []
    
    var printer: Printer {
        didSet {
            if oldValue.ipAddress != printer.ipAddress ||
               oldValue.username  != printer.username  ||
               oldValue.password  != printer.password {
                loadPrinterWebsite()
            }
        }
    }
    
    @Binding var logoViewOffset: CGFloat
    
    init?(coder: NSCoder, printer: Printer, logoViewOffset: Binding<CGFloat>) {
        self.printer = printer
        self._logoViewOffset = logoViewOffset
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.refreshControl = refreshWithHandler { [weak self] _ in
            self?.refreshPrinterWebsite()
        }
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        
        addLoadingWebView()
        
        loadPrinterWebsite()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadPrinterWebsite() {
        guard let ipAddress = printer.ipAddress else {
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
        
        webView.load(URLRequest(url: prusalinkURL, timeoutInterval: REQUEST_TIMEOUT))
    }
    
    func refreshPrinterWebsite() {
        if webView.url == nil || webView.url?.absoluteString == "about:blank" {
            loadPrinterWebsite()
        } else {
            guard let url = webView.url else {
                return
            }
            let refreshRequest = URLRequest(url: url, timeoutInterval: REQUEST_TIMEOUT)
            webView.load(refreshRequest)
        }
    }
    
    func refreshWithHandler(_ handler: @escaping UIActionHandler) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction(handler: handler), for: .valueChanged)
        return refreshControl
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
        
        loadingWebView.scrollView.refreshControl = refreshWithHandler { [weak self] _ in
            loadingWebView.scrollView.refreshControl?.endRefreshing()
            self?.refreshPrinterWebsite()
        }
        
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

extension PrusaWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let username = printer.username else {
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
        
        guard let password = printer.password else {
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
        
        let mk4Credentials = URLCredential(user: username, password: password, persistence: .none)
        
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
        webView.scrollView.refreshControl?.endRefreshing()
        
        if let loadingWebView = loadingWebView {
            loadingWebView.removeFromSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Webview Failed")
        print(error)
        if webView.isLoading { // We are still loading so we must be trying again, don't cancel by displaying error
            print("Ignoring Error")
            return
        }
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
        if webView.isLoading { // We are still loading so we must be trying again, don't cancel by displaying error
            print("Ignoring Error")
            return
        }
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

extension PrusaWebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffset = -view.safeAreaInsets.top - webView.scrollView.contentOffset.y + 60
        logoViewOffset = min(max(-44, scrollOffset), 0)
    }
}

