FROM debian:stable-slim
MAINTAINER Ludovic MAILLET <Ludo.Goodlinux@gmail.com>


ENV TZ=Europe/Paris        \
    NUM_SENSOR_UP=1        \ 
    NUM_SENSOR_DOWN=2      \ 
    NUM_SENSOR_PING=3      \ 
    DOMOTICZ_SERV=http://192.168.10.150 \ 
    DOMOTICZ_PORT=8080     \ 
    DOMOTICZ_USER=username \ 
    DOMOTICZ_PASS=password \ 
    SQL_SERV=192.168.1.10   \
    SQL_PORT=3307          \
    SQL_USER=debit        \
    SQL_PASS=gS7/6P_9IE    \
    SQL_BASE=debit 	       \
    CRON_HOUR_START=22     \
    CRON_DAY_START=sun     \
    CRON_MINUT_DELAY=15 
    
#&& cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >  /etc/timezone  \
#&& echo  "echo 'nameserver      1.1.1.1' > /etc/resolv.conf"  >> /usr/local/bin/entrypoint.sh \
#&& echo  "echo 'nameserver      1.0.0.1' >> /etc/resolv.conf"    >> /usr/local/bin/entrypoint.sh \
#&& echo  "echo 'nameserver      8.8.8.8' >> /etc/resolv.conf"    >> /usr/local/bin/entrypoint.sh \ 
    
    
RUN  apt update && apt upgrade -y && apt install curl mysql-client jq tzdata nano \ 
    && curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash \
    && sudo apt install speedtest \
    && speedtest --accept-gdpr   \ 
    && echo  "speedtest -f json > /tmp/speedcomplet"                    > /usr/local/bin/speedtestScript  \ 
    && echo  "DATE="'$'"(date +'%Y-%m-%d %H:%M')"                       >> /usr/local/bin/speedtestScript  \
    && echo  "echo \$DATE > /dev/stdout "                               >> /usr/local/bin/speedtestScript  \
    && echo  "downraw=$(jq -r '.download.bandwidth' /tmp/speedcomplet)"  >> /usr/local/bin/speedtestScript  \
    && echo  "DOWN=$(printf %.2f\\n "$((downraw * 8))e-6")"              >> /usr/local/bin/speedtestScript  \
    && echo  "upraw=$(jq -r '.upload.bandwidth' /tmp/speedcomplet)"      >> /usr/local/bin/speedtestScript  \
    && echo  "UP=$(printf %.2f\\n "$((upraw * 8))e-6")"                  >> /usr/local/bin/speedtestScript  \
    && echo  "PING=$(jq -r '.ping.latency' /tmp/speedcomplet)"           >> /usr/local/bin/speedtestScript  \
    && echo  "echo PING : "'$PING'       > /dev/stdout                  >> /usr/local/bin/speedtestScript  \ 
    && echo  "echo Download : "'$DOWN'   > /dev/stdout                  >> /usr/local/bin/speedtestScript  \ 
    && echo  "echo Upload : "'$UP'       > /dev/stdout                  >> /usr/local/bin/speedtestScript  \     
    && echo  "if [ -n \"\$DOMOTICZ_SERV\" ]; then  "                    >> /usr/local/bin/speedtestScript  \     
    && echo  "      curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_PING'"&nvalue=0&svalue="'$PING''"  > /dev/stdout'   >> /usr/local/bin/speedtestScript  \ 
    && echo  "      curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_DOWN'"&nvalue=0&svalue="'$DOWN''"  > /dev/stdout'   >> /usr/local/bin/speedtestScript  \ 
    && echo  "      curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_UP'"&nvalue=0&svalue="'$UP''"  > /dev/stdout'   >> /usr/local/bin/speedtestScript  \ 
    && echo "fi "                                                       >> /usr/local/bin/speedtestScript  \ 
    && echo "if [ -n \"\$SQL_SERV\" ]; then  "                          >> /usr/local/bin/speedtestScript  \     
    && echo  '      echo "INSERT INTO \`debit\`(\`date\`,\`upload\`, \`download\`, \`ping\`) VALUES ("''\"$DATE\"''",$UP,$DOWN,$PING);"  > /tmp/insert.sql'         >> /usr/local/bin/speedtestScript  \                
    && echo  '      mysql --user=$SQL_USER --host=$SQL_SERV --port=$SQL_PORT --password=$SQL_PASS  $SQL_BASE < /tmp/insert.sql'     >> /usr/local/bin/speedtestScript  \
    && echo "fi "                                                       >> /usr/local/bin/speedtestScript  \ 
    && echo  "apt update && apt upgrade -y"             > /usr/local/bin/updtPkg  \
    && echo  "#! /bin/sh"                       > /usr/local/bin/entrypoint.sh \
    && echo  "echo Parametrage de Cron"         >> /usr/local/bin/entrypoint.sh \
    && echo  "echo '*/'\$CRON_MINUT_DELAY'      *       *       *       *       /usr/local/bin/speedtestScript' > /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
    && echo  "echo '00         '\$CRON_HOUR_START'     *       *       '\$CRON_DAY_START'     /usr/local/bin/updtPkg' >> /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
    && echo  "echo Lancement de Cron"           >> /usr/local/bin/entrypoint.sh \
    && echo  "crond -f&"                        >> /usr/local/bin/entrypoint.sh  \
    && echo  "exec /bin/sh"                     >> /usr/local/bin/entrypoint.sh  \
    && chmod a+x /usr/local/bin/*

CMD /usr/local/bin/entrypoint.sh 
