## DECLARACION DE VARIABLES ##
#d flag es si es un dispositivo de desarrollo
#i flag es si es un dispositivo de desarrollo y IP_DEV sera el argumento i que contiene la ip del incloud de desarrollo

DEV=0;
IP_DEV=0;
while getopts ":i:d:" option; do
  case "${option}" in
    i) 
      IP_DEV=${OPTARG}
      echo "IP_DEV:$IP_DEV">>/home/pi/auto-logs/args;;
    d) 
      DEV=1
      echo "dev:$DEV">>/home/pi/auto-logs/args;;
  esac
done

# Declarar variables de entorno en inupdater
if [ $DEV -eq 1 ]; then
  echo "export UPDATER_OTA_INAUTH_URL=https://$IP_DEV:4500">>/home/pi/.bashrc
  echo "export UPDATER_OTA_OTA_URL=$IP_DEV">>/home/pi/.bashrc
  echo "export UPDATER_OTA_OTA_PORT=4445">>/home/pi/.bashrc
else
  echo "export UPDATER_OTA_INAUTH_URL=https://inmote.api.insite.com.co:4500">>/home/pi/.bashrc
fi
echo "export UPDATER_OTA_INMOTE=/home/pi/software/inmote">>/home/pi/.bashrc
echo "export UPDATER_OTA_CERTIFICATE_PATH=/home/pi/software/certificates">>/home/pi/.bashrc
echo "export UPDATER_OTA_MBED_PATH=/home/pi/software/mbedtls">>/home/pi/.bashrc
echo "export UPDATER_OTA_FILES=/home/pi/software/updater-files">>/home/pi/.bashrc
echo "export UPDATER_OTA_FIRMWARES=/home/pi/software/firmwares">>/home/pi/.bashrc
echo "export UPDATER_OTA_UPDATE_FILE=/home/pi/software/updates.txt">>/home/pi/.bashrc
echo "export UPDATER_OTA_CRON_UPDATE_FILE=/home/pi/software/runUpdate">>/home/pi/.bashrc
echo "export UPDATER_OTA_CRON_AUTH_FILE=/home/pi/software/runAuth">>/home/pi/.bashrc
