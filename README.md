# このリポジトリの概要
[テスト自動化の学習用の練習サイト](https://hotel.testplanisphere.dev/ja/index.html)をイメージして、ローカル(Docker上)でWebAPI(システムの内部向けAPI)を叩ける環境を作成した。  

# WebAPIの仕様
- [コチラ](# 使い方)を参考にAPIの仕様はSwaggerを確認ください。

## テスト自動化の学習用の練習サイトとは異なる仕様
- ユーザーのアイコンの変更(画像のアップロード)が不可である点

# 環境
- Ruby 3.1.2
- Rails 7.0.4
- PostgreSQL
- devise(認証)
- DeviseTokenAuth(認証)
- pundit(認可)
 
# 使い方
1.リポジトリクローン
```bash
# TODO:URL書く
cd [repository_root] 
```

2.dockerで起動
```bash
docker compose build
docker compose run web rails db:create
docker compose run web rails db:migrate
docker compose run web rails db:seed
docker compose up -d  
```
3.http://localhost:8080 にアクセスするとSwaggerが見れる

4.RSpecを実行する場合
```bash
docker compose run web rails db:migrate RAILS_ENV=test
docker compose run web rails db:seed RAILS_ENV=test

docker compose exec web bundle exec rspec
````
