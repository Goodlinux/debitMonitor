FROM alpine:latest
MAINTAINER Ludovic MAILLET <Ludo.Goodlinux@gmail.com>

ENV TZ=Europe/Paris        \
	SQL_SERV=192.168.0.10  \
	SQL_PORT=3307          \
	SQL_USER=debit         \
	SQL_PASS=gS7/6P_9IE    \
	SQL_BASE=debit 		\
	LOG_SRV=192.168.0.10	\
	CRON_HOUR_START=22     \
	CRON_DAY_START=sun     \
	BOX_IP=192.168.0.1     \
	BOX_USER=admin         \
	BOX_PWD=passwords      \
	CRON_MINUT_DELAY=60 

RUN apk update && apk add curl mysql-client jq nano apk-cron logger
RUN echo  "#! /bin/bash"                                        > /usr/local/bin/updtPkg      \              
	&& echo  "apk -U upgrade"                	>> /usr/local/bin/updtPkg     \
	&& echo  "curl -s -o /usr/local/bin/speedTestFromBox https://raw.githubusercontent.com/Goodlinux/debitMonitor/master/speedTestFromBox" >> /usr/local/bin/updtPkg   \
	&& echo  "chmod a+x /usr/local/bin/*" 		 >> /usr/local/bin/updtPkg 
RUN echo  "#! /bin/sh"                                > /usr/local/bin/entrypoint.sh \
	&& echo  "echo script speed test update"       >> /usr/local/bin/entrypoint.sh \
	&& echo  "/usr/local/bin/updtPkg"  >> /usr/local/bin/entrypoint.sh \
	&& echo  "chmod +x /usr/local/bin/speedTestFromBox"        >> /usr/local/bin/entrypoint.sh \
	&& echo  "echo change cron parameter with env variable"         >> /usr/local/bin/entrypoint.sh \
	&& echo  "echo '*/'\$CRON_MINUT_DELAY'      *       *       *       *       /usr/local/bin/speedTestFromBox ' > /etc/crontabs/root" >> /usr/local/bin/entrypoint.sh  \
	&& echo  "echo launching cron"              >> /usr/local/bin/entrypoint.sh \
	&& echo  "crond -b "                        >> /usr/local/bin/entrypoint.sh  \
	&& echo "/bin/sh "                          >> /usr/local/bin/entrypoint.sh  \
	&& chmod a+x /usr/local/bin/*
	
CMD /usr/local/bin/entrypoint.sh 
