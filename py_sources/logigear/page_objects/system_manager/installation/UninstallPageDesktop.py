'''
Created on Mar 11, 2020

@author: tiep.tra
'''
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
import os
import autoit
import shutil
from logigear.core.utilities import utils


class UninstallPageDesktop(GeneralPage):
 
    def __init__(self):
        GeneralPage.__init__(self)
        
    def uninstall_sm_build(self):
        
        uninstallPath = utils.get_registry_value("HKEY_LOCAL_MACHINE", "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\SystemManager", "UninstallString")
        if uninstallPath != "" and uninstallPath != None:
            os.startfile(uninstallPath)
            autoit.win_wait_active("imVision System Manager Setup")
            autoit.control_focus("imVision System Manager Setup", "[NAME:buttonNext]")
            autoit.control_click("imVision System Manager Setup", "[NAME:buttonNext]")
            autoit.win_wait_active("Confirm")
            autoit.control_focus("Confirm", "[CLASS:Button; INSTANCE:1]")
            autoit.control_click("Confirm", "[CLASS:Button; INSTANCE:1]")
            autoit.win_wait_close("imVision System Manager Setup",timeout=600)
            shutil.rmtree("C:/Program Files/CommScope",True)
        
    def delete_sm_database(self, server):
        deleteSNMPConnectionQuery = '"'"alter database [SNMPSiteData] set single_user with rollback immediate"'"'
        deleteSMConnectionQuery = '"'"alter database [SystemManager7] set single_user with rollback immediate"'"'
        deleteSNMPQuery = '"'"drop database [SNMPSiteData]"'"'
        deleteSMQuery = '"'"drop database [SystemManager7]"'"'
        SNMPConnectionCommand = "sqlcmd -S .\\" + server +" -Q " + deleteSNMPConnectionQuery
        SMConnectionCommand = "sqlcmd -S .\\" + server +" -Q " + deleteSMConnectionQuery
        SNMPCommand = "sqlcmd -S .\\" + server +" -Q " + deleteSNMPQuery
        SMCommand = "sqlcmd -S .\\" + server +" -Q " + deleteSMQuery
        os.system(SNMPConnectionCommand)
        os.system(SMConnectionCommand)
        os.system(SNMPCommand)
        os.system(SMCommand)
        
    def install_sm_by_cmd(self, locationPath, typeInstall="fresh install", keyCode="4z4ba-Y9T2V-EF74Y-4bSwA-DbAbF-6bea3-Db9hG"):
        """locationPath: The location path include sm build
            typeInstall: Type of install(fresh install, upgrade install)
            keyCode: license key"""
        isDataServerExisted = locationPath[:2]
        if typeInstall == "fresh install":
            cmd = ".\Package\SM.Setup.exe keycode=" + keyCode
        else:
            cmd = ".\Package\SM.Setup.exe silent=true"
        if isDataServerExisted == "\\\\":
            navigate = "pushd " + locationPath
            finalCmd = navigate + " && " + cmd + "&& popd"
        else:
            navigate = "cd /d " + locationPath
            finalCmd = navigate + " && " + cmd
        os.system(finalCmd)
        
