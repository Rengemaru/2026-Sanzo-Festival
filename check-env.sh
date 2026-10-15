#!/bin/bash
# 本番前の「環境お掃除チェック」
#
# どのコーディングエージェントも、起動フォルダの「上の階層」や「ホーム」にある
# ルールファイル(AGENTS.md / CLAUDE.md / GEMINI.md など)を一緒に読み込みます。
# それらが会場PCに残っていると、kids/teens のルールに混入し、
# 意図しない改造・安全ルール無視の原因になります。
#
# このスクリプトは「混入源になりそうなファイル」を探して警告するだけです。
# ファイルの削除・変更はしません。表示された物を本番前に自分で片付けてください。
#
# 使い方:  ./check-env.sh

set -uo pipefail
cd "$(dirname "$0")"
KIT_ROOT="$(pwd -P)"

# このキットが正しく持っているべきルールファイル名(ゲームフォルダの中だけにある想定)
RULE_NAMES=(AGENTS.md AGENTS.override.md CLAUDE.md CLAUDE.local.md GEMINI.md .clinerules .cursorrules)

problems=0
note() { printf '  \033[33m⚠ %s\033[0m\n' "$1"; problems=$((problems+1)); }
ok()   { printf '  \033[32m✓ %s\033[0m\n' "$1"; }

echo "================================================================"
echo " 環境お掃除チェック  (混入源になりそうなルールファイルを探します)"
echo " キットの場所: $KIT_ROOT"
echo "================================================================"

# ---------------------------------------------------------------
# 1) キットの「上の階層」(親〜ルート)に迷子のルールファイルがないか
# ---------------------------------------------------------------
echo
echo "[1] キットより上の階層(親フォルダ〜ルート)"
dir="$(dirname "$KIT_ROOT")"
found_parent=0
while :; do
  for name in "${RULE_NAMES[@]}"; do
    if [ -e "$dir/$name" ]; then
      note "$dir/$name  (上位にあるため混入します)"
      found_parent=1
    fi
  done
  [ "$dir" = "/" ] && break
  dir="$(dirname "$dir")"
done
[ "$found_parent" -eq 0 ] && ok "上の階層にルールファイルはありません"

# ---------------------------------------------------------------
# 2) キット内の「ゲームフォルダ以外」に紛れていないか
#    (正しくは kids|teens / template|work / <game> の中だけにある)
# ---------------------------------------------------------------
echo
echo "[2] キット内(ゲームフォルダ以外にルールファイルが紛れていないか)"
found_inside=0
while IFS= read -r f; do
  rel="${f#"$KIT_ROOT"/}"
  depth="$(awk -F/ '{print NF}' <<<"$rel")"
  # 正常な位置は「グループ/種別/ゲーム/ファイル名」= 4階層。それ以外は紛れ込み。
  if [ "$depth" -ne 4 ]; then
    note "$rel  (ゲームフォルダの外にあります)"
    found_inside=1
  fi
done < <(
  for name in "${RULE_NAMES[@]}"; do
    find "$KIT_ROOT" -name "$name" 2>/dev/null
  done
)
[ "$found_inside" -eq 0 ] && ok "ゲームフォルダの中だけに収まっています"

# ---------------------------------------------------------------
# 3) ホーム(~)のグローバル設定に迷子のルールファイルがないか
# ---------------------------------------------------------------
echo
echo "[3] ホームのグローバル設定(全プロジェクトに効くファイル)"
HOME_FILES=(
  "$HOME/.claude/CLAUDE.md:Claude Code"
  "$HOME/.codex/AGENTS.md:Codex CLI"
  "$HOME/.codex/AGENTS.override.md:Codex CLI"
  "$HOME/.config/opencode/AGENTS.md:OpenCode"
  "$HOME/.pi/agent/AGENTS.md:Pi"
  "$HOME/.pi/agent/APPEND_SYSTEM.md:Pi"
  "$HOME/.gemini/GEMINI.md:Gemini CLI"
  "$HOME/.agents/AGENTS.md:Cline"
)
found_home=0
for entry in "${HOME_FILES[@]}"; do
  path="${entry%%:*}"; tool="${entry##*:}"
  if [ -e "$path" ]; then
    note "$path  ($tool のグローバル指示。混入します)"
    found_home=1
  fi
done
[ "$found_home" -eq 0 ] && ok "ホームにグローバルのルールファイルはありません"

# ---------------------------------------------------------------
# 結果
# ---------------------------------------------------------------
echo
echo "================================================================"
if [ "$problems" -eq 0 ]; then
  printf ' \033[32m結果: きれいです。そのまま本番に使えます。\033[0m\n'
  echo "================================================================"
  exit 0
else
  printf ' \033[33m結果: %d 件の混入源が見つかりました。本番前に片付けてください。\033[0m\n' "$problems"
  echo " (このスクリプトは削除しません。表示されたファイルを移動/削除/リネームしてください)"
  echo "================================================================"
  exit 1
fi
