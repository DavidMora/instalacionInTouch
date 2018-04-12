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

`<NAME OF DISK>` puede ser disk4 por ejemplo.

Copiar la imagen a la SD
```sh
$ sudo dd bs=1m if=2018-03-13-raspbian-stretch.img of=/dev/r<NAME OF DISK> conv=sync
```
# Iniciar sesion
`La contraseña por defecto es pi:raspberry`
## 1. Actualizar Raspberry
```bash
sudo apt-get update
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
$ sudo cp /boot/cmdline.txt /boot/cmdline.old.txt
$ sudo echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty3 root=PARTUUID=7ebe8cf8-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash loglevel=0 logo.nologo vt.global_cursor_default=0 plymouth.ignore-serial-consoles">/boot/cmdline.txt
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
$ scp splash/180x180.png pi@192.168.1.240:/home/pi/
```

```bash 
$ sudo cp /usr/share/plymouth/themes/pix/splash.png /usr/share/plymouth/themes/pix/splash.old.png
$ sudo cp /home/pi/180x180.png /usr/share/plymouth/themes/pix/splash.png
```

### 4.3 Borrar texto del splash screen

### El archivo pix.script se encuentra en la carpeta `usr/share/plymouth/themes/pix/pix.script` de este repositorio

```bash 
$ vim /usr/share/plymouth/themes/pix/pix.script
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

### El archivo rc.local se puede encontrar en la carpeta `/etc/rc.local` de este repo

```bash
# Start ifplugd daemon to connect or disconect the wlan0 interface
ifplugd
```

Este archivo debe terminar de la siguiente forma
```bash
# Start ifplugd daemon to connect or disconect the wlan0 interface
ifplugd
exhit 0
```
# Instalar servidor X

## 1. instalar servidor x
```bash 
$ sudo apt-get --no-install-recommends install xserver-xorg xserver-xorg-video-fbdev xinit pciutils xinput xfonts-100dpi xfonts-75dpi xfonts-scalable -y

$ sudo apt-get install libgtk2.0-0 libxrender1 libxtst6 libxi6 libxss-dev libgconf-2-4 libasound2 libnss3-dev -y

$ sudo apt-get install -y mesa-utils libgl1-mesa-glx
```

# Instalar Node

## 1. Instalar node 8.11.1
```bash
$ wget https://nodejs.org/dist/v8.11.1/node-v8.11.1-linux-armv6l.tar.gz 
$ tar -xvf node-v8.11.1-linux-armv6l.tar.gz 
$ cd node-v8.11.1-linux-armv6l
$ sudo cp -R * /usr/local/
$ cd ..
$ rm -r node-v8.11.1-linux-armv6l 
$ rm node-v8.11.1-linux-armv6l.tar.gz
```

## 2. Instalar Electron
La versión 1.7.9 es funcional para rasberry
```bash
$ npm install -g electron@1.7.9 --unsafe-perm=true --allow-root
```

# Instalar software de dependencias de INUPDATER

Se dene revisar el archivo requirements.txt del repositorio `linuxOTAComptiblwUpdater`
## 1. Instalar pip
```bash
$ sudo apt-get install python-pip
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
Igualmente se debe crear en `/home/pi/software/certificates/`un archivo `list.txt` el cual contiene la siguiente estructura, `<NAME_OF_FOLDER>`:`<CERTIFICATE_ID>`

un ejemplo es: `intouch_15_3100270:f448fb1ac612635f8af15e70961e47a8`

## 8. Instalar biblioteca criptográfica mbedtls

Se debe descargar el último release del repositorio. Se debe tener presente la rama de la cual se va a descargar el release

https://github.com/DavidMora/mbedtls-arch-dependant-releases

Si por algún motivo no se encutra el código necesitado se puede seguir el siguiente paso
### OPCIONAL **NO** se cuenta con los binarios de los archivos de `mbedtls/pk_sign` y `mbedtls/aescrypt2` **compilados en ARM Raspberry**

Copiar carpeta de desarrollo de mbedtl usada en `in-updater` a raspberry
```bash 
$ scp -r mbedtls pi@192.168.1.118:/home/pi/
```
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

### Se cuenta con los binarios de los archivos de `mbedtls/pk_sign` y `mbedtls/aescrypt2` **compilados en ARM Raspberry**
```bash 
$ scp -r aescrypt2 pi@192.168.1.118:/home/pi/
$ scp -r pk_sign pi@192.168.1.118:/home/pi/
```
```bash 
$ mkdir -p /home/pi/software/mbedtls/programs/aes
$ mkdir -p /home/pi/software/mbedtls/programs/pkey
$ cp /home/pi/aescrypt2 /home/pi/software/mbedtls/programs/aes
$ cp /home/pi/pk_sign /home/pi/software/mbedtls/programs/pkey
```


## 9. Descargar inUpdater

Para descargar el inupdater se debe descargar el último release de github en el repositorio
`https://github.com/DavidMora/linuxOTAComptiblwUpdater/releases/`
```bash 
$ scp release-X.Y.Z.tar.gz pi@192.168.1.118:/home/pi/
```
```bash
$ tar xvzf release-X.Y.Z.tar.gz
$ mkdir -p software/in-updater
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
```
Ahora debemos crear las carpetas que serán usadas por las variables de entorno
```bash
$ mkdir -p /home/pi/software/updater-files
$ mkdir -p /home/pi/software/firmwares
```
**Es muy importante NO terminar las rutas, tanto URL como de archivo con un `/` al final**

## 11. Crear cron Job para updater
Ejecutar 
```bash
$ crontab -e
```
Luego se deben añadir los siguientes jobs
```bash
0 3 * * * $(which python) /home/pi/software/in-updater/main.pyc # Ejecuta rutinca de autenticación a las 3 de la mañana
5 3 * * * $(which python) /home/pi/software/in-updater/update.pyc # Corre rutina de update a las 3 y 5 de la mañana
```

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
$(which electron) /home/pi/inmote/main.js
```

## 14. Añadir la siguiente linea a .bashrc para iniciar automáticamente inmote 
```bash 
$ echo "while :">>/home/pi/.bashrc
$ echo "do">>/home/pi/.bashrc
$ echo "startx -- -nocursor 2>/dev/null >/dev/null">>/home/pi/.bashrc
$ echo "done">>/home/pi/.bashrc
```
### Los archivos .xinitrc y .bashrc estarán en la carpeta `home/pi` de este repositorio
