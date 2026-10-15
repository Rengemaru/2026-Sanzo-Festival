# 大学祭 バイブコーディング体験(弾幕シューティング)スタッフ用手順

来場者がAIに話しかけるだけでシューティングゲームを改造する体験の一式です。
**特定のコーディングエージェントに依存しません。** 各ゲームフォルダに置いたルールファイル
(`AGENTS.md`)を、起動したエージェントが自動で読み込む仕組みで動きます。
OpenCode / Pi / Codex CLI / Claude Code / Gemini CLI / Cursor CLI などで使えます。

## フォルダ構成

```
vibe-coding-festival/
├── README.md        この手順書
├── reset.sh         体験用フォルダを元に戻すスクリプト
├── check-env.sh     本番前の「環境お掃除チェック」(混入源の検出)
├── kids/            幼稚園・小学生向け(スタッフや保護者が代わりに入力する前提)
│   ├── template/    元の状態(ここは直接いじらない)
│   └── work/        体験で実際に改造するフォルダ
└── teens/           中高生向け(本人がタイピングする前提)
    ├── template/
    └── work/
```

kids と teens には、それぞれ3種類のゲームがあります。

| フォルダ | 内容 |
|---|---|
| `1_zako` | ざこ敵だけ |
| `2_boss` | ボスだけ |
| `3_zako_boss` | ざこ敵とボス |

各ゲームのフォルダには、ゲーム本体の `index.html` と、AIへのルールファイルが入っています。

| ファイル | 役割 |
|---|---|
| `index.html` | ゲーム本体(HTML/CSS/JavaScriptがすべてこの中にある)。体験で改造するのはここだけ |
| `AGENTS.md` | AIへのルール。**ルールファイルはこれ1本だけ** |

ほとんどのコーディングエージェント(Claude Code / Codex CLI / OpenCode / Pi / Cursor CLI / Cline)は、
起動したフォルダの `AGENTS.md` を**追加設定なしで自動で読みます**。余計なルールファイルは置きません。

- **Gemini CLI だけは例外**です。既定では `AGENTS.md` を読まないので、どちらか一方で対応してください。
  - `~/.gemini/settings.json` または `.gemini/settings.json` に `"context": { "fileName": ["AGENTS.md"] }` を追加する、または
  - そのゲームフォルダの `AGENTS.md` を `GEMINI.md` という名前でコピー(または別名リンク)する。
- **Aider も例外**です。自動では読まないので、起動時に明示します:`aider --read AGENTS.md index.html`

kids と teens では、ゲームの中身もルールも別物です。kids はゲームオーバーなし・やさしい表現・難しさの上限あり、teens は残機とゲームオーバーあり・本格的な弾幕・難しさは自由です。

## 事前準備(1回だけ)

### 1. 使うコーディングエージェントをインストール & ログイン

どれか1つで構いません。会場PCで使うものを選んでください。

| エージェント | インストール | 起動 | ログイン |
|---|---|---|---|
| **OpenCode** | `curl -fsSL https://opencode.ai/install \| bash` | `opencode` | `opencode auth login` |
| **Pi** | `curl -fsSL https://pi.dev/install.sh \| sh` | `pi` | 起動して `/login` |
| **Codex CLI** | `npm install -g @openai/codex` | `codex` | `codex login`(ChatGPTアカウント) |
| **Claude Code** | `npm install -g @anthropic-ai/claude-code` | `claude` | 起動して `/login` |
| **Gemini CLI** | `npm install -g @google/gemini-cli` | `gemini` | 起動して `/auth` |
| **Cursor CLI** | `curl https://cursor.com/install -fsS \| bash` | `cursor-agent` | `cursor-agent login` |

- OpenCode / Pi / Codex CLI / Claude Code / Cursor CLI は、起動したフォルダの `AGENTS.md` を**追加設定なしで自動で**読みます。
- **Gemini CLI / Aider は例外**です(上の「フォルダ構成」の注を参照)。Gemini は設定1行かファイル名 `GEMINI.md`、Aider は起動時 `--read AGENTS.md` で対応します。
- コスト面:**OpenCode はログイン不要の無料モデルを同梱**。Codex は ChatGPT 有料プラン、Gemini は無料枠が実質廃止(2026年)、Pi は要アカウント。会場の予算・アカウントに合わせて選んでください。

### 2. インストールできたか確認

```bash
<エージェント名> --version      # 例: opencode --version / pi --version / codex --version
```

### 3. ブラウザの自動更新に使う Node.js を入れておく(`npx` が使えれば OK)

```bash
node --version
```

### 4. このフォルダに移動して、スクリプトを使えるようにする

```bash
cd vibe-coding-festival
chmod +x reset.sh check-env.sh
```

### 5. 【重要】環境お掃除チェックを実行する

```bash
./check-env.sh
```

どのエージェントも、起動フォルダの**上の階層**や**ホーム**(`~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md`、
`~/.pi/agent/AGENTS.md` など)にあるルールファイルを一緒に読み込みます。それらが会場PCに残っていると、
kids/teens のルールに混ざり込み、意図しない改造や安全ルール無視の原因になります。
`check-env.sh` が混入源になりそうなファイルを探して警告するので、「きれいです」と出る状態にしてから本番に臨んでください。

## 体験の流れ(1人ごと)

例として、幼稚園・小学生向けの「ざこ敵だけ」を使う場合です。コマンド中の `opencode` は、使うエージェント名(`pi` / `codex` / `claude` / `gemini` / `cursor-agent`)に読み替えてください。

1. 体験用フォルダを元に戻します。
   ```bash
   ./reset.sh kids 1_zako
   ```
2. ターミナルを1つ開き、ゲームをブラウザで表示します。ファイルが保存されるたびに、ブラウザが自動で更新されます。
   ```bash
   cd kids/work/1_zako
   npx live-server
   ```
3. もう1つターミナルを開き、同じフォルダでエージェントを起動します。**必ずゲームのフォルダの中で起動してください**(起動フォルダの `AGENTS.md` を読むため)。
   ```bash
   cd kids/work/1_zako
   opencode          # ← 使うエージェント名に読み替え
   ```
4. 体験者の言葉をエージェントに入力します(teens は本人が入力)。
5. 体験が終わったら、次の人の前に 1. のリセットを実行します。live-server とエージェントは起動したままで構いませんが、**エージェントの会話は新しく始め直してください**(前の人の会話が残ると、AIが前の改造を引きずります)。

すべてのゲームを一度に元に戻すときは、引数なしで実行します。

```bash
./reset.sh
```

## スタッフ用の操作

- **B キー**:「ざこ敵とボス」のゲームで、すぐにボスを呼びます。8分の体験でボスまで届かないときに使ってください。
- **teens のハイスコア**:ブラウザに保存されるので、体験者が交代しても残ります。live-server のポート番号が変わると別扱いになり、リセットされたように見えます。

## 安全を「確実に」止めたいとき(エージェント別の権限設定)

`AGENTS.md` は「お願い」であって「強制」ではありません。AIが指示を無視して、ルール外の変更
(`index.html` 以外のファイル操作、外部との通信など)をする可能性は残ります。これを**確実に**止めたい場合は、
エージェント側の権限設定が別途必要です(この一式にはまだ含まれていません)。エージェントごとの得意・不得意は次のとおりです。

| エージェント | 権限/サンドボックス | 備考 |
|---|---|---|
| **Codex CLI** | ◎ 強力 | `~/.codex/config.toml` で `sandbox_mode = "workspace-write"`(フォルダ外への書き込み禁止・通信OFF) |
| **Cursor CLI** | ◎ 強力 | `--sandbox enabled` で通信OFF+ワークスペース限定。`Shell`/`WebFetch` を deny、`--yolo` は使わない |
| **OpenCode** | ◎ | `opencode.json` の `permission` で `bash`/`webfetch` を `deny`、`edit` を限定 |
| **Claude Code** | ◎ | `.claude/settings.json` の `permissions.deny` + PreToolUse フック + `sandbox.enabled` |
| **Gemini CLI** | △ | `tools.exclude` でシェル/通信ツールを除外。サンドボックスはコンテナ(`--sandbox`)で、既定オフ |
| **Cline** | △ | コマンド許可リスト(`CLINE_COMMAND_PERMISSIONS`)。`--auto-approve` は使わない |
| **Pi / Aider** | ✕ 内蔵なし | 公開端末で確実に縛るなら Docker などコンテナで隔離する |

公開端末としての安全度が最優先なら、**Codex CLI か Cursor CLI**(OS/サンドボックスで「このフォルダだけ・通信なし」を強制できる)が無難です。

## 注意

- **このフォルダを、別のルールファイル(`AGENTS.md` / `CLAUDE.md` / `GEMINI.md` など)があるプロジェクトの中に置かないでください。** どのエージェントも上の階層のルールまで読み込むため、意図しない指示が混ざります。本番前に必ず `./check-env.sh` を実行してください。
- **template フォルダは直接いじらないでください。** 改造してしまうと、リセットしても元に戻らなくなります。
- **ルールファイルは `AGENTS.md` 1本だけです。** 修正するときはこれを直します。Gemini CLI で使う場合も、`GEMINI.md` を別に作らず `AGENTS.md` を設定で読ませる方法を推奨します(余計なファイルを増やさないため)。
- **3つのゲームの本体は共通のプログラムです。** ゲームの動きを直したいときは、3つすべてを同じように直さないと、ゲームごとに動きがずれていきます。
- 本番前に、実際の体験者に近い人に一度遊んでもらい、難しさと分かりやすさ、そして**使うエージェント+モデルが安全ルール(kids の「死を連想させる演出を作らない」等)を守るか**を確認しておくことをおすすめします。安いモデルほどルールを外しやすい傾向があります。
