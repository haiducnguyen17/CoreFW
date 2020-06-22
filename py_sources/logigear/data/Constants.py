import os
webuser = "webuser"
password = "password"
DIR_BACKUPFILE_COMMSCOPE = "C:\Program Files\CommScope\imVision System Manager\Web\Data\BackupFiles"
OBJECT_WAIT = 30
OBJECT_WAIT_PROBE = 10
URL = "http://" + os.environ['system'] + "/systemmanager"
QUAREO_DEVICES_URL = "http://" + webuser + ":" + password + "@" + os.environ['middlewaresystem'] + "/app/quareo-devices-list.html"
USERNAME = "admin"
PASSWORD = "Admin1"