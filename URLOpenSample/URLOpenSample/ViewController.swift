//
//  ViewController.swift
//  URLOpenSample
//

//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController {
    
    private var redirectButton: UIButton!
    private var webViewButton: UIButton!
    private var statusLabel: UILabel!
    
    private var safariVCInstance: SFSafariViewController?
    private var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // UIの初期設定
    private func setupUI() {
        // SafariVCボタンの設定
        redirectButton = UIButton(type: .system)
        redirectButton.translatesAutoresizingMaskIntoConstraints = false
        redirectButton.setTitle("SFSafariViewControllerを表示", for: .normal)
        redirectButton.addTarget(self, action: #selector(presentSafariViewController), for: .touchUpInside)
        view.addSubview(redirectButton)
                
        // WKWebViewボタンの設定
        webViewButton = UIButton(type: .system)
        webViewButton.translatesAutoresizingMaskIntoConstraints = false
        webViewButton.setTitle("WebViewControllerを表示", for: .normal)
        webViewButton.addTarget(self, action: #selector(presentWebViewController), for: .touchUpInside)
        view.addSubview(webViewButton)
        
        // ステータスラベルの設定
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.text = "ステータス: 準備完了"
        view.addSubview(statusLabel)
        
        // 制約の設定
        NSLayoutConstraint.activate([
            // SafariVCボタンの制約
            redirectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            redirectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            // WKWebViewボタンの制約
            webViewButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webViewButton.topAnchor.constraint(equalTo: redirectButton.bottomAnchor, constant: 20),
            
            // ステータスラベルの制約
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // SafariViewControllerの表示
    @objc func presentSafariViewController() {
        // ローカルホストのURLを使用
        let urlStr = "http://127.0.0.1:3000/step1.html"
        print("test ---------------- presentSafariViewController -- urlStr\(urlStr)")
        let url = URL(string: urlStr)!
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.dismissButtonStyle = .close
        safariVC.modalPresentationStyle = .overFullScreen
        print("test ---------------- presentSafariViewController -- present")
        present(safariVC, animated: true, completion: nil)
    }
    
    
    // WebViewControllerの表示
    @objc func presentWebViewController() {
        // WebViewControllerのインスタンス作成
        let webViewController = WebViewController()
        
        // redirect.htmlを読み込む
        if let url = URL(string: "http://127.0.0.1:3000/step1.html") {
            webViewController.initialURL = url
        }
        
        // リダイレクト検知時のコールバック設定
        webViewController.onRedirectDetected = { [weak self] url in
            self?.statusLabel.text = "WebViewControllerでリダイレクト検知: \(url.absoluteString)"
            print("リダイレクト検知: \(url.absoluteString)")
            
            // パラメータを解析して表示
            self?.processCustomURL(url: url)
        }
        
        // ナビゲーションコントローラでラップして表示
        let navController = UINavigationController(rootViewController: webViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true) {
            self.statusLabel.text = "WebViewController表示中"
        }
    }
    
    // カスタムURLを処理するメソッド
    func handleCustomURL(url: URL) {
        print("test ---------------- handleCustomURL -- url\(url)")
        // SafariViewControllerが表示されている場合は閉じる
        if self.safariVCInstance != nil {
            dismiss(animated: true) { [weak self] in
                // 遅延させてURL処理
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.processCustomURL(url: url)
                }
            }
        }
    }
    
    // 実際のカスタムURL処理ロジック
    private func processCustomURL(url: URL) {
        // URLの説明を表示
        print("test ---- URL受信: \(url.absoluteString)")
        statusLabel.text = "URL受信: \(url.absoluteString)"
        
        // URLからクエリパラメーターを取得
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            var parameterString = ""
            for item in queryItems {
                parameterString += "\(item.name)=\(item.value ?? ""),"
            }
            if !parameterString.isEmpty {
                parameterString.removeLast() // 最後のカンマを削除
            }
            
            // パラメータを表示
            let alertController = UIAlertController(
                title: "カスタムURL受信",
                message: "受信したURL: \(url.absoluteString)\n\nパラメーター: \(parameterString)",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}

// MARK: - SFSafariViewControllerDelegate
extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("test ---------------- safariViewControllerDidFinish -- controller\(controller)")
        // Safari ViewControllerが閉じられた時の処理
        safariVCInstance = nil
    }
    
    // SafariViewControllerが開かれたときの処理
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("test ---------------- didCompleteInitialLoad -- controller\(controller) didLoadSuccessfully:\(didLoadSuccessfully)")
        safariVCInstance = controller
        // ローディングが完了したことをステータスに表示
        statusLabel.text = "ステータス: SafariVC 読み込み完了"
    }
}

