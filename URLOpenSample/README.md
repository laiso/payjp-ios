## SafariViewControllerモードのテスト

1. ローカルサーバーを起動: `python3 -m http.server 3000`
2. アプリ内で「Safari View」を選択
3. 3秒後に自動的にURLスキームが呼び出されることを確認
4. SafariViewに戻り、「setTimeout版」/「setTimeoutなし版」ボタンをタップ
5. パラメーターが正しく表示されることを確認

## HTMLファイルの動作を編集するには

1. `redirect.html`を編集する

## 実機テスト方法

1. PCのIPアドレスを確認: `ifconfig en0`
2. ViewController.swiftの実機用URLを編集: `let urlStr = "http://あなたのIPアドレス:3000/redirect.html"`
3. PCでサーバー起動: `python3 -m http.server 3000`
4. 実機でアプリを実行