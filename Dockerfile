FROM alpine:latest
MAINTAINER Ludovic MAILLET <Ludo.Goodlinux@gmail.com>


#localtime zone
# Id of the sensor in domoticz corresponding to Upload
# Id of the sensor in domoticz corresponding to Download
# Id of the sensor in domoticz corresponding to Ping
# Adress of your Domoticz server
# Port of the Domoticz server
# Domoticz username
# Domoticz password
# Delay in minutes for the CronJob

ENV TZ=Europe/Paris \
    NUM_SENSOR_UP=1 \ 
    NUM_SENSOR_DOWN=2 \ 
    NUM_SENSOR_PING=3 \ 
    DOMOTICZ_SERV=http://192.168.10.150 \ 
    DOMOTICZ_PORT=8080 \ 
    DOMOTICZ_USER=username \ 
    DOMOTICZ_PASS=password \ 
    CRON_HOUR_START=22  \
    CRON_DAY_START=sun   \
    CRON_MINUT_DELAY=15 

RUN  apk -U add py3-pip python3 curl apk-cron tzdata \ 
     && pip install pip speedtest-cli --upgrade  \
     && cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >  /etc/timezone  \ 
     && echo  "speedtest --simple > /tmp/speedcomplet"   > /usr/local/bin/speedtestScript  \ 
     && echo  "date +'%Y-%m-%d %H:%M' > /dev/stdout" >> /usr/local/bin/speedtestScript  \ 
     && echo  "cut -d' ' -f 2  /tmp/speedcomplet > /tmp/speedresult"   >> /usr/local/bin/speedtestScript  \ 
     && echo  "PING="'$'"(sed -n '1 p' /tmp/speedresult)"   >> /usr/local/bin/speedtestScript  \ 
     && echo  "DOWN="'$'"(sed -n '2 p' /tmp/speedresult)"   >> /usr/local/bin/speedtestScript  \ 
     && echo  "UP="'$'"(sed -n '3 p' /tmp/speedresult)"     >> /usr/local/bin/speedtestScript  \ 
     && echo  "echo PING : "'$PING'       > /dev/stdout     >> /usr/local/bin/speedtestScript  \ 
     && echo  "echo Download : "'$DOWN'   > /dev/stdout     >> /usr/local/bin/speedtestScript  \ 
     && echo  "echo Upload : "'$UP'       > /dev/stdout     >> /usr/local/bin/speedtestScript  \ 
     && echo  "curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_PING'"&nvalue=0&svalue="'$PING''"  > /dev/stdout'   >> /usr/local/bin/speedtestScript  \ 
     && echo  "curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_DOWN'"&nvalue=0&svalue="'$DOWN''"  > /dev/stdout'   >> /usr/local/bin/speedtestScript  \ 
     && echo  "curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_UP'"&nvalue=0&svalue="'$UP''"  > /dev/stdout'   >> /usr/local/bin/speedtestScript  \ 
     && echo  "apk -U upgrade" > /usr/local/bin/updtPkg  \
     && echo "#! /bin/sh" > /usr/local/bin/entrypoint.sh \
     && echo "echo '*/'\$CRON_MINUT_DELAY'*       *       *       *       /usr/local/bin/speedtestScript' > /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
     && echo "echo '00         '\$CRON_HOUR_START'     *       *       '\$CRON_DAY_START'     /usr/local/bin/updtPkg' >> /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
     && echo "SETTINGS=/root/domain-settings"   >> /usr/local/bin/entrypoint.sh  \
     && echo "resolvconf -u" >> /usr/local/bin/entrypoint.sh  \
     && echo "if [ -e  $SETTINGS ]  " >> /usr/local/bin/entrypoint.sh  \ 
     && echo "then"   >> /usr/local/bin/entrypoint.sh  \ 
     && echo "        crond -f&"  >> /usr/local/bin/entrypoint.sh  \  
     && echo "else "   >> /usr/local/bin/entrypoint.sh  \ 
     && echo "        echo Le fichier $SETTINGS n'existe pas Domaine : $DOMAIN"  >> /usr/local/bin/entrypoint.sh  \ 
     && echo "        domain-connect-dyndns setup --domain $DOMAIN --config $SETTINGS "  >> /usr/local/bin/entrypoint.sh  \
     && echo "        crond -f&" >> /usr/local/entrypoint.sh  \ 
     && echo "fi "   >> /usr/local/bin/entrypoint.sh  \
     && echo "exec /bin/sh" >> /usr/local/bin/entrypoint.sh  \
     && chmod a+x /usr/local/bin/*

# Lancement du daemon cron 
#CMD crond -f
CMD /usr/local/bin/entrypoint.sh 
#ENTRYPOINT ["cron", "-f"]
