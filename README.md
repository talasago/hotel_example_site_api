# このリポジトリの概要
[テスト自動化練習サイト](https://hotel.testplanisphere.dev/ja/index.html)
をイメージして、REST API(内部的API)verとして作成した

# 環境
- Ruby 3.1.2
- Rails 7.0.4
- PostgreSQL
 
# 使い方
1.リポジトリクローン
```bash
git clone git@github.com:talasago/hotel-example-site-restapi.git  
cd [repository_root] 

2.dockerで起動
```bash
docker compose build
docker compose run web rails db:create
docker compose run web rails db:migrate
docker compose run web rails db:seed
docker compose up -d  
```
3.Swaggerがhttp://localhost:8080 にアクセスすることで見れるようになる

4.RSpecを実行する場合
```bash
docker compose run web rails db:create RAILS_ENV=test
docker compose run web rails db:migrate RAILS_ENV=test
docker compose run web rails db:seed RAILS_ENV=test

docker compose exec web bundle exec rspec
````
