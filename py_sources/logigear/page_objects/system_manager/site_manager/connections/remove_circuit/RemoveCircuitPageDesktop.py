'''
Created on May 5, 2020

@author: tiep.tra
'''
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.site_manager.connections import connection


class RemoveCircuitPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.removeAllPatchesRadio = self.element("removeAllPatchesRadio")
        self.selectPatchesRadio = self.element("selectPatchesRadio")
        self.removeCircuitIframe = self.element("removeCircuitIframe")
        self.traceMapDiv = self.element("traceMapDiv")
        
    def remove_circuit(self, removeAllPatches=True, createWo=True, clickNext=True):
        self._select_iframe(self.removeCircuitIframe, self.removeAllPatchesRadio)
        if not removeAllPatches:
            self.selectPatchesRadio.wait_until_element_is_visible()
            self.selectPatchesRadio.select_radio_button("removePatches", "selectPatches")
        connection.createWoChk.select_checkbox(createWo)
        driver.unselect_frame()
        if clickNext:
            self.confirmDialogBtn.click_visible_element()
            
    def uncheck_remove_patching_on_remove_circuit_window(self, indexObject, clickNext=True):
        self._select_iframe(self.removeCircuitIframe, self.traceMapDiv)
        idObject = int(indexObject) * 2 - 1
        traceMapXpath = self._define_trace_map_xpath(self.traceMapDiv)
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
        
    def select_view_trace_tab_on_remove_circuit_window(self, viewTab):
        self._select_iframe(self.removeCircuitIframe, self.traceMapDiv)
        self._select_view_trace_tab(self.traceMapDiv, viewTab)
        driver.unselect_frame()