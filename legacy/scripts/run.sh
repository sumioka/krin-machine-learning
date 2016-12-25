#!/usr/bin/env bash

# ファイルやフォルダが自動的に作成されるので、
# 作業ディレクトリを作成して実行する方が良い

# 引数:
#  -f yyyymmdd  取得範囲(from)
#  -t yyyymmdd  取得範囲(to)
#
# 実行例:
# $ run.sh -f 20161201 -t 20161231
#
# 処理内容: 
# (1) KEIRIN.JP より、各月の開催日程をURL取得する -> calendar_list.txt
#  ex.  http://keirin.jp/pc/dfw/dataplaza/guest/racecalendar?NEN=2016&MON=12
#
# (2) calendar_list.txt の web page を calendar フォルダにダウンロードする
#
# (3) KEIRIN.JP より、各レースのレースプログラムのURLを取得する -> program_list.txt
#  ex. http://keirin.jp/pc/dfw/dataplaza/guest/raceprogram?KCD=13&KST=20161210
#
# (4) program_list.txt の web page を program フォルダにダウンロードする
#
# (5) KEIRIN.JP より、各レースの出走表と結果のURLを取得する -> results_list.txt
#  ex. http://keirin.jp/pc/dfw/dataplaza/guest/racemember?KCD=13&KBI=20161210&RNO=1
#  ex. http://keirin.jp/pc/dfw/dataplaza/guest/raceresult?KCD=13&KBI=20161210&RNO=1
#
# (6) results_list.txt の web page を race フォルダにダウンロードする
#
# -c: (1),(2)のみ
# -p: (3),(4)のみ、ただし(2) の結果がないと異常終了
# -r: (5),(6)のみ、ただし(4) の結果がないと異常終了

#BIN_DIR="../bin"
CAL_DIR="calendar"
PROG_DIR="program"
RACE_DIR="race"

D_FROM="19990101"
D_TO="19990131"

FLG_C="TRUE"
FLG_P="TRUE"
FLG_S="TRUE"

CMDNAME=`basename $0`
BIN_DIR=`dirname $0`

while getopts cf:prt: OPT
do
  case $OPT in
    "c" ) FLG_C="TRUE"  ; FLG_P="FALSE" ;FLG_R="FALSE" ;;
    "p" ) FLG_C="FALSE" ; FLG_P="TRUE"  ;FLG_R="FALSE" ;;
    "r" ) FLG_C="FALSE" ; FLG_P="FALSE" ;FLG_R="TRUE" ;;
    "f" ) D_FROM="$OPTARG" ;;
    "t" ) D_TO="$OPTARG" ;;
    * ) echo "Usage: $CMDNAME [-c][-p][-r] [-f yyyymmdd] [-t yyyymmdd]" 1>&2
	echo "    -c get race calendars" 1>&2
	echo "    -p get race programs" 1>&2
	echo "    -r get start lists and results" 1>&2
        exit 1 ;;
  esac
done

# カレンダー取得
if [ ${FLG_C} = "TRUE" ]; then
    if [ ! -d ${CAL_DIR} ]; then
	mkdir ${CAL_DIR}
    fi
    ruby ${BIN_DIR}/nittei.rb -f ${D_FROM} -t ${D_TO} > calendar_list.txt
    cd ${CAL_DIR}
    ../${BIN_DIR}/wget.sh ../calendar_list.txt
    cd ..
fi

# レースプログラム取得
if [ ${FLG_P} = "TRUE" ]; then
    if [ ! -d ${PROG_DIR} ]; then
	mkdir ${PROG_DIR}
    fi

    ruby ${BIN_DIR}/racelist.rb -f ${D_FROM} -t ${D_TO} -d ${CAL_DIR} > program_list.txt
    cd ${PROG_DIR}
    ../${BIN_DIR}/wget.sh ../program_list.txt
    cd  ..
fi

# 出走表取得
if [ ${FLG_R} = "TRUE" ]; then
    if [ ! -d ${RACE_DIR} ]; then
	mkdir ${RACE_DIR}
    fi
    ruby ${BIN_DIR}/get_results.rb -f ${D_FROM} -t ${D_TO} -d ${PROG_DIR} > results_list.txt
    cd ${RACE_DIR}
    ../${BIN_DIR}/wget.sh ../results_list.txt
    cd  ..
fi

