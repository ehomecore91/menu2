#!/bin/bash

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/har1st/Debian7/master/sources.list.debian7"
wget "http://x-mvst.cf/ld/Debian7/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i venet0
service vnstat restart

# install screenfetch
cd 

#touch screenfetch-dev
cd
wget "https://raw.githubusercontent.com/KittyKatt/screenFetch/master/screenfetch-dev" 
mv screenfetch-dev /usr/bin
cd /usr/bin
mv screenfetch-dev screenfetch
chmod +x /usr/bin/screenfetch
chmod 755 screenfetch
cd
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile
#wget "https://github.com/KittyKatt/screenFetch/archive/master.zip" 
#apt-get install -y unzip
#unzip master.zip
#mv screenFetch-master/screenfetch-dev /usr/bin
#cd /usr/bin
#mv screenfetch-dev screenfetch
#chmod +x /usr/bin/screenfetch
#chmod 755 screenfetch
#cd
#echo "clear" >> .bash_profile
#echo "screenfetch" >> .bash_profile
#wget -O screenfetch-dev "https://raw.githubusercontent.com/rizal180499/Auto-Installer-VPS/master/conf/screenfetch-dev"
#mv screenfetch-dev /usr/bin/screenfetch
#chmod +x /usr/bin/screenfetch
#echo "clear" >> .profile
#echo "screenfetch" >> .profile

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "http://x-mvst.cf/ld/Debian7/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Haris Eka Putra</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "http://x-mvst.cf/ld/Debian7/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install openvpn
wget -O /etc/openvpn/openvpn.tar "http://x-mvst.cf/ld/Debian7/openvpn-debian.tar"
cd /etc/openvpn/
tar xf openvpn.tar
wget -O /etc/openvpn/1194.conf "http://x-mvst.cf/ld/Debian7/1194.conf"
service openvpn restart
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
wget -O /etc/iptables.up.rules "http://x-mvst.cf/ld/Debian7/iptables"
sed -i '$ i\iptables-restore < /etc/iptables' /etc/rc.local
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
service openvpn restart

# configure openvpn client config
cd /etc/openvpn/
wget -O /etc/openvpn/1194-client.ovpn "http://x-mvst.cf/ld/Debian7/1194-client.conf"
sed -i $MYIP2 /etc/openvpn/1194-client.ovpn;
PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
useradd -M -s /bin/false har1st
echo "har1st:$PASS" | chpasswd
echo "har1st" > pass.txt
echo "$PASS" >> pass.txt
tar cf client.tar 1194-client.ovpn pass.txt
cp client.tar /home/vps/public_html/
cd
# install badvpn
wget -O /usr/bin/badvpn-udpgw "http://x-mvst.cf/ld/Debian7/badvpn-udpgw"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
wget -O /etc/snmp/snmpd.conf "http://x-mvst.cf/ld/Debian7/snmpd.conf"
wget -O /root/mrtg-mem.sh "http://x-mvst.cf/ld/Debian7/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl "http://x-mvst.cf/ld/Debian7/mrtg.conf" >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443 -p 110 -p 109 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
service ssh restart
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# install squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://raw.githubusercontent.com/har1st/Debian7/master/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.670_all.deb"
dpkg --install webmin_1.670_all.deb;
apt-get -y -f install;
rm /root/webmin_1.670_all.deb
service webmin restart
service vnstat restart

# download
cd /usr/bin
wget -O menu "https://raw.githubusercontent.com/har1st/Debian7/master/menu.sh"
wget -O banner-edit "https://raw.githubusercontent.com/har1st/Debian7/master/banner-edit.sh"
wget -O user-new "https://raw.githubusercontent.com/har1st/Debian7/master/user-new.sh"
wget -O create-trial "https://raw.githubusercontent.com/har1st/Debian7/master/user-trial.sh"
wget -O delete-user "https://raw.githubusercontent.com/har1st/Debian7/master/user-del.sh"
wget -O user-login "https://raw.githubusercontent.com/har1st/Debian7/master/user-login.sh"
wget -O user-list "https://raw.githubusercontent.com/har1st/Debian7/master/user-list.sh"
wget -O resvis "https://raw.githubusercontent.com/har1st/Debian7/master/resvis.sh"
wget -O speedtest "http://x-mvst.cf/ld/Debian7/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/har1st/Debian7/master/info.sh"
wget -O mem-info "https://raw.githubusercontent.com/har1st/Debian7/master/mrtg-mem.sh"
wget -O about-team "https://raw.githubusercontent.com/har1st/Debian7/master/about.sh"
wget -O limit-login "https://raw.githubusercontent.com/har1st/Debian7/master/user-limit.sh"
wget -O create-ocs "https://raw.githubusercontent.com/har1st/Debian7/master/create-ocs.sh"
wget -O dropmon "https://raw.githubusercontent.com/har1st/Debian7/master/dropmon.sh"
echo "0 0 * * * root /usr/bin/reboot" > /etc/cron.d/reboot
echo "* * * * * service dropbear restart" > /etc/cron.d/dropbear
chmod +x menu
chmod +x banner-edit
chmod +x user-new
chmod +x create-trial
chmod +x delete-user
chmod +x user-login
chmod +x user-list
chmod +x resvis
chmod +x speedtest
chmod +x info
chmod +x mem-info
chmod +x about-team
chmod +x limit-login
chmod +x create-ocs
chmkd +x dropmon
cd

# Blockir Torrent
iptables -A OUTPUT -p tcp --dport 6881:6889 -j DROP
iptables -A OUTPUT -p udp --dport 1024:65534 -j DROP
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP

# finalisasi
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo -e "\e[36;1m Autoscript Include: installer by har1st" | tee log-install.txt
echo -e "\e[36;1m ===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "\e[32;1m Service"  | tee -a log-install.txt
echo -e "\e[32;1m -------"  | tee -a log-install.txt
echo -e "\e[37;1m OpenSSH  : 22, 143"  | tee -a log-install.txt
echo -e "\e[32;1m Dropbear : 80, 109, 110, 443"  | tee -a log-install.txt
echo -e "\e[32;1m Squid3   : 8080, 8000, 3128 (limit to IP SSH)"  | tee -a log-install.txt
echo -e "\e[37;1m OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo -e "\e[32;1m badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo -e "\e[37;1m nginx    : 80"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "\e[37;1m Script"  | tee -a log-install.txt
echo -e "\e[37;1m- -----"  | tee -a log-install.txt
echo -e "\e[35;1m menu          (Menampilkan daftar perintah yang tersedia)"  | tee -a log-install.txt
echo -e "\e[35;1m banner-edit   (Mengganti banner login)"  | tee -a log-install.txt
echo -e "\e[35;1m user-new 	(Membuat Akun SSH)"  | tee -a log-install.txt
echo -e "\e[35;1m create-trial  (Membuat Akun Trial)"  | tee -a log-install.txt
echo -e "\e[35;1m delete-user   (Menghapus Akun SSH)"  | tee -a log-install.txt
echo -e "\e[38;1m user-login    (Cek User Login)"  | tee -a log-install.txt
echo -e "\e[38;1m user-list     (Cek Member SSH)"  | tee -a log-install.txt
echo -e "\e[38;1m resvis        (Restart Service dropbear, webmin, squid3, openvpn dan ssh)"  | tee -a log-install.txt
echo -e "\e[34;1m reboot        (Reboot VPS)"  | tee -a log-install.txt
echo -e "\e[34;1m speedtest     (Speedtest VPS)"  | tee -a log-install.txt
echo -e "\e[34;1m info          (Menampilkan Informasi Sistem)"  | tee -a log-install.txt
echo -e "\e[34;1m mem-info      (Menampilkan Informasi memory)" | tee -a log-install.txt
echo -e "\e[34;1m limit-login	(kill multy login)" | tee -a log-install.txt
echo -e "\e[34;1m about-team    (Informasi tentang script auto install)"  | tee -a log-install.txt
echo -e "\e[35;1m Account Default (utk SSH dan VPN)"  | tee -a log-install.txt
echo -e "---------------"  | tee -a log-install.txt
echo -e "\e[35;1m User     : har1st"  | tee -a log-install.txt
echo -e "\e[35;1m Password : $PASS"  | tee -a log-install.txt
echo -e ""  | tee -a log-install.txt
echo -e "\e[35;1m =[Fitur lain]="  | tee -a log-install.txt
echo -e "\e[35;1m =[----------]="  | tee -a log-install.txt
echo -e "\e[36;1m =[Webmin       : http://$MYIP:10000/]="  | tee -a log-install.txt
echo -e "\e[36;1m =[Timezone     : Asia/Jakarta (GMT +7)]="  | tee -a log-install.txt
echo -e "\e[36;1m =[IPv6         : [Off]]="  | tee -a log-install.txt
echo -e "\e[36;1m =[Ddos Flate   : [On]]="  | tee -a log-install.txt
echo -e "\e[36;1m =[Block Torrent: [On]]="  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "\e[37;1m =[Original Script by har1st]="  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "\e[37;1m =[Log Instalasi --> /root/log-install.txt]="  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "\e[33;1m =[VPS AUTO REBOOT TIAP 12 JAM]="  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo -e "=[===========================================]="  | tee -a log-install.txt
echo -e "\e[31;1m =[Silahkan Reboot VPS anda!]="  | tee -a log-install.txt
echo -e "\e[33;1m =[===========================================]="  | tee -a log-install.txt

