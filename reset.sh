#!/bin/bash
# 体験用フォルダ(work)を、元の状態(template)に戻すスクリプト
#
# 使い方:
#   ./reset.sh                 → すべてのゲームを元に戻す
#   ./reset.sh kids 1_zako     → 指定したゲームだけ元に戻す
#
#   グループ: kids(幼稚園・小学生) / teens(中高生)
#   ゲーム  : 1_zako(ざこ敵だけ) / 2_boss(ボスだけ) / 3_zako_boss(ざこ敵とボス)

set -euo pipefail
cd "$(dirname "$0")"

reset_one() {
  local group="$1" game="$2"
  if [ ! -d "$group/template/$game" ]; then
    echo "見つかりません: $group/template/$game" >&2
    exit 1
  fi
  rm -rf "$group/work/$game"
  mkdir -p "$group/work"
  cp -R "$group/template/$game" "$group/work/$game"
  echo "元に戻しました: $group/work/$game"
}

if [ $# -eq 2 ]; then
  reset_one "$1" "$2"
elif [ $# -eq 0 ]; then
  for group in kids teens; do
    for dir in "$group"/template/*/; do
      reset_one "$group" "$(basename "$dir")"
    done
  done
else
  echo "使い方: ./reset.sh  または  ./reset.sh kids 1_zako" >&2
  exit 1
fi
