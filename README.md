# INFO 
[![speedtest](https://img.shields.io/static/v1?label=based_on&message=speedtest-cli&color=blue)](link=https://github.com/sivel/speedtest-cli,float="left")

 It allows you to measure the internet speed in Upload / Download as well as the ping and send it to a Domoticz server.

# INSTALL 
[![docker](https://img.shields.io/static/v1?label=docker&message=debitmonitor&color=green)](link=https://hub.docker.com/r/goodlinux/debitmonitor,float="left")
 
 On the Domoticz server, create 1 virtual counter then 3 virtual sensors 
 note the identifiers of the virtual sensors 
 and pass them as a parameter in the Dockerfile 
 
# DNS 
 be sure you have a txt dns _domainconnect TXT field under your domain name with value depending on your DNS provider 
 for inons the value of the TXT field is : "api.domainconnect.1and1.com"
 
# ENV VARIABLES 
 NUM_SENSOR_UP = 1      Id of the sensor in domoticz corresponding to Upload   
 NUM_SENSOR_DOWN = 2    Id of the sensor in domoticz corresponding to Download   
 NUM_SENSOR_PING = 3    Id of the sensor in domoticz corresponding to Ping   
 DOMOTICZ_SERV = http://192.168.10.150    Address of your Domoticz server   
 DOMOTICZ_PORT = 8080    Port of the Domoticz server   
 DOMOTICZ_USER = username    Domoticz username   
 DOMOTICZ_PASS = password    Domoticz password   
 CRON_HOUR_START = 22        Hour to start the Job for Updates  
 CRON_DAY_START = sun        Day to start the job for updates values "mon tue ... sat sun"     
 CRON_MINUT_DELAY = 15       Delay in minutes for the CronJob to check the internet debit  
