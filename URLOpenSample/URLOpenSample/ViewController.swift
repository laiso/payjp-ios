//
//  ViewController.swift
//  URLOpenSample
//

//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    // UI要素
    private var webView: WKWebView!
    private var segmentedControl: UISegmentedControl!
    private var redirectButton: UIButton!
    private var statusLabel: UILabel!
    
    // 表示モード
    private enum DisplayMode: Int {
        case wkWebView = 0
        case safariViewController = 1
    }
    
    private var currentDisplayMode: DisplayMode = .wkWebView
    private var safariVCInstance: SFSafariViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // UIの初期設定
    private func setupUI() {
        // セグメントコントロールの設定
        segmentedControl = UISegmentedControl(items: ["WKWebView", "Safari View"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = currentDisplayMode.rawValue
        segmentedControl.addTarget(self, action: #selector(displayModeChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        // WebViewの設定
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.preferences.javaScriptEnabled = true
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
        
        // ボタンの設定
        redirectButton = UIButton(type: .system)
        redirectButton.translatesAutoresizingMaskIntoConstraints = false
        redirectButton.setTitle("カスタムURLスキームをコール", for: .normal)
        redirectButton.addTarget(self, action: #selector(redirectButtonTapped), for: .touchUpInside)
        view.addSubview(redirectButton)
        
        // ステータスラベルの設定
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.text = "ステータス: 準備完了"
        view.addSubview(statusLabel)
        
        // 制約の設定
        NSLayoutConstraint.activate([
            // セグメントコントロールの制約
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // WebViewの制約
            webView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: redirectButton.topAnchor, constant: -20),
            
            // ボタンの制約
            redirectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            redirectButton.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -20),
            
            // ステータスラベルの制約
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        // WebViewにコンテンツを表示
        updateDisplay()
    }
    
    // 表示モードが変更された時の処理
    @objc private func displayModeChanged() {
        currentDisplayMode = DisplayMode(rawValue: segmentedControl.selectedSegmentIndex) ?? .wkWebView
        updateDisplay()
    }
    
    // 現在のモードに基づいて表示を更新
    private func updateDisplay() {
        switch currentDisplayMode {
        case .wkWebView:
            webView.isHidden = false
            loadInitialHTML()
        case .safariViewController:
            webView.isHidden = true
            presentSafariViewController()
        }
    }
    
    // SafariViewControllerの表示
    private func presentSafariViewController() {
        // ローカルホストのURLを使用
        let urlStr = "http://localhost:3000/redirect.html"
        if let url = URL(string: urlStr) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            present(safariVC, animated: true, completion: nil)
        } else {
            // フォールバックとして指定の他のURLを開く
            if let url = URL(string: initialURL) {
                let safariVC = SFSafariViewController(url: url)
                safariVC.delegate = self
                present(safariVC, animated: true, completion: nil)
            }
        }
    }
    
    // 初期ページの読み込み (WKWebView用)
    private func loadInitialHTML() {
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>カスタムURLスキームサンプル</title>
            <style>
                body { font-family: -apple-system, sans-serif; margin: 20px; text-align: center; }
                button { background-color: #007AFF; color: white; border: none; padding: 10px 20px; 
                         border-radius: 8px; font-size: 16px; margin-top: 20px; cursor: pointer; }
                button:hover { background-color: #0056b3; }
                .container { display: flex; flex-direction: column; align-items: center; 
                              justify-content: center; height: 80vh; }
                #result { margin-top: 20px; padding: 10px; color: #333; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>カスタムURLスキームサンプル</h1>
                <p>以下のボタンを押すと、JavaScriptからカスタムURLスキームが呼び出されます</p>
                <button onclick="openCustomURL()">カスタムURLスキームを開く</button>
                <div id="result"></div>
            </div>
            
            <script>
                function openCustomURL() {
                    document.getElementById('result').innerText = 'カスタムURLスキームを開こうとしています...';
                    
                    // カスタムURLスキームを呼び出す
                    setTimeout(function() {
                        try {
                            // カスタムURLスキームとパラメーターを指定
                            window.location.href = 'urlsample://action?param1=value1&param2=value2';
                            
                            // iOSではアプリが開くとこのページから離れるため、このメッセージは表示されないかもしれません
                            setTimeout(function() {
                                document.getElementById('result').innerText = 'アプリが開かれなかったか、またはページに戻ってきました';
                            }, 2000);
                        } catch (e) {
                            document.getElementById('result').innerText = 'エラー: ' + e.message;
                        }
                    }, 500);
                }
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    // ボタンがタップされた時の処理
    @objc func redirectButtonTapped() {
        if currentDisplayMode == .wkWebView {
            // WKWebViewモードの場合はJavaScriptを実行
            let jsCode = "openCustomURL();"
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if let error = error {
                    print("JavaScript実行エラー: \(error.localizedDescription)")
                }
            }
        } else {
            // SafariViewControllerモードの場合はURLスキームを直接呼び出す
            if let url = URL(string: "urlsample://action?param1=value1&param2=value2&source=button") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // カスタムURLを処理するメソッド
    func handleCustomURL(url: URL) {
        // SafariViewControllerが表示されている場合は閉じる
        if currentDisplayMode == .safariViewController {
            dismiss(animated: true) { [weak self] in
                self?.segmentedControl.selectedSegmentIndex = DisplayMode.wkWebView.rawValue
                self?.currentDisplayMode = .wkWebView
                self?.updateDisplay()
                // 遅延させてURL処理
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.processCustomURL(url: url)
                }
            }
        } else {
            // WKWebView表示中の場合はそのままURLを処理
            processCustomURL(url: url)
        }
    }
    
    // 実際のカスタムURL処理ロジック
    private func processCustomURL(url: URL) {
        // URLの説明を表示
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
    
        // WKNavigationDelegateのメソッド
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            // カスタムURLスキームの処理
            if url.scheme == "urlsample" {
                handleCustomURL(url: url)
                decisionHandler(.cancel) // WebViewでのナビゲーションはキャンセル
                return
            }
        }
        decisionHandler(.allow) // その他のナビゲーションは許可
    }
}

// MARK: - SFSafariViewControllerDelegate
extension ViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // Safari ViewControllerが閉じられた時の処理
        segmentedControl.selectedSegmentIndex = DisplayMode.wkWebView.rawValue
        currentDisplayMode = .wkWebView
        safariVCInstance = nil
        updateDisplay()
    }
    
    // SafariViewControllerが開かれたときの処理
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        safariVCInstance = controller
        // ローディングが完了したことをステータスに表示
        statusLabel.text = "ステータス: SafariVC 読み込み完了"
    }
}

