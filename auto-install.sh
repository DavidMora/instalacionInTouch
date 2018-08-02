#!/bin/sh

mkdir /home/pi/auto-logs/
touch /home/pi/auto-logs/args

# archivo de error para inauth

# funcion para validar que un comando funcione
# si no funciona escribira el log del comando que falla el cual es el primer argumento
check_command (){
  if [ $? -ne 0 ]; then
    echo "$(date) -- $1\n">>/home/pi/auto-logs/error.log
  fi
}

## DECLARACION DE VARIABLES ##
#d flag es si es un dispositivo de desarrollo
#i flag es si es un dispositivo de desarrollo y IP_DEV sera el argumento i que contiene la ip del incloud de desarrollo
#p flag es el password para el usuario pi
#q flag es el password para el usuario dev

DEV=0;
IP_DEV=0;
PI_PASSWD="insite1234";
DEV_PASSWD="insite1234";
while getopts ":q:i:d:p:" option; do
  case "${option}" in
    i) 
      IP_DEV=${OPTARG}
      echo "IP_DEV:$IP_DEV">>/home/pi/auto-logs/args;;
    d) 
      DEV=1
      echo "dev:$DEV">>/home/pi/auto-logs/args;;
    p) 
      PI_PASSWD=${OPTARG}
      echo "PI_PASSWD:$PI_PASSWD">>/home/pi/auto-logs/args;;
    q) 
      DEV_PASSWD=${OPTARG}
      echo "DEV_PASSWD:$DEV_PASSWD">>/home/pi/auto-logs/args;;
  esac
done

sudo apt-get update
check_command "sudo apt-get update"
sudo apt-get install vim -y
check_command "sudo apt-get install vim -y"

# #COMENTARIOS
# # Expand Filesystem
# sudo raspi-config --expand-rootfs
# check_command "sudo raspi-config --expand-rootfs"
# #COMENTARIOS
# REBOOT

sudo su -c "useradd dev -s /bin/bash -m -G sudo"
check_command "adduser dev"
sudo chpasswd << 'END'
dev:insite1234
END
check_command "passwd:dev"
sudo usermod -a -G sudo dev
check_command "usermod -a -G sudo dev"

echo "pi:$PI_PASSWD" | sudo chpasswd
check_command "pi:password"

# Añadir usuario pi a grupo sudo
sudo usermod -g sudo pi
check_command "usermod -g sudo pi"

# raspi-config AUTO LOGIN Boot Options -> Desktop/CLI -> Console AutoLogin
sudo systemctl set-default graphical.target
check_command "systemctl"
sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
check_command "ln -fs /etc/systemd/system/autologin@.service"
sudo sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=pi/"
check_command "sed /etc/lightdm/lightdm.conf"
# disable_raspi_config_at_boot()
if [ -e /etc/profile.d/raspi-config.sh ]; then
  rm -f /etc/profile.d/raspi-config.sh
  check_command "disable_raspi_config_at_boot 1"
  if [ -e /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf ]; then
    rm /etc/systemd/system/getty@tty1.service.d/raspi-config-override.conf
    check_command "disable_raspi_config_at_boot 2"
  fi
  telinit q
  check_command "disable_raspi_config_at_boot 3"
fi

if [ $DEV -eq 1 ]
then
  # raspi-config Interfacing Options -> SSH -> YES
  sudo update-rc.d ssh enable && sudo invoke-rc.d ssh start
  check_command "enablessh"
fi

# #COMENTARIOS
# BOOT CONFIG
sudo printf " quiet splash loglevel=0 logo.nologo vt.global_cursor_default=0 plymouth.ignore-serial-consoles">>/home/pi/install/cmd.add.txt
check_command "create adition cmdline"
sudo cp /boot/cmdline.txt /boot/cmdline.old.txt
check_command "cp cmdline.txt.old"
sudo cp /boot/cmdline.txt /home/pi/install
check_command "cp cmdline.txt install"
tr -d '\n' < /home/pi/install/cmdline.txt > cmdline.new.txt
check_command "remove new line in cmdline"
cat cmdline.new.txt cmd.add.txt > cmd.txt
check_command "create final cmdline"
sudo cp cmd.txt /boot/cmdline.txt
check_command "copy boot cmdline"

# #COMENTARIOS

# # Quitar mensajes de kernel
sudo cp /home/pi/install/etc/rc.local /etc/rc.local
check_command "cp etc/rc.local"

sudo mv /etc/motd /etc/motd.old
check_command "mv etc/rc.local"
sudo touch /etc/motd
check_command "touch /etc/motd"
sudo update-rc.d motd remove
check_command "update-rc.d motd remove"
touch /home/pi/.hushlogin
check_command "touch /home/pi/.hushlogin"

# Quitar logs del auto login
sudo cp /home/pi/install/etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service
check_command "autologin_logs"

# Poner logo de inmote al inicio
sudo apt-get install plymouth plymouth-themes pix-plym-splash -y
check_command "splash logo 1"

sudo cp /usr/share/plymouth/themes/pix/splash.png /usr/share/plymouth/themes/pix/splash.old.png
check_command "splash logo 2"
sudo cp /home/pi/install/splash/180x180.png /usr/share/plymouth/themes/pix/splash.png
check_command "splash logo 3"

# Borrar texto del splash screen
sudo cp /home/pi/install/usr/share/plymouth/themes/pix/pix.script /usr/share/plymouth/themes/pix/pix.script
check_command "splash remove text"

# Configuración de /boot/
sudo mv /boot/config.txt /boot/config.old.txt
check_command "boot config 1"
sudo cp /home/pi/install/boot/config.txt /boot/config.txt
check_command "boot config 2"

# Configurar interfaz de red
sudo apt-get install ifplugd
check_command "install ifplugd"
sudo cp /home/pi/install/etc/ifplugd/action.d/ifupdown /etc/ifplugd/action.d/ifupdown
check_command "config ifplugd"

# Configurar archivo de interfaces
sudo cp /home/pi/install/etc/network/interfaces /etc/network/interfaces
check_command "cp interfaces"

# # Instalar servidor X
sudo apt-get --no-install-recommends install xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable -y
check_command "install x 1"
sudo apt-get install libgtk2.0-0 libgtk-3-0 libxrender1 libxtst6 libxi6 libxss-dev libgconf-2-4 libasound2 libnss3-dev libpangocairo-1.0-0 -y
check_command "install x 2"
sudo apt-get install -y mesa-utils libgl1-mesa-glx
check_command "install x 3"

# Instalar Node
wget https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-armv6l.tar.gz
check_command "install node 1"
tar -xvf node-v8.11.3-linux-armv6l.tar.gz 
check_command "install node 2"
sudo cp -R node-v8.11.3-linux-armv6l/* /usr/local/
check_command "install node 3"
sudo npm i -g npm
check_command "install npm"

# Instalar Electron
sudo npm install -g electron@2.0.4 --unsafe-perm=true --allow-root
check_command "install electron"

# Instalar software de dependencias de INUPDATER
# Instalar pip
sudo apt-get install python-pip -y
check_command "install pip"
pip install requests
check_command "install pip-request"

mkdir -p /home/pi/software/certificates
mkdir -p /home/pi/software/files
mkdir -p /home/pi/software/inmote
mkdir -p /home/pi/software/firmwares
# Instalar biblioteca criptográfica mbedtls

wget https://github.com/DavidMora/mbedtls-arch-dependant-releases/releases/download/V1.0.0/release.tar
check_command "wget mbedtls V1.0.0"
tar -xvf release.tar
check_command "tar -xvf release.tar"
mkdir -p /home/pi/software/mbedtls/programs/aes
mkdir -p /home/pi/software/mbedtls/programs/pkey
mv aescrypt2 /home/pi/software/mbedtls/programs/aes
check_command "mv aescrypt2"
mv pk_sign /home/pi/software/mbedtls/programs/pkey
check_command "mv pk_sign"

# Descargar inUpdater 
mkdir -p /home/pi/software/in-updater
cp -r /home/pi/install/inupdater/* /home/pi/software/in-updater
check_command "cp in-updater"
cp -r /home/pi/install/certificates/* /home/pi/software/certificates
check_command "cp certificates"



mkdir -p /home/pi/software/updater-files
mkdir -p /home/pi/software/firmwares
touch /home/pi/software/updates.txt
mkdir -p /home/pi/software/in-updater2

# Copiar archivos de ejecucion de actualizacion
cp /home/pi/install/home/pi/software/runAuth /home/pi/software/runAuth
check_command "cp runAuth"
cp /home/pi/install/home/pi/software/runUpdate /home/pi/software/runUpdate
check_command "cp runUpdate"

chmod +x /home/pi/software/runAuth
chmod +x /home/pi/software/runUpdate


# Declarar archivo raspberry para inmote
echo "yesiam">/home/pi/imraspberry
check_command "echo yesiam"

# Crear .xinitrc
cp /home/pi/install/home/pi/.xinitrc /home/pi/.xinitrc
check_command "cp .xinitrc"
cp /home/pi/install/home/pi/.bashrc /home/pi/.bashrc

# Dar permisos al archivo de configuración de red
sudo chmod 666 /etc/wpa_supplicant/wpa_supplicant.conf
check_command "chmod wpa_supplicant.conf"
sudo chmod 757 /etc/wpa_supplicant/
check_command "chmod wpa_supplicant"
# Validar errores de electron
touch /home/pi/lastCheckAlive.log
cp /home/pi/install/home/pi/check_alive.py /home/pi/check_alive.py
check_command "cp check_alive.py"


# Crear cron para autorizar, actualizar y validar electron
touch /home/pi/updatecron

crontab -l > /home/pi/updatecron
check_command "crontab updatecron"
echo "0 3 * * * ./home/pi/software/runAuth" >> /home/pi/updatecron
check_command "crontab runAuth"
echo "5 3 * * * ./home/pi/software/runUpdate" >> /home/pi/updatecron
check_command "crontab runUpdate"
echo "*/3 * * * * python /home/pi/check_alive.py" >> /home/pi/updatecron
check_command "crontab check_alive.py"

crontab /home/pi/updatecron
check_command "create crontab updatecron"