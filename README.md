# dotfiles

macOS 用の個人設定ファイル群。[mise](https://mise.jdx.dev/) の `[dotfiles]` 機能でシンボリックリンクを張り、ツールのインストールも mise で管理する。

## セットアップ

```
git clone https://github.com/fredkoya/dotfiles.git
cd dotfiles
make install
```

`make install` は Homebrew / prezto / mise を用意したうえで `mise bootstrap` を実行し、`mise.toml` の定義に従ってツールのインストールとシンボリックリンクの作成まで行う。

2 回目以降の適用は `make mise` を使う。mise 自体の最小バージョンを満たしているか確認してから `mise bootstrap` を実行する。

## 構成

| パス | 配置先 |
| --- | --- |
| `packages/claude/` | `~/.claude/` |
| `packages/git/` | `~/.config/git/` |
| `packages/mise/config.toml` | `~/.config/mise/config.toml` |
| `packages/vscode/` | `~/Library/Application Support/Code/User/` |
| `packages/zsh/` | `~/` |

対応関係の正確な定義は `mise.toml` の `[dotfiles]` セクションを参照。

## マシン固有の設定

リポジトリで管理しないファイル。各マシンで個別に用意する。

- `~/.config/git/config.local` — `user.name` / `user.email` / `credential.helper`
- `~/.zshrc.local` — `.zshrc` から読み込まれる（prezto 読み込みより前）
- `~/.config/git/allowed_signers` — コミット署名の検証に使う公開鍵

## コミット署名

`packages/git/config` で SSH 署名を有効にしているため、署名鍵がないマシンではコミットが失敗する。新しいマシンでは以下を実施する。

```
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_signing
gh ssh-key add ~/.ssh/id_ed25519_signing.pub --type signing --title "git signing"
printf '%s %s\n' "$(git config user.email)" "$(cut -d' ' -f1,2 ~/.ssh/id_ed25519_signing.pub)" > ~/.config/git/allowed_signers
```

GitHub 側の Key type は `Signing key` を指定する。`Authentication key` では Verified にならない。

## ライセンス

[MIT](LICENSE)
