# Nativum 公式サイト (サンプル)

[Nativum](https://github.com/hnkNkm/nativum) (Passive Native Web UI System) の公式サイト風サンプルページです。
HTML + `nativum.css` のみで構成され、**実行時 JavaScript はゼロ** です。

## 構成

```text
public/
├── index.html                 # サイト本体 (1ページ)
└── assets/
    ├── css/site.css           # トークン上書き + サイト固有スタイルのみ
    └── img/favicon.svg
flake.nix                      # nativum を flake input として参照し CSS を組み立て
serve.sh                       # ローカル確認用サーバー
.github/workflows/pages.yml    # GitHub Pages デプロイ (Nix build → upload)
```

`nativum.css` はリポジトリにコミットせず、**公式 Release (v0.1.0) を Nix flake input として固定参照**します。ビルド時に `nativum` パッケージの `dist/nativum.css` が `public/` に合成されます。

## 開発

ツールは flake.nix から提供します (Nix + direnv)。

```sh
nix develop              # または direnv の自動読み込み
./serve.sh               # http://localhost:8000 (ビルド成果物を配信)
nix run .#serve -- 9000  # ポート指定
```

## ビルド

```sh
nix build                # result/ にサイト一式 (nativum.css 込み) ができる
```

## nativum.css の更新

Nativum の新バージョンが出たら、flake.nix の input タグを上げて lock を更新するだけです。

```sh
# flake.nix:  nativum.url = "github:hnkNkm/nativum/v0.2.0"; に変更
nix flake update nativum
nix build    # SHA256 は lock が保証
```

## 配信 (GitHub Pages)

`main` ブランチへの push で GitHub Actions が Nix build → Pages へ自動デプロイします。

```sh
git init
git add .
git commit -m "Nativum 公式サイト (サンプル) を追加"
gh repo create nativum-site --public --source=. --push
```

初回のみ GitHub のリポジトリ設定で **Settings → Pages → Source を "GitHub Actions"** に変更してください。

## 動作確認のポイント

- `./serve.sh` → ブラウザで `http://localhost:8000` (ダイアログ / ドロップダウン / アコーディオンを操作)
- CSS を無効化しても全コンテンツが読めること (Nativum の最重要検証)
- `nix flake check` で flake の整合確認
