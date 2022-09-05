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
    
    
RUN  apt-get update && apt-get upgrade -y 
RUN apt-get -y install apt-utils 
RUN apt-get -y install curl default-mysql-client jq nano cron
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash 
RUN apt-get install speedtest 
RUN speedtest --accept-license --accept-gdpr  
RUN echo  "#! /bin/bash"                                        > /usr/local/bin/updtPkg      \              
    && echo  "apt-get update && apt-get upgrade -y"                >> /usr/local/bin/updtPkg     \
    && echo  "curl -s -o /usr/local/bin/speedtestScript https://raw.githubusercontent.com/Goodlinux/debitMonitor/master/speedtestScript" >> /usr/local/bin/updtPkg 
RUN echo  "#! /bin/bash"                                > /usr/local/bin/entrypoint.sh \
    && echo  "echo mise à jour du script de test"       >> /usr/local/bin/entrypoint.sh \
    && echo  "curl -s -o /usr/local/bin/speedtestScript https://raw.githubusercontent.com/Goodlinux/debitMonitor/master/speedtestScript"  >> /usr/local/bin/entrypoint.sh \
    && echo  "chmod +x /usr/local/bin/speedtestScript"        >> /usr/local/bin/entrypoint.sh \
    && echo  "echo Parametrage de Cron"         >> /usr/local/bin/entrypoint.sh \
    && echo  "echo '*/'\$CRON_MINUT_DELAY'      *       *       *       *       /usr/local/bin/speedtestScript' > /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
    && echo  "echo '00         '\$CRON_HOUR_START'     *       *       '\$CRON_DAY_START'     /usr/local/bin/updtPkg' >> /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
    && echo  "echo Lancement de Cron"           >> /usr/local/bin/entrypoint.sh \
    && echo  "crond -f&"                        >> /usr/local/bin/entrypoint.sh  \
    && echo  "exec /bin/bash"                     >> /usr/local/bin/entrypoint.sh  \
    && chmod a+x /usr/local/bin/*

CMD /usr/local/bin/entrypoint.sh 
