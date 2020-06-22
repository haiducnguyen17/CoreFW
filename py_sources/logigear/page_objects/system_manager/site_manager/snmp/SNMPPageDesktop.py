from logigear.core.assertion import Assert
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
import time
from logigear.core.config import constants
from logigear.core.utilities import utils
from logigear.core.elements.table_element import TableElement

class SNMPPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.snmpStatusIframe = self.element("snmpStatusIframe")
        self.snmpTaskStatusIframe = self.element("snmpTaskStatusIframe")
        self.snmpStatusTbl = self.element("snmpStatusTbl")
        self.snmpStatusTbl.__class__ = TableElement
        self.refreshBtn = self.element("refreshBtn")
            
    def close_snmp_status_window(self):
        self.close_dialog()
    
    def wait_until_synchronize_successfully(self, switchName=None, ipAdd=None, timeOut=constants.SELENPY_SYNCSWITCH_TIMEOUT, closeWindow=True):
        """Use to wait until the status of switch change to "Scheduled" in SNMP Status Window
    ...    We have 4 arguments:
    ...    - 'switchName': name of switch
    ...    - 'ipAdd': IP address of switch
    ...    - 'timeOut'
    ...    - 'closeWindow'"""
        
        self.snmpStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.snmpStatusIframe)
        self.snmpTaskStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.snmpTaskStatusIframe)
        self.snmpStatusTbl.wait_until_element_is_visible()
        pssInfo = "Poll Switch Status"+ "--" + switchName + "--" + ipAdd + "--" + "Scheduled" 
        ddErrorInfo = "Discover Devices Information"+ "--" + switchName + "--" + ipAdd + "--" + "Scheduled For Automatic Retry"
        for i in range(0, timeOut):
            self.refreshBtn.click_element()
            time.sleep(1) # hard sleep to waiting for the status changing to successful
            pssRow = self.snmpStatusTbl._get_table_row_map_with_header("Action Type--Device--IP Address--Status", pssInfo, "--")
            ddErrorRow = self.snmpStatusTbl._get_table_row_map_with_header("Action Type--Device--IP Address--Status", ddErrorInfo, "--")
            if pssRow > 0:
                syncTime = utils.get_current_date_time(resultFormat="%#m/%#d/%#Y %I:%M")
                break
            elif ddErrorRow > 0:
                utils.fatal_error("This managed switch cannot be synchronized. Please double-check it")
            else:
                i += 1
        driver.unselect_frame()
        if closeWindow:
            self.close_snmp_status_window()
        return  syncTime 

    def wait_until_discover_device_successfully(self, switchName=None, ipAdd=None, timeOut=constants.SELENPY_SYNCSWITCH_TIMEOUT, closeWindow=True):
        """Wait until the discover device switch successful in SNMP Status Window.
    ...    We have 4 arguments:
    ...    - 'switchName': name of switch
    ...    - 'ipAdd': IP address of switch
    ...    - 'timeOut'
    ...    - 'closeWindow'"""
        
        self.snmpStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.snmpStatusIframe)
        self.snmpTaskStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.snmpTaskStatusIframe)
        self._wait_for_processing()
        self.snmpStatusTbl.wait_until_element_is_visible()
        waitSwitchDiscover = "Discover Devices"+ "--" + switchName + "--" + ipAdd
        for i in range(0, int(timeOut)):
            self.refreshBtn.click_element()
            time.sleep(1) # hard sleep to waiting for the status changing to successful
            returnRow = self.snmpStatusTbl._get_table_row_map_with_header("Action Type--Device--IP Address", waitSwitchDiscover, "--")
            if(returnRow > 0):
                i += 1
            else:
                break
        driver.unselect_frame()
        if closeWindow:
            self.close_snmp_status_window()
    
    def check_synchronize_switch_successfully(self, switchName=None, ipAdd=None, closeWindow=True):
        """Use to check the status of switch change to "Scheduled" in SNMP Status Window.
    ...    We have 3 arguments:
    ...    - 'switchName': name of switch
    ...    - 'ipAdd': IP address of switch
    ...    - 'closeWindow'"""
    
        self.snmpStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.snmpStatusIframe)
        self.snmpTaskStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.snmpTaskStatusIframe)
        self.snmpStatusTbl.wait_until_element_is_visible()
        switchStatus = switchName + "--" + ipAdd + "--" + "Scheduled"
        returnRow = self.snmpStatusTbl._get_table_row_map_with_header("Device--IP Address--Status", switchStatus, "--")
        Assert.should_be_true(returnRow > 0, "Switch synchronize successfully.")
        driver.unselect_frame()
        if closeWindow:
            self.close_snmp_status_window()
        
