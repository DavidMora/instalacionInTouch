# Instalar Raspbian
### Este producto usa la versión RASPBIAN STRETCH LITE, se recomienda usar `Version:March 2018`
https://www.raspberrypi.org/downloads/raspbian/

## 1. Descargar la imagen
## 2. Quemar la tarjeta SD (MAC)
Luego de tener la imagen descargada se deben seguir los siguientes pasos

Buscar la memoria usando el comando `diskutil list`
```sh
$ diskutil list
```
Desmonrar la imagen
```sh
$ sudo diskutil unmountDisk /dev/<NAME OF DISK>
```

`<NAME OF DISK>` puede ser disk4 por ejemplo.`

Copiar la imagen a la SD
```sh
$ sudo dd bs=1m if=XXXX-XX-XX-raspbian-stretch.img of=/dev/r<NAME OF DISK> conv=sync
```
# USAR SCRIPT AUTOMATICO
Para usar el script automático es necesario haber incluido los archivos `.pyc` del modulo de inupdater en la carpeta `./inpudater` de este proyecto.

El repo de inupdater es https://github.com/DavidMora/linuxOTAComptiblwUpdater

Sin embargo, los pyc pueden ser descargados de la carpeta de firmwares de intelligence usando scp

Para usar el script automático se debe ejecutar el script `create-release.sh` de este directorio, luego se debe crear un servidor apache.

```bash
$ ./create-release.sh
```
Para poder servir el archivo zip es necesario crear una carpeta, para evitar que sea permanente se creará en /tmp/apache

```bash
$ mkdir -p /tmp/apache
$ cp install.tar.gz /tmp/apache
$ docker run --rm --name apache -p=80:80 --volume /tmp/apache/:/usr/local/apache2/htdocs httpd
```

Donde `/tmp/apache` es la carpeta donde se ubicará el tar.gz que se creó previamente.

## 1. Ejecutar el sistema de instalación automático

Debemos conectar el raspberry a la misma red del computador donde tenemos el apache descrito en el punto anterior, acto seguido se deben ejecutar los siguientes comandos.

```bash
$ wget http://IP_COMPUTADOR/install.tar.gz
$ mkdir /home/pi/install
$ tar xvzf install.tar.gz -C /home/pi/install
```

Ahora debemos ejecutar el script de instalación, si queremos instalar el programa para un intouch de producción solamente debemos ejecutar

```bash
$ sh /home/pi/install/auto-install.sh -p password_para_pi -q password_para_dev
$ sh /home/pi/install/auto-install-environment.sh
$ source /home/pi/.bashrc
$ sh /home/pi/install/auto-install-platforms.sh
$ sh /home/pi/install/auto-install-final-install.sh
$ sudo reboot
```

Si el intouch es para desarrollo se debe ejecutar con las siguientes flags

```bash
$ sh /home/pi/install/auto-install.sh -d 1 -p password_para_pi -q password_para_dev
$ sh /home/pi/install/auto-install-environment.sh -d 1 -i IP_INCLOUD_DESARROLLO
$ source /home/pi/.bashrc
$ sh /home/pi/install/auto-install-platforms.sh
```

Si usted sigue estos pasos no es necesario que continue leyendo esta guía pues todo se realizará de manera automática.

# Iniciar sesion
`La contraseña por defecto es pi:raspberry`
## 1. Actualizar Raspberry
```bash
sudo apt-get update
sudo apt-get install vim -y
```
## 2 Expandir sistema de archivos
Ejecutar
```bash
$ sudo raspi-config
```
Luego en la ventana emergente.
- Advanced Options
- Expand Filesystem

ahora debemos reiniciar el raspberry
```bash
$ sudo reboot
```
# Configuración de usuarios
## 1. Crear usuario DEV
```bash
$ sudo adduser dev
```
Poner contraseña definida por insite

Poner a dev en el grupo de `sudo`
```bash
$ sudo usermod -a -G sudo dev
```
## 2. Cambiar contraseña default de pi
```bash
$ passwd pi
```
Luego se debe poner el password actual `raspberry`

Cambiar El password por el definido por INSITE

## 3. Activar autologin
Ejecutar
```bash
$ sudo raspi-config
```
Luego en la ventana emergente.
- Boot Options
- Desktop/CLI
- Console Autologin


# Activar ssh con  SOLO DESARROLLO
Ejecutar
```bash
$ sudo raspi-config
```
Luego en la ventana emergente.
- Seleccionar Interfacing Options
- SSH
- YES

# Configuración de boot 

## 1. Modificar /boot/cmdline.txt
```bash 
$ sudo printf " quiet splash loglevel=0 logo.nologo vt.global_cursor_default=0 plymouth.ignore-serial-consoles">>/home/pi/install/cmd.add.txt
$ sudo cp /boot/cmdline.txt /boot/cmdline.old.txt
$ sudo cp /boot/cmdline.txt /home/pi/install
$ tr -d '\n' < /home/pi/install/cmdline.txt > cmdline.new.txt
$ cat cmdline.new.txt cmd.add.txt > cmd.txt
$ sudo cp cmd.txt /boot/cmdline.txt

```
### El archivo puede encontrarse en `/boot/cmdline.txt` de este repositorio.

## 2. Quitar mensajes de kernel
### El archivo rc.local se puede encontrar en la carpeta `/etc/rc.local` de este repo
```bash 
$ sudo vim /etc/rc.local
```
Poner la siguiente linea antes de 'exit 0':
```bash 
#Suppress Kernel Messages
dmesg --console-off
```
```bash
$ sudo mv /etc/motd /etc/motd.old
$ sudo touch /etc/motd
$ sudo update-rc.d motd remove
$ touch /home/pi/.hushlogin
```

## 3. Quitar logs del auto login

### El archivo autologin\@.service está en `/etc/systemd/system/autologin\@.service` de este repositorio
```bash
sudo vim /etc/systemd/system/autologin\@.service
```
Cambiar la siguiente linea
```bash
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
```
a:
```bash
ExecStart=-/sbin/agetty --skip-login --noclear --noissue --login-options "-f pi" %I $TERM
```

## 4. Poner logo de inmote al inicio
### 4.1 Instalar plymouth
```bash 
$ sudo apt-get install plymouth plymouth-themes pix-plym-splash -y
$ sudo plymouth-set-default-theme pix
```
### 4.2 Copiar imagen de icono
```bash 
$ scp 180x180.png pi@192.168.1.240:/home/pi/
```

```bash 
$ sudo cp /usr/share/plymouth/themes/pix/splash.png /usr/share/plymouth/themes/pix/splash.old.png
$ sudo cp /home/pi/180x180.png /usr/share/plymouth/themes/pix/splash.png
$ rm /home/pi/180x180.png
```

### 4.3 Borrar texto del splash screen

### El archivo pix.script se encuentra en la carpeta `usr/share/plymouth/themes/pix/pix.script` de este repositorio

```bash 
$ sudo vim /usr/share/plymouth/themes/pix/pix.script
```

Comentar las siguientes lineas

```bash
message_sprite = Sprite();
message_sprite.SetPosition(screen_width * 0.1, screen_height * 0.9, 10000);

my_image = Image.Text(text, 1, 1, 1);
message_sprite.SetImage(my_image);
```
El producto del archivo debe ser el siugiente
```bash
# message_sprite = Sprite();
# message_sprite.SetPosition(screen_width * 0.1, screen_height * 0.9, 10000);

# my_image = Image.Text(text, 1, 1, 1);
# message_sprite.SetImage(my_image);
```



## 5. Configuración de /boot/

### Transferir /boot/config.txt a rpi
Transferir por scp el archivo `/boot/config.txt`el cual está ubicado en este repositorio
```bash 
$ scp boot/config.txt pi@192.168.1.158:/home/pi/
```
```bash 
$ sudo mv /boot/config.txt /boot/config.old.txt
$ sudo cp /home/pi/config.txt /boot/config.txt
$ rm /home/pi/config.txt
```
# Apagar luz de la pantalla
Para apagar la luz de la pantalla se debe ejecutar el siguiente comando somo sudo
```bash
echo 1 > /sys/class/backlight/rpi_backlight/bl_power
```

Para apagarla
```bash
echo 0 > /sys/class/backlight/rpi_backlight/bl_power
```

# Configurar interfaz de red
## 1. Instalar ifplugd
```bash
$ sudo apt-get install ifplugd
```
Esta configuración se hace para apagar el wlan si hay un cable de red conectado
```bash 
$ scp etc/ifplugd/action.d/ifupdown pi@192.168.1.158:/home/pi/
```
```bash 
$ sudo cp /home/pi/ifupdown /etc/ifplugd/action.d/ifupdown
```

Ahora debemos ejecutar el proceso de ifplugd en el arranque del dispositivo, para esto debemos añadir las siguientes lineas antes del exit 0 en el archivo `/etc/rc.local`

```bash 
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi
#Suppress Kernel Messages
dmesg --console-off
#Start daemon for ifplugd to connect or disconect wlan0
ifplugd
exit 0
```
## 2. Configurar archivo de interfaces
El archivo de interfaces `/etc/network/interfaces` debe quedar de la siguiente forma 
```bash
auto lo
iface lo inet loopback
allow-hotplug eth0
wpa-conf /etc/wpa-supplicant/wpa-supplicant.conf

auto wlan0
```

### El archivo rc.local se puede encontrar en la carpeta `/etc/rc.local` de este repo

```bash
# Start ifplugd daemon to connect or disconect the wlan0 interface
ifplugd
```

Este archivo debe terminar de la siguiente forma
```bash
# Start ifplugd daemon to connect or disconect the wlan0 interface
ifplugd
exit 0
```
# Instalar servidor X

## 1. instalar servidor x
```bash 
$ sudo apt-get --no-install-recommends install xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable -y

$ sudo apt-get install libgtk2.0-0 libgtk-3-0 libxrender1 libxtst6 libxi6 libxss-dev libgconf-2-4 libasound2 libnss3-dev libpangocairo-1.0-0 -y

$ sudo apt-get install -y mesa-utils libgl1-mesa-glx
```

# Instalar Node

## 1. Instalar node 8.11.3
```bash
$ wget https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-armv6l.tar.gz 
$ tar -xvf node-v8.11.3-linux-armv6l.tar.gz 
$ cd node-v8.11.3-linux-armv6l
$ sudo cp -R * /usr/local/
$ cd ..
$ rm -r node-v8.11.3-linux-armv6l 
$ rm node-v8.11.3-linux-armv6l.tar.gz
$ sudo npm i -g npm
```

## 2. Instalar Electron
La versión 2.0.4 es funcional para rasberry y tiene corregido el problema de que las peticiones ajax bloquean electorn
```bash
$ sudo npm install -g electron@2.0.4 --unsafe-perm=true --allow-root
```
# Instalar software de dependencias de INUPDATER

Se dene revisar el archivo requirements.txt del repositorio `linuxOTAComptiblwUpdater`
## 1. Instalar pip
```bash
$ sudo apt-get install python-pip -y
```
## 2. Instalar librería de request http
```bash
$ pip install requests
```

## 3. Crear carpeta de certificados
```bash
$ mkdir -p /home/pi/software/certificates
```
## 4. Crear carpeta de almacenamiento de arichivos
```bash
$ mkdir -p /home/pi/software/files
```
## 5. Crear carpeta para inmote
```bash
$ mkdir -p /home/pi/software/inmote
```

## 6. Crear carpeta para descargar firmwares
```bash
$ mkdir -p /home/pi/software/firmwares
```


## 7. Instalar los certificados de inUpdater

Crear carpeta para los certificados
```bash
$ mkdir -p /home/pi/software/certificates/
```
Se deben copiar los certificados a la siguiente ruta de el dispositivo
`/home/pi/software/certificates/`
- <NAME_OF_FOLDER>/
  - <NAME_OF_FOLDER>_private_key.pem
  - <NAME_OF_FOLDER>.csr
  - <NAME_OF_FOLDER>.pem

Donde `<NAME_OF_FOLDER>` es el nombre de la carpeta que contiene los certificados
```bash 
$ scp -r <NAME_OF_FOLDER> pi@192.168.1.118:/home/pi/software/certificates/
```
Igualmente se debe crear en `/home/pi/software/certificates/`un archivo `list.lst` el cual contiene la siguiente estructura, `<NAME_OF_FOLDER>`:`<CERTIFICATE_ID>`

un ejemplo es: `intouch_15_3100270:f448fb1ac111111f8af15e70961e47a8`

## 8. Instalar biblioteca criptográfica mbedtls

Se debe descargar el último release del repositorio. Se debe tener presente la rama de la cual se va a descargar el release

https://github.com/DavidMora/mbedtls-arch-dependant-releases


### A continuación se presentarán 2 opciones, si usted quiere compilar la aplicación, siga el primera opción, si cuenta con los binarios, siga el segunda opción

## PRIMERA OPCIÓN
Si por algún motivo no se encutra el código necesitado se puede seguir el siguiente paso
### OPCIONAL **NO** se cuenta con los binarios de los archivos de `mbedtls/pk_sign` y `mbedtls/aescrypt2` **compilados en ARM Raspberry**

Copiar carpeta de desarrollo de mbedtl usada en `in-updater` a raspberry
```bash 
$ scp -r mbedtls pi@192.168.1.118:/home/pi/
```

## Creacion de carpetas para mbedtls
```bash 
$ mkdir -p /home/pi/software/mbedtls/programs/aes
$ mkdir -p /home/pi/software/mbedtls/programs/pkey
$ cd /home/pi/mbedtls/
$ make clean
$ make
$ cd /home/pi
$ cp mbedtls/programs/aes/aescrypt2 /home/pi/software/mbedtls/programs/aes
$ cp mbedtls/programs/pkey/pk_sign /home/pi/software/mbedtls/programs/pkey
$ rm -r mbedtls
```

## SEGUNDA OPCIÓN
### Se cuenta con los binarios de los archivos de `mbedtls/pk_sign` y `mbedtls/aescrypt2` **compilados en ARM Raspberry**
```bash
$ mkdir /home/pi/mbedtls/
$ wget https://github.com/DavidMora/mbedtls-arch-dependant-releases/releases/download/V1.0.0/release.tar
$ tar -xvf release.tar
$ rm release.tar
```
```bash 
$ mkdir -p /home/pi/software/mbedtls/programs/aes
$ mkdir -p /home/pi/software/mbedtls/programs/pkey
$ cp /home/pi/mbedtls/aescrypt2 /home/pi/software/mbedtls/programs/aes
$ cp /home/pi/mbedtls/pk_sign /home/pi/software/mbedtls/programs/pkey
```


## 9. Descargar inUpdater

Para descargar el inupdater se debe descargar el último release de github en el repositorio
`https://github.com/DavidMora/linuxOTAComptiblwUpdater/releases/`
```bash 
$ scp release-X.Y.Z.tar.gz pi@192.168.1.118:/home/pi/
```
```bash
$ tar xvzf release-X.Y.Z.tar.gz
$ mkdir -p /home/pi/software/in-updater
$ cp release-X.Y.Z/* /home/pi/software/in-updater/
$ rm -r release-X.Y.Z*
```
## 10. Declarar variables de entorno en inupdater
Antes de hacer esto se debe revisar el repositorio para validar si hay que instanciar nuevas variables
```bash
$ echo "export UPDATER_OTA_INMOTE=/home/pi/software/inmote">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_INAUTH_URL=https://inmote.api.insite.com.co:4500">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_CERTIFICATE_PATH=/home/pi/software/certificates">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_MBED_PATH=/home/pi/software/mbedtls">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_FILES=/home/pi/software/updater-files">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_FIRMWARES=/home/pi/software/firmwares">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_UPDATE_FILE=/home/pi/software/updates.txt">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_CRON_UPDATE_FILE=/home/pi/software/runUpdate">>/home/pi/.bashrc
$ echo "export UPDATER_OTA_CRON_AUTH_FILE=/home/pi/software/runAuth">>/home/pi/.bashrc
```
Ahora debemos crear las carpetas y los archivos que serán usadas por las variables de entorno
```bash
$ mkdir -p /home/pi/software/updater-files
$ mkdir -p /home/pi/software/firmwares
$ touch /home/pi/software/updates.txt
```
**Es muy importante NO terminar las rutas, tanto URL como de archivo con un `/` al final**

## 11. Crear cron Job para updater

## crear archivo de validacción de in-updater
```bash
$ touch /home/pi/software/in-updater-file.txt
```

### Primero se debe crear el archivo de ejecución del updater
```bash 
$ vim /home/pi/software/runAuth

#!/bin/sh
$$(which python) /home/pi/software/$(cat /home/pi/software/in-updater-file.txt)/main.pyc
```

```bash 
$ vim /home/pi/software/runUpdate

#!/bin/sh
$(which python) /home/pi/software/$(cat /home/pi/software/in-updater-file.txt)/update.pyc
```

### Ahora crear la carpeta para el firmware de actualización
```bash
$ mkdir -p /home/pi/software/in-updater2
```


Ejecutar 
```bash
$ crontab -e
```
Luego se deben añadir los siguientes jobs
```bash
0 3 * * * sh /home/pi/software/runAuth # Ejecuta rutinca de autenticación a las 3 de la mañana
5 3 * * * sh /home/pi/software/runUpdate # Corre rutina de update a las 3 y 5 de la mañana
```
## 12. Declarar archivo raspberry para inmote
Para que inmote sepa que está corriendo en un raspberry es necesario declarar el siguiente archivo
```bash
$ sudo echo "yesiam">/home/imraspberry
$ sudo chown pi:pi /home/imraspberry
$ sudo chmod 766 /home/imraspberry
```
Este archivo es obligatorio, sin el inmote no sabrá si es un navegador cualquiera o es un intouch
## 12. Instalar inmote
Debemos ejecutar los siguientes comandos, esto registrará la cosa en la nube, le dará autenticación y descargará el firmware de inmote en la carpeta definida por la variable de entorno `UPDATER_OTA_INMOTE`
```bash
$ python /home/pi/software/in-updater/main.pyc
$ python /home/pi/software/in-updater/update.pyc
```

## 13. Crear .xinitrc
```bash 
$ vim /home/pi/.xinitrc

#!/bin/sh
$(which electron) /home/pi/software/inmote/main.js
```

## 14. Añadir la siguiente linea a .bashrc para iniciar automáticamente inmote 
```bash 
$ echo "while :">>/home/pi/.bashrc
$ echo "do">>/home/pi/.bashrc
$ echo "startx -- -nocursor 2>/dev/null">>/home/pi/.bashrc
$ echo "done">>/home/pi/.bashrc
```
### Los archivos .xinitrc y .bashrc estarán en la carpeta `home/pi` de este repositorio

## 15 Añadir usuario pi a grupo sudo
Para que los comandos ejecutados por el inmote no fallen a razón de la falta de permisos
```bash
$ sudo usermod -g sudo pi
```
## 16 Dar permisos al archivo de configuración de red
Para poder modificar el archivo wp-supplicant se debe ejecutar el siguiente comando
```bash
$ sudo chmod 666 /etc/wpa_supplicant/wpa_supplicant.conf
```

también se debe dar permisos de escritura a la carpeta `wpa_supplicant`
```bash
$ sudo chmod 757 /etc/wpa_supplicant/
```


# Validar errores de electron
Debido a que Electron a veces se bloquea, se decide que inmote hace logs de forma continua cada minutos, por ende, debe existir un script que valide minuto a minuto estos logs y si el último log es mayor a tres minutos el dispositivo se debe reiniciar.

## 1. Se debe crear un archivo el cual almacenará los logs.

Este archivo estará /home/pi/lastCheckAlive.log
```bash 
$ touch /home/pi/lastCheckAlive.log
```

## 2. Crear archivo de python para la verificación
en la carpeta `/home/pi` contiene un archivo llamado `check_alive.py` este archivo debe ser pegado en `/home/pi` del raspberry, pues será el encargado de validar la antiguedad de los logs

Ejecutar 
```bash
$ crontab -e
```
Se debe agregar la siguiente linea
```bash
*/3 * * * * python /home/pi/check_alive.py 
``` 
