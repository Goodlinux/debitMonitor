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

RUN apt-get update && apt-get upgrade -y 
RUN apt-get -y install curl default-mysql-client jq nano cron
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash 
RUN apt-get install speedtest && speedtest --accept-gdpr --accept-license  
RUN echo  "#! /bin/bash"                                        > /usr/local/bin/updtPkg      \              
    && echo  "apt-get update && apt-get upgrade -y"                >> /usr/local/bin/updtPkg     \
    && echo  "curl -s -o /usr/local/bin/speedtestScript https://raw.githubusercontent.com/Goodlinux/debitMonitor/master/speedtestScript" >> /usr/local/bin/updtPkg 
RUN echo  "#! /bin/bash"                                > /usr/local/bin/entrypoint.sh \
	&& echo  "printenv | grep -v "no_proxy" >> /etc/environment" >> /usr/local/bin/entrypoint.sh \
	&& echo  "echo script speed test update"       >> /usr/local/bin/entrypoint.sh \
    && echo  "curl -s -o /usr/local/bin/speedtestScript https://raw.githubusercontent.com/Goodlinux/debitMonitor/master/speedtestScript"  >> /usr/local/bin/entrypoint.sh \
    && echo  "chmod +x /usr/local/bin/speedtestScript"        >> /usr/local/bin/entrypoint.sh \
    && echo  "echo change cron parameter with env variable"         >> /usr/local/bin/entrypoint.sh \
    && echo  "echo '*/'\$CRON_MINUT_DELAY'      *       *       *       *       /usr/local/bin/speedtestScript ' > /etc/cron.d/speed-crontab" >> /usr/local/bin/entrypoint.sh  \
    && echo  "echo '00         '\$CRON_HOUR_START'     *       *       '\$CRON_DAY_START'     /usr/local/bin/updtPkg' >> /etc/cron.d/speed-crontab" >> /usr/local/bin/entrypoint.sh  \
    && echo  "chmod 0644 /etc/cron.d/speed-crontab"   >> /usr/local/bin/entrypoint.sh \
	&& echo  "crontab /etc/cron.d/speed-crontab"   >> /usr/local/bin/entrypoint.sh \
    && echo  "echo launching cron"                 >> /usr/local/bin/entrypoint.sh \
    && echo  "cron -f"                        >> /usr/local/bin/entrypoint.sh  \
    && chmod a+x /usr/local/bin/*

CMD /usr/local/bin/entrypoint.sh 
