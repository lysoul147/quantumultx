#!/usr/bin/env bash
  
#作者：Antiscientist GitHub@lysoul147
#不带参数运行时，自动清理jd.sh系列进程，如bash AutoCleanJD.sh
#带参数运行时，清理包含参数关键字的进程，如bash AutoCleanJD.sh "baidu_speed.sh"可以清理baidu_speed.sh相关的进程
#默认清理运行时长超过1小时的进程，可自行设置TimeCleanMin变量

TimeCleanMin=60 #清理运行时间超过超过此时间的进程，单位分钟，默认60分钟

Target=$1
FileName=$(echo $(basename $0 | cut -d . -f1))

if [[ ! ${Target} ]]; then
        Target=jd.sh
fi

TargetPIDList=$(ps -eo pid,etimes,cmd | grep ${Target} | grep -v -E "grep|pm2|jd_crazy_joy_coin|${FileName}") #获取进程PID及运行时间,过滤掉grep、pm2、和本文件相关进程

function KillProcess(){
        IFS=$'\n'
        for process in $1; do
        TargetTime=$(echo ${process} | awk '{print $2}')
        TargetCMD=$(echo ${process} | awk '{print $3,$4,$5,$6,$7}')
        min=$((${TargetTime}/60))
        scd=$((${TargetTime}%60))
        if [[ "${TargetTime}" -gt "$((${TimeCleanMin}*60))" ]]; then
                kill -15 $(echo ${process} | awk '{print $1}')
                echo -e "进程【${TargetCMD}】\n运行时间：${min}分${scd}秒，已清理❌ "
            else
                [[ $(echo ${process} | grep -v "\-c") ]] && echo -e "进程【${TargetCMD}】\n运行时间：${min}分${scd}秒，无需清理✅ " #显示不用清理的进程时过滤掉带"-c"选项的命令
        fi
        done
}

echo -e "\n====🔔 开始自动清理【${Target}】进程===="
echo -e "开始时间：$(date +'%Y-%m-%d %H:%M:%S')\n" 

if [[ ${TargetPIDList} ]]; then
        KillProcess "${TargetPIDList}"
else
        echo -e "没有【${Target}】相关的进程"
fi

echo -e "\n====🔔 清理完毕====\n"
