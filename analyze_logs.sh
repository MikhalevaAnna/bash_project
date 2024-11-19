#!/bin/bash

filename="access.log";
reportname="report.txt";
mydir=$(pwd)
fullfilepath=$mydir"/"$filename;
fullreportpath=$mydir"/"$reportname;

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

if [ ! -e $reportname ]; then
    touch $reportname;
fi


printf "Отчет о логе веб-сервера\n" > $reportname;
printf "========================\n" >> $reportname;

awk 'BEGIN{cnt=0} $1~/^192\./{cnt++} END{print "Общее количество запросов: ", cnt}' $fullfilepath >> $fullreportpath
awk '$1~/^192\./{cnt[$1]++} END{for(i in cnt) {unq++;} print "Количество уникальных IP адресов: ", unq}' $fullfilepath >> $fullreportpath

printf "\n\nКоличество запросов по методам:\n" >> $reportname;

awk 'BEGIN{cnt=0} $6~/GET/{cnt++} END{print "    ",cnt," GET"}' $fullfilepath >> $fullreportpath
awk 'BEGIN{cnt=0} $6~/POST/{cnt++} END{print "    ",cnt," POST\n\n"}' $fullfilepath >> $fullreportpath
awk '$1~/^192\./{cnt[$7]++} END{for(i in cnt)  print "Самый популярный URL: ", cnt[i], i}' $fullfilepath | sort -nr | head -n 1 >> $fullreportpath

printf "Отчет сохранен в файл $reportname\n";
