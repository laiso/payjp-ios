//
//  WebViewController.swift
//  URLOpenSample
//
//  Created on 2025/04/09.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    // WKWebView
    private var webView: WKWebView!
    
    // URLを受け取るプロパティ
    var initialURL: URL?
    
    // 結果表示用のクロージャー
    var onRedirectDetected: ((URL) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        
        // 初期URLがあれば読み込む
        if let url = initialURL {
            loadURL(url)
        }
    }
    
    // WKWebViewの設定
    private func setupWebView() {
        // WKWebViewの設定
        let config = WKWebViewConfiguration()
        
        // JavaScriptを有効化
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        config.preferences = preferences
        
        // WKWebViewの初期化
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // 閉じるボタンを追加
        let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    // URLを読み込む
    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
        title = url.host
    }
    
    // リダイレクトを検知した時の処理
    private func handleRedirect(url: URL) {
        print("WebViewController: リダイレクト検知 - \(url.absoluteString)")
        
        // カスタムスキームの場合
        if url.scheme == "urlsample" {
            print("WebViewController: カスタムURLスキーム検知 - \(url.absoluteString)")
            
            // 結果をコールバックで通知
            onRedirectDetected?(url)
            
            // アラートを表示してクローズ
            let alert = UIAlertController(
                title: "リダイレクト検知",
                message: "URL: \(url.absoluteString)",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "閉じる", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
    }
    
    // 閉じるボタンの処理
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    // ナビゲーション決定時 - URL遷移の制御
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print("WebView: ナビゲーション - \(url.absoluteString)")
            
            // カスタムURLスキームを検出した場合
            if let scheme = url.scheme, scheme == "urlsample" {
                handleRedirect(url: url)
                decisionHandler(.cancel)
                return
            }
        }
        
        // その他の通常ナビゲーションは許可
        decisionHandler(.allow)
    }
}
