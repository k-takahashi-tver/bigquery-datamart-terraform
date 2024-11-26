# bigquery-datamart-terraform
このリポジトリは、TerraformとGitHub Actionsを使用してBigQueryのスケジュールクエリとテーブルを管理するサンプルです。  
本プロジェクトはブログ記事 [リンクを挿入] で紹介した内容に基づいています。  

**注意:**  
このリポジトリはあくまで学習や参考用のサンプルとして提供されています。簡単な動作確認は行っていますが、全ての環境での動作を保証するものではありません。本番環境での利用時には十分に検証を行ってください。

# セットアップ手順
1. Google Cloud プロジェクトを作成
1. 必要なAPI (BigQuery, Cloud Storageなど)を有効化
1. `terraform/environments` 配下で各環境の設定を行う

GitHub Actionsを利用する場合は以下の手順も行ってください。  

1. OIDC 用リソースとterraform 実行用サービスアカウントをローカル環境で作成
1. リポジトリの secrets に以下を登録

```
# 以下は DEV 環境のみ、必要に応じて複数環境用意する
WIF_SERVICE_ACCOUNT_EMAIL_DEV: github actionsでterraformを実行するSAのメールアドレス
WIF_PROVIDER_DEV : projects/<project number>/locations/global/workloadIdentityPools/<workload identity pool name>/providers/<workload identity provider name>
```

# 利用方法
1. リソース種別に対応するディレクトリ内にクエリやスキーマを定義します
1. Terraform を適用 
