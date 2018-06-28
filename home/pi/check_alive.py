from os import system
from time import time

def main():
  try:
    file = open("/home/pi/lastCheckAlive.log","r")
    txt = file.read()
    file.close()
  except IOError:
    print "error"
    return

  try:
    txt.index("IMALIVE")
  except ValueError:
    print "IMALIVE NOT PRESENT"
    return
  msDate = txt[11:]
  if msDate == "":
    print "DATE IS EMPTY"
    return
  sDate = int(msDate)/1000
  now = time()
  timeDifMins = (now - sDate)/60
  if timeDifMins > 3:
    print "Electron is dead"
    system("sudo reboot")
  else:
    print "electron still alive",timeDifMins

main()
