FROM alpine:latest
MAINTAINER Ludovic MAILLET <Ludoivc@maillet.me>


#localtime zone
ENV TZ=Europe/Paris

# Id of the sensor in domoticz corresponding to Upload
# Id of the sensor in domoticz corresponding to Download
# Id of the sensor in domoticz corresponding to Ping
# Adress of your Domoticz server
# Port of the Domoticz server
# Domoticz username
# Domoticz password
# Delay in minutes for the CronJob

ENV NUM_SENSOR_UP=1 \ 
    NUM_SENSOR_DOWN=2 \ 
    NUM_SENSOR_PING=3 \ 
    DOMOTICZ_SERV=http://192.168.1.30 \ 
    DOMOTICZ_PORT=18084 \ 
    DOMOTICZ_USER=username \ 
    DOMOTICZ_PASS=password \ 
    CRON_MINUT_DELAY=10 

RUN echo 'https://mirrors.ircam.fr/pub/alpine/v3.9/community' >> /etc/apk/repositories && apk -U add speedtest-cli curl apk-cron tzdata \ 
     && cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >  /etc/timezone  \ 
	 && echo  "speedtest --simple > /tmp/speedcomplet"   > /usr/local/bin/speedtestScript  \ 
	 && echo  "date" >> /usr/local/bin/speedtestScript  \ 
	 && echo  "cut -d' ' -f 2  /tmp/speedcomplet > /tmp/speedresult"   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "PING="'$'"(sed -n '1 p' /tmp/speedresult)"   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "DOWN="'$'"(sed -n '2 p' /tmp/speedresult)"   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "UP="'$'"(sed -n '3 p' /tmp/speedresult)"   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "echo PING : "'$PING'       >> /usr/local/bin/speedtestScript  \ 
	 && echo  "echo Download : "'$DOWN'    >> /usr/local/bin/speedtestScript  \ 
	 && echo  "echo Upload : "'$UP'      >> /usr/local/bin/speedtestScript  \ 
	 && echo  "curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_PING'"&nvalue=0&svalue="'$PING''"'   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_DOWN'"&nvalue=0&svalue="'$DOWN''"'   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "curl --user "'$DOMOTICZ_USER'":"'$DOMOTICZ_PASS' '"''$DOMOTICZ_SERV'":"'$DOMOTICZ_PORT'"/json.htm?type=command&param=udevice&idx="'$NUM_SENSOR_UP'"&nvalue=0&svalue="'$UP''"'   >> /usr/local/bin/speedtestScript  \ 
	 && echo  "apk -U upgrade" > /usr/local/bin/updtPkg  \
	 && echo  'ls -la $1'  >  /usr/local/bin/ll
	 && echo "*/$CRON_MINUT_DELAY     *       *       *       *       /usr/local/bin/speedtestScript" >> /etc/crontabs/root  \ 
	 && echo "00     1       *       *       sun       /usr/local/bin/updtPkg" >> /etc/crontabs/root  \ 
	 && chmod a+x /usr/local/bin/*

# Lancement du daemon cron
#CMD crond -f
ENTRYPOINT ["cron", "-f"]
