#!/bin/bash
echo "Introdueix Nom + El Primer Cognom:"
read nom
echo "Introdueix el teu compte de correu: "
read var1
echo "Introdueix la contraseña del teu compte de correu: "
read -s var2

clear

#Colors
RED='\033[31m'
GREEN='\033[32m'
BLUE='\033[34m'
NONE='\033[00m'

#Creem fitxer examen
touch /var/log/examen.txt

#Dades
#NAME=$(getent passwd {1000..6000} | cut -d ':' -f1)
IP=$(ip a | grep "inet" | grep "scope global" |  cut -d" " -f6)
GATE=$(ip r | grep "default via" | cut -d" " -f3)
DNS=$(cat /etc/resolv.conf | cut -d" " -f2)
RAM=$(vmstat -s -S M | grep "total memory" | cut -c 1-16)
HDD=$(df -h -t ext4 | sort -k 2 | head -1)
echo "+---------------------------------------------+"
echo -e "NOM ALUMNE:${GREEN} ${nom}${NONE}"
echo -e "NOM ALUMNE:${nom}" > /var/log/examen.txt
echo -e "Dades xarxa (HOST / Gateway / DNS):${GREEN} ${IP} / ${GATE} / ${DNS}${NONE}"
echo -e "Dades xarxa (HOST / Gateway / DNS): ${IP} / ${GATE} / ${DNS}" >> /var/log/examen.txt
echo -e "Característiques (RAM / HDD):${GREEN} ${RAM} / ${HDD} ${NONE}"
echo -e "Característiques (RAM / HDD):${RAM} / ${HDD}" >> /var/log/examen.txt
echo "+---------------------------------------------+"
echo "+---------------------------------------------+" >> /var/log/examen.txt
punts=0

#Comprovem si som root
if [ "$EUID" -ne 0 ]
then echo -e "${RED}Executa aquest script com a root${NONE}"
exit
fi


#Comprovem la versió
VERSIO=$(lsb_release -d | grep "Description" | cut -d ' ' -f2-4)
echo -e "[*]  La versió de Linux és:     ${GREEN} $VERSIO ${NONE}"
echo -e "[*]  La versió de Linux és: $VERSIO" >> /var/log/examen.txt
DATA_IN=$(head -1 /var/log/installer/syslog | cut -c 1-12)
echo -e "[*]  Inici de la insta.lació:   ${GREEN} $DATA_IN ${NONE}";
echo -e "[*]  Inici de la insta.lació: $DATA_IN" >> /var/log/examen.txt
DATA_FI=$(tail -1 /var/log/installer/syslog | cut -c 1-12)
echo -e "[*]  Final de la insta.lació:   ${GREEN} $DATA_FI ${NONE}";
echo -e "[*]  Final de la insta.lació: $DATA_FI " >> /var/log/examen.txt
echo
echo "+---------------------------------------------+"
echo "+---------------------------------------------+" >> /var/log/examen.txt
#Comprovem apache2
if [ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed") -eq 0 ] >>/var/log/examen.txt;
	then
	echo -e "[*]  Apache2 no està instal.lat                             ${RED}Incorrecte!!${NONE}"
	echo -e "[*]  Apache2 no està instal.lat:  Correcte!! 0 punts${NONE}" >> /var/log/examen.txt
	else
#	punts=$((punts + 1));
	echo -e "[*]  Apache2 està instal.lat                                ${GREEN}Correcte!!${NONE}" 
	echo -e "[*]  Apache2 està instal.lat:   Correcte!" >> /var/log/examen.txt
fi

#Comprovem Mariadb-Server
if [ $(dpkg-query -W -f='${Status}' mariadb-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
	echo -e "[*]  Mariadb-Server no està instal.lat                      ${RED}Incorrecte!!${NONE}"
	echo -e "[*]  Mariadb-Server no està instal.lat   Incorrecte!! 0 punts" >> /var/log/examen.txt
	else
#	punts=$((punts + 1));
	echo -e "[*]  Mariadb-Server està instal.lat                         ${GREEN}Correcte!!${NONE}"
	echo -e "[*]  Mariadb-Server està instal.lat:    Correcte!" >> /var/log/examen.txt
fi

#Comprovem php
if [ $(dpkg-query -W -f='${Status}' php 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
	echo -e "[*]  PHP no està instal.lat                                 ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  PHP no està instal.lat: Incorrecte!! 0 punts" >> /var/log/examen.txt
	else
#	punts=$((punts + 3));
	echo -e "[*]  PHP està instal.lat                                    ${GREEN}Correcte!${NONE}"
	echo -e "[*]  PHP està instal.lat: Correcte!" >> /var/log/examen.txt
fi

#Comprovem php-mysql
if [ $(dpkg-query -W -f='${Status}' php-mysql 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
	echo -e "[*]  El paquet PHP-MYSQL no està instal.lat                 ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  El paquet PHP-MYSQL no està instal.lat:   Incorrecte!! 0 punts" >> /var/log/examen.txt
	else
	punts=$((punts + 5));
	echo -e "[*]  Si la xarxa NAT és correcte i,                         ${GREEN}OK ${NONE}
	echo -e "[*]  El paquet PHP-MYSQL està instal.lat                    ${GREEN}Correcte! $punts${NONE}"
	echo -e "[*]  El paquet PHP-MYSQL està instal.lat: Correcte! $punts" >> /var/log/examen.txt
fi

#Comprovem base de dades
DBNAME="glpi"
if [ -d "/var/lib/mysql/$DBNAME" ]; then
	punts=$((punts + 1));
	echo -e "[*]  La base de dades $DBNAME existeix.                   ${GREEN}Correcte! $punts"
	echo -e "[*]  La base de dades $DBNAME existeix:  Correcte! $punts" >> /var/log/examen.txt
else
	echo -e "[*]  La base de dades $DBNAME no existeix.                ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  La base de dades $DBNAME no existeix:  Incorrecte!! 0 punts" >> /var/log/examen.txt
fi

#Comprovem descompressió fitxer
WGET="/opt/"

if [ ! "$(ls $WGET)" ]; then
	echo -e "[*]  No has fet la descarrega.                              ${RED}Incorrecte!!${NONE}"
	echo -e "[*]  No has fet la descarrega:  Incorrecte!!" >> /var/log/examen.txt
echo "+-----------------------------------------------------------------------------+"
echo "+-----------------------------------------------------------------------------+"
echo -e "${GREEN}La nota de l'examen és: $punts${NONE}"
echo -e "La nota de l'examen és:   $punts" >> /var/log/examen.txt
echo "+-----------------------------------------------------------------------------+"
echo "+-----------------------------------------------------------------------------+"
	exit
	else
	punts=$((punts + 1));
	echo -e "[*]  Has fet la descarrega.                                 ${GREEN}Correcte! $punts${NONE}"
	echo -e "[*]  Has fet la descarrega:  Correcte! $punts" >> /var/log/examen.txt
fi

#Comprovem moure software decarregat al host
HOST_DIR="/var/www/html/"
HOST_FILE="/var/www/html/index.html"

if [ ! -d "$HOST_DIR" ];
	then echo -e "[*]  El directori host no existeix.                    ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  El directori host no existeix:  Incorrecte!! 0 punts" >> /var/log/examen.txt
	else
	if [  "$(ls $HOST_DIR)" ];
	then echo -e "El directori té algun fitxer -- index.html i és?"
	echo -e "El directori té algun fitxer -- index.html i és?" >> /var/log/examen.txt
		if [ ! -f "$HOST_FILE" ]
#		punts=$((punts + 1));
		then echo -e "[*]  Fitxer index.html borrat.                              ${GREEN}Correcte! $punts${NONE}"
		echo -e "[*]  Fitxer index.html borrat:  Correcte! $punts" >> /var/log/examen.txt
		else echo -e "[*]  No has esborrat el fitxer index.html!!                 ${RED}Incorrecte!! 0 punts${NONE}"
		echo -e "[*]  No has esborrat el fitxer index.html!! Incorrecte!! 0 punts" >> /var/log/examen.txt
		fi
	else
	echo -e "[*]  El directori host està buit.                               ${RED}Incorrecte!! 0 punts${NONE}" 
	echo -e "[*]  El directori host està buit: Incorrecte!! 0 punts" >> /var/log/examen.txt
fi
fi

#Comprovem els permisos
#HOST_DIR="/var/www/html/"

if [ -d "$HOST_DIR" ] && [ $(stat -c "%a" $HOST_DIR) == "755" ]; then
	punts=$((punts + 1));
	echo -e "[*]  El directori host té permisos correctes.               ${GREEN}Correcte! $punts${NONE}"
	echo -e "[*]  El directori host té permisos correctes:   Correcte! $punts" >> /var/log/examen.txt
	else
	echo -e "[*]  El directori host no té permisos 755.                  ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  El directori host no té permisos 755:  Incorrecte!! 0 punts" >> /var/log/examen.txt
fi


#Comprovem si s'ha creat el directori moodledata
#HOST_DIR_MDATA="/var/www/moodledata"

#if [ ! -d "$HOST_DIR_MDATA" ]
#	then echo -e "[*]  El directori moodledata no existeix.                   ${RED}Incorrecte!! 0 punts${NONE}"
#	echo -e "[*]  El directori moodledata no existeix:  Incorrecte!! 0 punts" >> /var/log/examen.txt
#	else echo -e "[*]  El directori moodledata existeix.                      ${GREEN}Nota EXAMEN: $punts${NONE}"
#	echo -e "[*]  El directori moodledata existeix:     Nota EXAMEN: $punts" >> /var/log/examen.txt
#fi

#Comprovem propietaris
if [ -d "$HOST_DIR" ] && [ $(stat -c "%U" $HOST_DIR) == "www-data" ]; then
#	punts=$((punts + 1));
	echo -e "[*]  El directori host té usuari correcte.                  ${GREEN}Correcte! $punts${NONE}"
	echo -e "[*]  El directori host té usuari correcte:  Correcte! $punts"  >> /var/log/examen.txt
else
	echo -e "[*]  El directori host té usuari incorrecte.                ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  El directori host té usuari incorrecte:  Incorrecte!! 0 punts" >> /var/log/examen.txt
fi
if [ -d "$HOST_DIR" ] && [ $(stat -c "%G" $HOST_DIR) == "www-data" ]; then
	punts=$((punts + 1));
	echo -e "[*]  El directori host té grup correcte                     ${GREEN}Correcte!! $punts${NONE}"
	echo -e "[*]  El directori host té grup correcte:  Correcte!! $punts" >> /var/log/examen.txt
else
	echo -e "[*]  El directori host no té grup correcte                  ${RED}Incorrecte!! 0 punts${NONE}"
	echo -e "[*]  El directori host no té grup correcte:  Incorrecte!! 0 punts" >> /var/log/examen.txt
fi
echo "+---------------------------------------------------------------------+"
echo "+---------------------------------------------------------------------+"
echo -e "${GREEN}La nota de l'examen és: $punts${NONE}"
echo -e "La nota de l'examen és: $punts" >> /var/log/examen.txt
echo "+---------------------------------------------------------------------+"
echo "+---------------------------------------------------------------------+"

apt-get -y update >/dev/null
apt-get install -y sendemail >/dev/null
apt-get install -y libnet-ssleay-perl >/dev/null
apt-get install -y libio-socket-ssl-perl >/dev/null

sendemail -f $var1 -t p2022inf3@jaumebalmes.net -u "1DAW" -m "Examen UF2" -a /var/log/examen.txt -s smtp.gmail.com:587 -o tls=yes -v -xu $var1 -xp $var2 >/dev/null
echo

