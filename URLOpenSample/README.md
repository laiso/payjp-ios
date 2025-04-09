1. ローカルサーバーを起動: `docker compose up -d`
2. アプリ内で「SFSafariViewControllerを表示」を選択
3. web_src/step1.html の内容が表示される。
    されない場合、presentSafariViewControllerのurlStrに指定しているIPアドレスを自身の環境にあわせて修正してください
4. ボタンをタップするとweb_src/redirect.htmlまでリダイレクトが進み `urlsample://action` が開かれるが、URIスキームが起動しないことが確認できるはず

