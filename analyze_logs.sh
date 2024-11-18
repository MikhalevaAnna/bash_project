#!/bin/bash

filename="access.log";
report="report.txt";
mydir=$(pwd)
fullnamepath=$mydir"/"$filename;
fullreportpath=$mydir"/"$report;

if [ ! -e $filename ]; then
    cat > $filename <<EOL
192.168.1.1 - - [28/Jul/2024:12:34:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.2 - - [28/Jul/2024:12:35:56 +0000] "POST /login HTTP/1.1" 200 567
192.168.1.3 - - [28/Jul/2024:12:36:56 +0000] "GET /home HTTP/1.1" 404 890
192.168.1.1 - - [28/Jul/2024:12:37:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.4 - - [28/Jul/2024:12:38:56 +0000] "GET /about HTTP/1.1" 200 432
192.168.1.2 - - [28/Jul/2024:12:39:56 +0000] "GET /index.html HTTP/1.1" 200 1234
EOL
fi

if [ ! -e $report ]; then
    touch $report;
fi


printf "Отчет о логе веб-сервера\n" > $report;
printf "========================\n" >> $report;

awk 'BEGIN{cnt=0} $1~/^192\./{cnt++} END{print "Общее количество запросов: ", cnt}' $fullnamepath >> $fullreportpath
awk '$1~/^192\./{cnt[$1]++} END{for(i in cnt) {unq++;} print "Количество уникальных IP адресов: ", unq}' $fullnamepath >> $fullreportpath

printf "\n\nКоличество запросов по методам:\n" >> $report;

awk 'BEGIN{cnt=0} $6~/GET/{cnt++} END{print "    ",cnt," GET"}' $fullnamepath >> $fullreportpath
awk 'BEGIN{cnt=0} $6~/POST/{cnt++} END{print "    ",cnt," POST\n\n"}' $fullnamepath >> $fullreportpath
awk '$1~/^192\./{cnt[$7]++} END{for(i in cnt)  print "Самый популярный URL: ", cnt[i], i}' $fullnamepath | sort -nr | head -n 1 >> $fullreportpath

printf "Отчет сохранен в файл $report\n";
