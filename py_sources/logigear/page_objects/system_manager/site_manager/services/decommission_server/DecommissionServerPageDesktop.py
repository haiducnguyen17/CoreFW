'''
Created on May 5, 2020

@author: tiep.tra
'''
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.services import services
from logigear.core.drivers import driver
from logigear.core.elements.table_element import TableElement

class DecommissionServerPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.dynamicRemoveConnectRadio = self.element("dynamicRemoveConnectRadio")
        self.removeServerChk = self.element("removeServerChk")
        self.serverPortTbl = self.element("serverPortTbl", TableElement)
        self.traceMapDiv = self.element("traceMapDiv")
        self.decommissionServerOptionIframe = self.element("decommissionServerOptionIframe")  
        self.dynamicObjectXpath = self.element("dynamicObjectXpath")
        self.dynamicScheduleIconXpath = self.element("dynamicScheduleIconXpath")              
                    
    def decommission_server(self, typeRemove="1", removeServer=True):
        """typeRemove: 1,2,3"""
        self._select_iframe(services.serviceIframe, self.removeServerChk)
        self._wait_for_processing()
        self.dynamicRemoveConnectRadio.arguments = [typeRemove]
        self.dynamicRemoveConnectRadio.select_radio_button("RemoveOption", typeRemove)
        self.removeServerChk.select_checkbox(removeServer)
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
    
    def remove_patching_on_decommission_server_window(self, portName=None, indexObjects=None, clickNext=True, delimiter=","):
        self._select_iframe(self.decommissionServerOptionIframe, self.traceMapDiv)
        if portName is not None:
            returnRow = self.serverPortTbl._get_table_row_map_with_header("Port Name", portName)
            self.serverPortTbl._click_table_cell(returnRow, 1)       
            traceMapXpath = self._define_trace_map_xpath(self.traceMapDiv)  
            listIndexObjects = indexObjects.split(delimiter)
            for indexObject in listIndexObjects:   
                idObject = int(indexObject) * 2 - 1    
                self.dynamicObjectXpath.arguments = [traceMapXpath, str(idObject)]
                if(traceMapXpath.__contains__("//div[@id='divTrace']")):
                    self.dynamicObjectXpath.mouse_over()
                else:
                    self.dynamicObjectXpath.click_visible_element()
                    self.dynamicScheduleIconXpath.arguments = [traceMapXpath, str(idObject), "CrossChecked"]
                    self.dynamicScheduleIconXpath.click_visible_element()
        driver.unselect_frame()
        if clickNext:
            self.confirmDialogBtn.click_visible_element()            
            