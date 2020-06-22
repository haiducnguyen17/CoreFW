from logigear.page_objects.quareo_simulator.QSGeneralPage import QSGeneralPage
from logigear.core.config import constants


class QuareoDevicePageDesktop(QSGeneralPage):
    
    def __init__(self):
        QSGeneralPage.__init__(self);
        self.dynamicDeleteBtn = self.element("dynamicDeleteBtn")
        self.startAtIpTxt = self.element("startAtIpTxt")
        self.numberOfDevicesTxt = self.element("numberOfDevicesTxt")
        self.populateDataChk = self.element("populateDataChk")
        self.supportsPushChk = self.element("supportsPushChk")
        self.dynamicAddingTab = self.element("dynamicAddingTab")
        self.contentTypeCbb = self.element("contentTypeCbb")
        self.retainDataLnk = self.element("retainDataLnk")
        self.inputFileTxt = self.element("inputFileTxt")
        self.okBtn = self.element("okBtn")
        self.closeBtn = self.element("closeBtn")
        self.capacityUCbb = self.element("capacityUCbb")
        self.modulesCbb = self.element("modulesCbb")
        self.createBtn = self.element("createBtn")
        self.deviceSubTypeCbb = self.element("deviceSubTypeCbb")
        self.moduleContentTbl = self.element("moduleContentTbl")
        self.dynamicObjectQuareoTable = self.element("dynamicObjectQuareoTable")
        self.dynamicModuleIdLnk = self.element("dynamicModuleIdLnk")
        self.dynamicSwitchPortStateBtn = self.element("dynamicSwitchPortStateBtn")
        self.dynamicCableIdTxt = self.element("dynamicCableIdTxt")
        self.quareoDevicesLinkState = self.element("quareoDevicesLinkState")
        self.showEntriesCbb = self.element("showEntriesCbb")
        self.quareoDevicesTable = self.element("quareoDevicesTable")

    def delete_simulator_quareo_device(self, ipAddress):
        self.dynamicDeleteBtn.arguments = [ipAddress]
        self.dynamicDeleteBtn.click_element_if_exist()

    def add_simulator_quareo_device(self, startAtIp, numberOfDevices=1, populate=None, supportsPush=None, addType="Template", contentType=None, retainData=None, importFile=None, deviceType="Q2000", capacityUs=None, modules=None):
        """'startAtIp': the start at ip which to fill in when creating Quareo Devices on site manager page(ex: 1.1.1.1, 2.3.4.5)
        ...    'numberOfDevices': always default is 1
        ...    'populate', 'supportsPush', 'retainData': user can check or uncheck
        ...    'addType': user can choose two type: "File Based" or "Template"
        ...    'contentType': user can choose two type: "XML" or "JSON"
        ...    'importFile': user need input directory of import file
        ...    'deviceType': user can choose 4 type: Q2000, Q4000, QHDEP, QNG4
        ...    'capacityUs': user can choose: 1,2,4
        ...    'modules': user can choose one modules (ex: F12MPO08-R4MPO24-Straight, F24LCDuplex-R2MPO24-HD, v.v...)"""

        self._go_to_sub_page("Quareo Devices")
        self._set_entries(100)
        self.delete_simulator_quareo_device(startAtIp)
        
        temp = 0
        while not self.startAtIpTxt.is_element_visible() and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.createBtn.click_visible_element()
            self.startAtIpTxt.return_wait_for_element_visible_status()
            temp += 1
        
        temp = 0
        while self.startAtIpTxt.get_value() != startAtIp and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.startAtIpTxt.click_element()
            self.startAtIpTxt.input_text(startAtIp)
            self.startAtIpTxt.wait_until_element_attribute_contains("value", startAtIp)
            temp += 1
        
        self.numberOfDevicesTxt.click_element()
        self.numberOfDevicesTxt.input_text(numberOfDevices)
        
        if populate is not None:
            self.populateDataChk.select_checkbox(populate)
        if supportsPush is not None:
            self.supportsPushChk.select_checkbox(supportsPush)
        self.dynamicAddingTab.arguments = [addType]
        self.dynamicAddingTab.click_visible_element()
        if addType == "Template":
            self.deviceSubTypeCbb.select_from_list_by_label(deviceType)
            if capacityUs is not None:
                self.capacityUCbb.select_from_list_by_label(capacityUs)
            if modules is not None:
                self.modulesCbb.select_from_list_by_label(modules)
        else:
            if contentType is not None:
                self.contentTypeCbb.select_from_list_by_label(contentType)
            if retainData is not None:
                self.retainDataChk.select_checkbox(retainData)
            if importFile is not None:
                self.inputFileTxt.choose_file(importFile)
        self.okBtn.click_visible_element()
        self.okBtn.wait_until_element_is_not_visible()
        self._set_entries(100)
        self.wait_for_object_exist_on_quareo_device_table(startAtIp)
        
    def wait_for_object_exist_on_quareo_device_table(self, objectName, timeOut=constants.SELENPY_OBJECT_WAIT_PROBE):
        self.dynamicObjectQuareoTable.arguments = [objectName]
        self.dynamicObjectQuareoTable.wait_until_page_contains_element(timeOut)

    def get_quareo_module_information(self, startAtIp, moduleIndex):
        self.dynamicObjectQuareoTable.arguments = [startAtIp]
        if not self.dynamicObjectQuareoTable.is_element_present():
            self._go_to_sub_page("Quareo Devices")
            self._set_entries(100)
        self.dynamicObjectQuareoTable.click_visible_element()
        self.moduleContentTbl.wait_until_element_is_visible()
        moduleIdx = int(moduleIndex) + 2
        return self.moduleContentTbl.get_table_cell(moduleIdx, 1)

    def edit_quareo_simulator_port_properties(self, deviceID, moduleId, portId, cableId=None, portStatus="Unmanaged"):
        self._go_to_sub_page("Quareo Devices")
        self._set_entries(100)
        
        self.dynamicObjectQuareoTable.arguments = [deviceID]
        self.dynamicModuleIdLnk.arguments = [moduleId]
        self.dynamicSwitchPortStateBtn.arguments = [portId]
        
        self.dynamicObjectQuareoTable.click_visible_element()
        self.dynamicModuleIdLnk.click_visible_element()
        temp = 0
        while(self.dynamicModuleIdLnk.is_element_existed() and temp < constants.SELENPY_DEFAULT_TIMEOUT):
            self.dynamicModuleIdLnk.click_visible_element()
            temp += 1
        
        """ check and click if the switch port state button is not displayed """  
        temp = 0 
        while not self.dynamicSwitchPortStateBtn.return_wait_for_element_visible_status() and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.dynamicModuleIdLnk.click_visible_element()
            temp += 1
        
        if cableId is not None:
            self.dynamicCableIdTxt.arguments = [portId]
            self.dynamicCableIdTxt.wait_until_element_is_visible()
            self.dynamicCableIdTxt.set_customize_attribute_for_element_by_js("value" ,cableId)
            
        """ check and click if the switch port state button is not clicked properly """
        if portStatus == "Empty":
            temp = 0
            while not "success" in self.dynamicSwitchPortStateBtn.get_element_attribute("class") and temp < constants.SELENPY_DEFAULT_TIMEOUT:
                self.dynamicSwitchPortStateBtn.click_element()
                self.dynamicSwitchPortStateBtn.wait_until_element_attribute_contains("class", "success", constants.SELENPY_DEFAULT_TIMEOUT)
                temp += 1
        elif portStatus == "Unmanaged" or portStatus == "Managed":
            temp = 0
            while not "danger" in self.dynamicSwitchPortStateBtn.get_element_attribute("class") and temp < constants.SELENPY_DEFAULT_TIMEOUT:
                self.dynamicSwitchPortStateBtn.click_element()
                self.dynamicSwitchPortStateBtn.wait_until_element_attribute_contains("class", "danger", constants.SELENPY_DEFAULT_TIMEOUT)
                temp += 1

    def _set_entries(self, value):
        self.showEntriesCbb.select_from_list_by_label(value)
        self.quareoDevicesTable.wait_for_element_outer_html_not_change()