## Iniciar sesion
`La contraseña por defecto es pi:raspberry`
## 1 Actualizar Raspberry
```bash
sudo apt-get update
```
# Configuración de usuarios
## 1 Crear usuario DEV
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


## Activar ssh con  SOLO DESARROLLO
Ejecutar
```bash
$ sudo raspi-config
```
Luego en la ventana emergente.
- Seleccionar Interfacing Options
- SSH
- YES

# Configuración de boot 

## 1. modificar /boot/cmdline.txt
```bash 
$ sudo cp /boot/cmdline.txt /boot/cmdline.old.txt
$ sudo echo "dwc_otg.lpm_enable=0 console=serial0,115200 console=tty3 root=PARTUUID=7ebe8cf8-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait quiet splash loglevel=0 logo.nologo vt.global_cursor_default=0 plymouth.ignore-serial-consoles">/boot/cmdline.txt
```

## 2. Quitar mensajes de kernel
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
$ touch /home/dev/.hushlogin
```

## 3. Cambiar el auto login
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
$ scp splash/180x180.png dev@192.168.1.240:/home/dev/
```
```bash 
$ sudo apt-get install plymouth plymouth-themes pix-plym-splash -y
$ sudo plymouth-set-default-theme pix
```

```bash 
$ sudo cp /usr/share/plymouth/themes/pix/splash.png /usr/share/plymouth/themes/pix/splash.old.png
$ sudo cp /home/dev/180x180.png /usr/share/plymouth/themes/pix/splash.png
```

### 4.2 Borrar texto del splash screen

```bash 
$ vim /usr/share/plymouth/themes/pix/pix.script
```

### 4.3 Comentar las siguientes lineas
```bash
message_sprite = Sprite();
message_sprite.SetPosition(screen_width * 0.1, screen_height * 0.9, 10000);

my_image = Image.Text(text, 1, 1, 1);
message_sprite.SetImage(my_image);
```

## 5. Configuración de /boot/

### Transferir /boot/config.txt a rpi
Transferir por scp el archivo /boot/config.txt
```bash 
$ scp boot/config.txt dev@192.168.1.158:/home/dev/
```
```bash 
$ sudo mv /boot/config.txt /boot/config.old.txt
$ sudo cp /home/dev/config.txt /boot/config.txt
$ rm /home/dev/config.txt
```
# Configurar interfaz de red
## 1. Instalar ifplugd
```bash
$ sudo apt-get install ifplugd
```
Esta configuración se hace para apagar el wlan si hay un cable de red conectado
```bash 
$ scp etc/ifplugd/action.d/ifupdown dev@192.168.1.158:/home/dev/
```
```bash 
$ sudo cp /home/dev/ifupdown /etc/ifplugd/action.d/ifupdown
```

Ahora debemos ejecutar el proceso de ifplugd en el arranque del dispositivo, para esto debemos añadir las siguientes lineas antes del exit 0 en el archivo `/etc/rc.local`
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

## 3. Transferir el proyecto inmote al raspberry 
Transferir por scp el archivo zip de inmote
```bash 
$ scp release-1.23.6.zip dev@192.168.1.158:/home/dev/
```
```bash 
$ mkdir inmote && mv release-1.23.6.zip inmote && cd inmote
$ unzip release-1.23.6.zip
$ rm release-1.23.6.zip
```
## 4. Crear .xinitrc
```bash 
$ vim /home/dev/.xinitrc

#!/bin/sh
$(which electron) /home/dev/inmote/main.js
```

## 5. Añadir la siguiente linea a .bashrc para iniciar automáticamente inmote 
```bash 
$ echo "while :">>/home/dev/.bashrc
$ echo "do">>/home/dev/.bashrc
$ echo "startx -- -nocursor 2>/dev/null >/dev/null">>/home/dev/.bashrc
$ echo "done">>/home/dev/.bashrc
```

## Instalar XTER para Desarrollo
```bash 
$ sudo apt-get install -y xterm
```

