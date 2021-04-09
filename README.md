# INFO 
The project is based on the speedtest-cli project
Allows you to measure the internet speed in Upload / Download as well as the ping and send it to a Domoticz server.

# INSTALL 
On the Domoticz server, create 1 virtual counter
then 3 virtual sensors
note the identifiers of the virtual sensors
and pass them as a parameter in the Dockerfile

# ENV VARIABLES 

the list of parameters is: 
Id of the sensor in domoticz corresponding to Upload 
Id of the sensor in domoticz corresponding to Download 
Id of the sensor in domoticz corresponding to Ping 
Address of your Domoticz server 
Port of the Domoticz server 
Domoticz username 
Domoticz password 
Delay in minutes for the CronJob 

NUM_SENSOR_UP = 1 
NUM_SENSOR_DOWN = 2 
NUM_SENSOR_PING = 3 
DOMOTICZ_SERV = http: //192.168.10.150 
DOMOTICZ_PORT = 8080 
DOMOTICZ_USER = username 
DOMOTICZ_PASS = password 
CRON_MINUT_DELAY = 15
