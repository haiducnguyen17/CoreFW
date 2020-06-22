from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.config import constants
from logigear.core.elements.table_element import TableElement

class SynchronizationPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.syncStatusIframe = self.element("syncStatusIframe")
        self.syncStatusTbl = self.element("syncStatusTbl", TableElement)
        self.refreshBtn = self.element("refreshBtn")
        
    def wait_until_device_synchronize_successfully(self, ipAdd=None, timeOut=constants.SELENPY_SYNCSWITCH_TIMEOUT):
        self.syncStatusIframe.wait_until_page_contains_element()
        driver.select_frame(self.syncStatusIframe)
        self._wait_for_processing()
        for i in range(0, timeOut):
            ipAddExist = self.syncStatusTbl._get_table_row_map_with_header("IP Address",ipAdd)
            self.refreshBtn.click_visible_element()
#             time.sleep(1.5) # hard sleep to waiting for the status changing to successful
            self._wait_for_processing()
            if ipAddExist ==0:
                break
            i += 1
        driver.unselect_frame()
    
    def close_quareo_synchronize_window(self):
        self.close_dialog()