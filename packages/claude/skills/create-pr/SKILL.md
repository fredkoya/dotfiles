---
name: create-pr
description: Pull Request を作成・編集する手順。body を一時ファイル経由で渡すときの事故を防ぎ、送信後に本文を照合する。ユーザーが「PR 作って」「PR 出して」「pull request を作成」「PR の説明を直して」と依頼したとき、または gh pr create / gh pr edit を使うときに必ず使う。
user-invocable: true
---

# PR 作成手順

`gh pr create` / `gh pr edit` を実行する前に、この手順を上から順に守る。

## 1. 前提の確認

- ベースブランチは各 repo のデフォルトブランチ（`gh repo view --json defaultBranchRef` で確認）。`develop` を採用している repo もあるので推測しない
- 作業ブランチがデフォルトブランチから切られているか `git log --oneline` で確認する
- テンプレートの見出し構成を先に読む。パスは repo によって違う（`.github/PULL_REQUEST_TEMPLATE.md` / `.github/pull_request_template.md`）

```bash
ls .github/ | grep -i pull_request
```

## 2. body ファイルの作り方

**禁止：`/tmp` の固定名に書く。** 2026-08-04 に dotfiles repo の PR #15 で、別プロジェクトの内部情報がそのまま public な PR 説明として公開された。public repo の PR body は編集履歴が誰でも参照でき、取り消せない。

事故の経路：

1. ユーザーの zsh は `noclobber` が有効
2. `cat > /tmp/pr_body.md` が `(eval):1: file exists` で拒否された
3. 以前のプロジェクトで作った同名ファイルが残っていて、その中身が送信された
4. `gh pr create` 自体は成功したのでエラーに気づかなかった

守ること：

- **Write ツールで書く**（リダイレクトを使わない。`noclobber` の影響を受けない）
- パスは repo 内の git 追跡外＋PR ごとに一意な名前にする。例：`.git/pr_body_<branch-name>.md`
- どうしてもシェルのリダイレクトを使う場合は `>|` で上書きを明示する
- 作業後に削除する

## 3. 本文の書き方

- **日本語**で書く。テンプレートの見出し構成に従う
- AI／エージェントの関与を示す記述を含めない。`Co-Authored-By: Claude` 等の trailer も付けない
- 検証で判明した具体的な数値（修正前後の実際の出力など）を含める
- 未対応の懸念事項は「注意事項」に明記する
- 複数 repo にまたがる変更では、関連 PR の番号を相互リンクし、リリース順序を書く。片方だけ先に反映しても既存表示が壊れないことを明示する

## 4. 送信後に必ず照合する

`gh pr create` の終了コードだけを完了判定にしない。ヒアドキュメントを含む複合コマンドは、リダイレクトが失敗しても後続が走る。

```bash
gh pr view <番号> --json body -q .body
```

出力が意図した内容と一致することを目で確認する。差異があれば `gh pr edit <番号> --body-file <ファイル>` で直し、もう一度照合する。

照合まで終わってから「PR を作成しました」と報告する。照合していない状態で完了扱いにしない。

## 5. 後片付け

```bash
rm -f .git/pr_body_<branch-name>.md
```

マージ後にブランチを消すときは `-D` ではなく `-d` を使い、マージ済みであることを確認してから消す。
