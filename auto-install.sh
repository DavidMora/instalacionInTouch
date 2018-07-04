#!/bin/sh

mkdir /home/pi/auto-logs/

sudo apt-get update
sudo apt-get install vim -y
touch /home/pi/auto-logs/update-done
# Expand Filesystem
sudo raspi-config --expand-rootfs
# REBOOT

echo "dev:insite1234" | sudo chpasswd
# sudo su -c "useradd dev -s /bin/bash -m -G sudo dev"
# sudo chpasswd << 'END'
# dev:insite1234
# END
echo "pi:insite1234" | sudo chpasswd
touch /home/pi/auto-logs/users-done

# raspi-config AUTO LOGIN Boot Options -> Desktop/CLI -> Console AutoLogin
sudo systemctl set-default graphical.target
sudo ln -fs /etc/systemd/system/autologin@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
sudo sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=pi/"
sudo disable_raspi_config_at_boot
touch /home/pi/auto-logs/autologin-done

# raspi-config Interfacing Options -> SSH -> YES
sudo update-rc.d ssh enable && sudo invoke-rc.d ssh start
touch /home/pi/auto-logs/ssh-done
# BOOT CONFIG
sudo cp /boot/cmdline.txt /boot/cmdline.old.txt
sudo echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty3 root=PARTUUID=7ebe8cf8-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash loglevel=0 logo.nologo vt.global_cursor_default=0 plymouth.ignore-serial-consoles">/boot/cmdline.txt
touch /home/pi/auto-logs/boot-done
# Quitar mensajes de kernel
sudo cp /home/pi/install/etc/rc.local /etc/rc.local

sudo mv /etc/motd /etc/motd.old
sudo touch /etc/motd
sudo update-rc.d motd remove
touch /home/pi/.hushlogin
touch /home/pi/auto-logs/kernel-done

# Quitar logs del auto login
sudo cp /home/pi/install/etc/systemd/system/autologin@.service /etc/systemd/system/autologin@.service
touch /home/pi/auto-logs/autologin-logs-done

# Poner logo de inmote al inicio
sudo apt-get install plymouth plymouth-themes pix-plym-splash -y

sudo cp /usr/share/plymouth/themes/pix/splash.png /usr/share/plymouth/themes/pix/splash.old.png
sudo cp /home/pi/install/splas/180x180.png /usr/share/plymouth/themes/pix/splash.png
touch /home/pi/auto-logs/init-logo-done

# Borrar texto del splash screen
sudo cp /home/pi/install/usr/share/plymouth/themes/pix/pix.script /usr/share/plymouth/themes/pix/pix.script
touch /home/pi/auto-logs/splash-text-done

# Configuración de /boot/
sudo mv /boot/config.txt /boot/config.old.txt
sudo cp /home/pi/install/boot/config.txt /boot/config.txt
touch /home/pi/auto-logs/boot2-done

# Configurar interfaz de red
sudo apt-get install ifplugd
sudo cp /home/pi/install/etc/ifplugd/action.d/ifupdown /etc/ifplugd/action.d/ifupdown
touch /home/pi/auto-logs/ifplugd-done

# Configurar archivo de interfaces
sudo cp /home/pi/install/etc/network/interfaces /etc/network/interfaces
touch /home/pi/auto-logs/interfaces-done

# Instalar servidor X
sudo apt-get --no-install-recommends install xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable -y
sudo apt-get install libgtk2.0-0 libgtk-3-0 libxrender1 libxtst6 libxi6 libxss-dev libgconf-2-4 libasound2 libnss3-dev libpangocairo-1.0-0 -y
sudo apt-get install -y mesa-utils libgl1-mesa-glx
touch /home/pi/auto-logs/xserver-done

# Instalar Node
wget https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-armv6l.tar.gz 
tar -xvf node-v8.11.3-linux-armv6l.tar.gz 
sudo cp -R node-v8.11.3-linux-armv6l/* /usr/local/
sudo npm i -g npm
touch /home/pi/auto-logs/node-done

# Instalar Electron
sudo npm install -g electron@2.0.3 --unsafe-perm=true --allow-root
touch /home/pi/auto-logs/electron-done
# Instalar software de dependencias de INUPDATER
# Instalar pip
sudo apt-get install python-pip -y
pip install requests

mkdir -p /home/pi/software/certificates
mkdir -p /home/pi/software/files
mkdir -p /home/pi/software/inmote
mkdir -p /home/pi/software/firmwares
mkdir -p /home/pi/software/certificates/
touch /home/pi/auto-logs/pip-done
# Instalar biblioteca criptográfica mbedtls

wget https://github.com/DavidMora/mbedtls-arch-dependant-releases/releases/download/V1.0.0/release.tar
tar -xvf release.tar
mkdir -p /home/pi/software/mbedtls/programs/aes
mkdir -p /home/pi/software/mbedtls/programs/pkey
mv aescrypt2 /home/pi/software/mbedtls/programs/aes
mv pk_sign /home/pi/software/mbedtls/programs/pkey
touch /home/pi/auto-logs/mbedtls-done

# Descargar inUpdater 
# -
# -
# -

# Declarar variables de entorno en inupdater
echo "export UPDATER_OTA_INMOTE=/home/pi/software/inmote">>/home/pi/.bashrc
echo "export UPDATER_OTA_INAUTH_URL=https://inmote.api.insite.com.co:4500">>/home/pi/.bashrc
echo "export UPDATER_OTA_CERTIFICATE_PATH=/home/pi/software/certificates">>/home/pi/.bashrc
echo "export UPDATER_OTA_MBED_PATH=/home/pi/software/mbedtls">>/home/pi/.bashrc
echo "export UPDATER_OTA_FILES=/home/pi/software/updater-files">>/home/pi/.bashrc
echo "export UPDATER_OTA_FIRMWARES=/home/pi/software/firmwares">>/home/pi/.bashrc
echo "export UPDATER_OTA_UPDATE_FILE=/home/pi/software/updates.txt">>/home/pi/.bashrc
echo "export UPDATER_OTA_CRON_UPDATE_FILE=/home/pi/software/runUpdate">>/home/pi/.bashrc
echo "export UPDATER_OTA_CRON_AUTH_FILE=/home/pi/software/runAuth">>/home/pi/.bashrc

mkdir -p /home/pi/software/updater-files
mkdir -p /home/pi/software/firmwares
touch /home/pi/software/updates.txt
touch /home/pi/auto-logs/environment-done
# Crear cron Job para updater
cp /home/pi/install/home/pi/software/runAuth /home/pi/software/runAuth
cp /home/pi/install/home/pi/software/runUpdate /home/pi/software/runUpdate
mkdir -p /home/pi/software/in-updater2

crontab -l > updatecron
echo "0 3 * * * sh /home/pi/software/runAuth" >> updatecron
echo "5 3 * * * sh /home/pi/software/runUpdate" >> updatecron

touch /home/pi/auto-logs/cron1-done
# Declarar archivo raspberry para inmote
sudo echo "yesiam">/home/imraspberry
sudo chown pi:pi /home/imraspberry
sudo chmod 766 /home/imraspberry
touch /home/pi/auto-logs/raspi-file-done

# Crear .xinitrc
cp /home/pi/install/home/pi/.xinitrc /home/pi/.xinitrc
# cp /home/pi/install/home/pi/.bashrc /home/pi/.bashrc
touch /home/pi/auto-logs/file-xinit-done
# Añadir usuario pi a grupo sudo
sudo usermod -g sudo pi

# Dar permisos al archivo de configuración de red
sudo chmod 666 /etc/wpa_supplicant/wpa_supplicant.conf
sudo chmod 757 /etc/wpa_supplicant/
touch /home/pi/auto-logs/wpa-done
# Validar errores de electron
touch /home/pi/lastCheckAlive.log
cp /home/pi/install/check_alive.py /home/pi/check_alive.py
echo "*/3 * * * * python /home/pi/check_alive.py" >> updatecron
touch /home/pi/auto-logs/cron2-done