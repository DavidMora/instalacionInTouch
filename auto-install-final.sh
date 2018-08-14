#!/bin/sh
check_command (){
  if [ $? -ne 0 ]; then
    echo "$(date) -- $1\n">>/home/pi/auto-logs/error.log
  fi
}
# Crear cron para autorizar, actualizar y validar electron
cp /home/pi/install/home/pi/updatecron /home/pi/updatecron
check_command "copy cron file"

crontab /home/pi/updatecron
check_command "create crontab updatecron"

echo "export UPDATER_OTA_UPDATE_FILE=/home/pi/software/updates.txt">>/home/pi/.bashrc

echo "while :">>/home/pi/.bashrc
echo "do">>/home/pi/.bashrc
echo "startx -- -nocursor 2>/dev/null >/dev/null">>/home/pi/.bashrc
echo "done">>/home/pi/.bashrc