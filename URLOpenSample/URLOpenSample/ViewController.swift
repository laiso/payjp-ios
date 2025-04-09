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
    private var statusLabel: UILabel!
    
    private var safariVCInstance: SFSafariViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // UIの初期設定
    private func setupUI() {
        // ボタンの設定
        redirectButton = UIButton(type: .system)
        redirectButton.translatesAutoresizingMaskIntoConstraints = false
        redirectButton.setTitle("SFSafariViewControllerを表示", for: .normal)
        redirectButton.addTarget(self, action: #selector(presentSafariViewController), for: .touchUpInside)
        view.addSubview(redirectButton)
        
        // ステータスラベルの設定
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.text = "ステータス: 準備完了"
        view.addSubview(statusLabel)
        
        // 制約の設定
        NSLayoutConstraint.activate([
            
            // ボタンの制約
            redirectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            redirectButton.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -20),
            // ステータスラベルの制約
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
    }
    
    // SafariViewControllerの表示
    @objc func presentSafariViewController() {
        // ローカルホストのURLを使用
        let urlStr = "http://192.168.1.25:3000/step1.html"
        print("test ---------------- presentSafariViewController -- urlStr\(urlStr)")
        let url = URL(string: urlStr)!
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.dismissButtonStyle = .close
        safariVC.modalPresentationStyle = .overFullScreen
        print("test ---------------- presentSafariViewController -- present")
        present(safariVC, animated: true, completion: nil)
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

