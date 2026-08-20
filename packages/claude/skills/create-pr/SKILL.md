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

## 4. push 前に履歴を確認する

**public リポジトリでは push が取り消せない公開行為になる。** ブランチ全体の履歴を、そのリポジトリと無関係な情報が入っていないか確認する。

途中のコミットで追加して後のコミットで削除したファイルは、**削除しても履歴には残る**。ワーキングツリーを見るだけでは足りない。

```bash
gh repo view --json isPrivate -q .isPrivate      # public なら特に念入りに
git ls-remote --heads origin <branch>            # 空なら未 push（今なら作り直せる）
git log -p <default-branch>..HEAD | grep -icE '<他プロジェクト固有の語>'
```

混入していて未 push なら、`git reset --soft <混入コミットの親>` で作り直してから push する。既に push 済みなら、その事実と影響範囲をユーザーに報告して判断を仰ぐ。

## 5. 送信後に必ず照合する

`gh pr create` の終了コードだけを完了判定にしない。ヒアドキュメントを含む複合コマンドは、リダイレクトが失敗しても後続が走る。

目視で確認しない。機械的に照合する。

```bash
B=.git/pr_body_<branch-name>.md
gh pr view <番号> --json body -q .body > "$B.remote"

# コマンド置換が末尾改行を落とすため、GitHub 側が付与する末尾空行を無視して比較できる
if [ "$(cat "$B.remote")" = "$(cat "$B")" ]; then
  echo "✔ 一致"
else
  echo "✘ 差異あり"
  diff "$B.remote" "$B"
fi
```

**既知の差分：** GitHub は body の末尾に空行を 1 つ付与する。素の `diff` は必ず末尾 1 行の差分（`Nd(N-1) < `）を報告するので、これを実際の不一致と誤認しない。上の `$(cat ...)` による比較はこの差分を吸収する。

意図しない差異があれば `gh pr edit <番号> --body-file "$B"` で直し、もう一度照合する。

送信された本文に、そのリポジトリと無関係な情報が混入していないかも確認する。public リポジトリなら特に念入りに。

```bash
grep -icE '<他プロジェクト固有の語>' "$B.remote"
```

照合まで終わってから「PR を作成しました」と報告する。照合していない状態で完了扱いにしない。

## 6. 後片付け

```bash
rm -f .git/pr_body_<branch-name>.md .git/pr_body_<branch-name>.md.remote
```

マージ後にブランチを消すときは `-D` ではなく `-d` を使い、マージ済みであることを確認してから消す。
