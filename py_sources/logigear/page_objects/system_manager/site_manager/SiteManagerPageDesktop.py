from logigear.core.assertion import SeleniumAssert, Assert
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.element import Element
import os
import time
from logigear.core.elements.table_element import TableElement
from logigear.data import Constants
from logigear.core.drivers import driver
from logigear.core.elements.tree_element import TreeElement
from logigear.core.config import constants

class SiteManagerPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.usernameLbl = self.element("usernameLbl")
        self.remindlaterBtn = self.element("remindlaterBtn")
        self.siteTreeDiv = self.element("siteTreeDiv", TreeElement)
        self.contentTbl = self.element("contentTbl", TableElement)
        self.dynamicObjectOnContentTbl = self.element("dynamicObjectOnContentTbl")
        self.allChk = self.element("allChk")
        self.traceMapDiv = self.element("traceMapDiv")
        self.switchTraceViewBtn = self.element("switchTraceViewBtn")
        self.deleteBtn = self.element("deleteBtn")
        self.disabledDeleteBtn = self.element("disabledDeleteBtn")
        self.dialogConfirmBtn = self.element("dialogConfirmBtn")
        self.connectionBtn = self.element("connectionsBtn")
        self.conduitsLnk = self.element("conduitsLnk")
        self.defineEquipmentPatchLnk = self.element("defineEquipmentPatchLnk")
        self.eventBtn = self.element("eventBtn")
        self.dynamicEventsLnk = self.element("dynamicEventsLnk")
        self.frontToBackCablingLnk = self.element("frontToBackCablingLnk")
        self.ospCablingLnk = self.element("ospCablingLnk")
        self.patchingLnk = self.element("patchingLnk")
        self.replaceNetworkEquipmentLnk = self.element("replaceNetworkEquipmentLnk")
        self.upgradeToiPatchLnk = self.element("upgradeToIpatchLnk")
        self.dynamicObjectlbl = self.element("dynamicObjectLbl")
        self.copyBtn = self.element("copyBtn")
        self.pasteBtn = self.element("pasteBtn")
        self.objectToAddOkBtn = self.element("objectToAddOkBtn")
        self.quantityTxt = self.element("quantityTxt")   
        self.updateMneNameChk = self.element("updateMneNameChk")
        self.dynamicContextMenuItem = self.element("dynamicContextMenuItem")
        self.twoChoiceYesDiv = self.element("twoChoiceYesDiv")
        self.twoChoiceNoDiv = self.element("twoChoiceNoDiv")
        self.addBtn = self.element("addBtn")
        self.disabledAddBtn = self.element("disabledAddBtn")
        self.editBtn = self.element("editBtn")
        self.disabledEditBtn = self.element("disabledEditBtn")
        self.buildingLnk = self.element("buildingLnk")
        self.nameTxt = self.element("nameTxt")
        self.cableVaultNameTxt = self.element("cableVaultNameTxt")
        self.saveObjectBtn = self.element("saveObjectBtn")
        self.descriptionTxt = self.element("descriptionTxt")
        self.zoneModeCbb = self.element("zoneModeCbb")
        self.zoneCbb = self.element("zoneCbb")
        self.contactCbb = self.element("contactCbb")
        self.faceplatePortTypeCbb = self.element("faceplatePortTypeCbb")
        self.maximumOutletsCbb = self.element("maximumOutletsCbb")
        self.totalPortsTxt = self.element("totalPortsTxt")
        self.firstNameTxt = self.element("firstNameTxt")
        self.lastNameTxt = self.element("lastNameTxt")
        self.rackUnitsTxt = self.element("rackUnitsTxt")
        self.locationInRackCbb = self.element("locationInRackCbb")
        self.dynamicViewTypeImg = self.element("dynamicViewTypeImg")
        self.dynamicLockToggleLnk = self.element("dynamicLockToggleLnk")
        self.hidePropertiesDiv = self.element("hidePropertiesDiv")
        self.hideTreeDiv = self.element("hideTreeDiv")
        self.circuitProvisioningLnk = self.element("circuitProvisioningLnk")
        self.cablingLnk = self.element("cablingLnk")
        self.quareoUnmanagedConnectionsLnk = self.element("quareoUnmanagedConnectionsLnk")
        self.cableByNameLnk = self.element("cableByNameLnk")
        self.positionTxt = self.element("positionTxt")
        self.dynamicIpV4Txt = self.element("dynamicIpV4Txt")
        self.portTypeCbb = self.element("portTypeCbb")
        self.cableVaultBtn = self.element("cableVaultBtn")
        self.tableObjectNameLbl = self.element("tableObjectNameLbl")
        self.cancelTraceBtn = self.element("cancelTraceBtn")
        self.popupErrorMsg = self.element("popupErrorMsg")
        self.confirmSavePopupBtn = self.element("confirmSavePopupBtn")
        self.objectSpaceviewIcon = self.element("objectSpaceviewIcon")
        self.labelHideBtn = self.element("labelHideBtn")
        self.labelBtn = self.element("labelBtn")
        self.iconImageObject = self.element("iconImageObject")
        self.dynamicObjectSpaceviewLabel = self.element("dynamicObjectSpaceviewLabel")
        self.showTreeBtn = self.element("showTreeBtn")
        self.hideTreeBtn = self.element("hideTreeBtn")
        self.imageLayerCbb = self.element("imageLayerCbb")
        self.dynamicZoomMapBtn = self.element("dynamicZoomMapBtn")
        self.dynamicSnmpMenuLnk = self.element("dynamicSnmpMenuLnk")
        self.snmpLnk = self.element("snmpLnk")
        self.nddChk = self.element("nddChk")
        self.dynamicObjectTypeLbl = self.element("dynamicObjectTypeLbl")
        self.dynamicAssignUser = self.element("dynamicAssignUser")
        self.assignBtn = self.element("assignBtn")
        self.assignUserTable = self.element("assignUserTable")
        self.assignSaveBtn = self.element("assignSaveBtn")
        self.dynamicPortColor = self.element("dynamicPortColor")
        self.dynamicLeftTreeFilterBtn = self.element("dynamicLeftTreeFilterBtn")
        self.dynamicVerticalTraceTbl = self.element("dynamicVerticalTraceTbl")
        self.slotCapacityTxt = self.element("slotCapacityTxt")
        self.mapGraph = self.element("mapGraph")
        self.criticalChk = self.element("criticalChk")
        self.notAvailableChk = self.element("notAvailableChk")
        self.reservedChk = self.element("reservedChk")
        self.uplinkPortChk = self.element("uplinkPortChk")
        self.synchronizeYesLnk = self.element("synchronizeYesLnk")
        self.mapDiv = self.element("mapDiv")
        self.mapTilerLnk = self.element("mapTilerLnk")
        self.openStreetMapLnk = self.element("openStreetMapLnk")
        self.googleLnk = self.element("googleLnk")
        self.googleGuidelinesLnk = self.element("googleGuidelinesLnk")
        self.showHideUplinkBtn = self.element("showHideUplinkBtn")
        self.uplinkTab = self.element("uplinkTab")
        self.spliceTypeCbb = self.element("spliceTypeCbb")
        self.totalSplicesTxt = self.element("totalSplicesTxt")
        self.deviceInRackTypeCbb = self.element("deviceInRackTypeCbb")
        self.cutBtn = self.element("cutBtn")
        self.viewTypeTraceCbb = self.element("viewTypeTraceCbb")
        self.historyBtn = self.element("historyBtn")
        self.circuitHistoryLnk = self.element("circuitHistoryLnk")
        self.refreshBtn = self.element("refreshBtn")
        self.dynamicPropertyValue = self.element("dynamicPropertyValue")
        self.centerPanelTitle = self.element("centerPanelTitle")
        self.centerPanelContentList = self.element("centerPanelContentList")
        self.contextMenuSyncYesLnk = self.element("contextMenuSyncYesLnk")
        self.contextMenuSyncNoLnk = self.element("contextMenuSyncNoLnk")
        self.dynamicPriorityEventIcon = self.element("dynamicPriorityEventIcon")
        self.connectionIdTxt = self.element("connectionIdTxt")
        self.serviceTicketIdTxt = self.element("serviceTicketIdTxt")
        self.cordLengthTxt = self.element("cordLengthTxt")
        self.cordTypeTxt = self.element("cordTypeTxt")
        self.cordColorTxt = self.element("cordColorTxt")
        self.portField1Txt = self.element("portField1Txt")
        self.portField2Txt = self.element("portField2Txt")
        self.portField3Txt = self.element("portField3Txt")
        self.portField4Txt = self.element("portField4Txt")
        self.portField5Txt = self.element("portField5Txt")
        self.staticRearChk = self.element("staticRearChk")
        self.staticFrontChk = self.element("staticFrontChk")
        self.staticChk = self.element("staticChk")
        self.workOrdersBtn = self.element("workOrdersBtn")
        self.workOrderQueueLnk = self.element("workOrderQueueLnk")
        self.selectImageBtn = self.element("selectImageBtn")
        self.selectImageCbb = self.element("selectImageCbb")
        self.confirmPopupBtn = self.element("confirmPopupBtn")
        self.cancelPopupBtn = self.element("cancelPopupBtn")
        self.dynamicPropertiesEquipmentImage = self.element("dynamicPropertiesEquipmentImage")
        self.dynamicEquipmentImageRackViewFront = self.element("dynamicEquipmentImageRackViewFront")
        self.dynamicEquipmentImageRackViewZeroU = self.element("dynamicEquipmentImageRackViewZeroU")
        self.rackVIewFrontDiv = self.element("rackVIewFrontDiv")
        self.rackVIewZeroUDiv = self.element("rackVIewZeroUDiv")
        self.dynamicModuleChk = self.element("dynamicModuleChk")
        self.dynamicModuleTypeCbb = self.element("dynamicModuleTypeCbb")
        self.dynamicOrientationCbb = self.element("dynamicOrientationCbb")
        self.portConfigurationCbb = self.element("portConfigurationCbb")
        self.dynamicObjectIcon = self.element("dynamicObjectIcon")
        self.dyanmicServiceChannelCbb = self.element("dyanmicServiceChannelCbb")
        self.propertiesDiv = self.element("propertiesDiv")
        self.appDiv = self.element("appDiv")
        self.mapGraphSvg = self.element("mapGraphSvg")
        self.workOrderHistoryLnk = self.element("workOrderHistoryLnk")
        self.servicesBtn = self.element("servicesBtn")
        self.dynamicMPOPortType = self.element("dynamicMPOPortType")
        self.workOrderForObjectLnk = self.element("workOrderForObjectLnk")
        self.showWorkOnHoldLnk = self.element("showWorkOnHoldLnk")
        self.overrideChoiceDiv = self.element("overrideChoiceDiv")
        self.dynamicCellContentTable = self.element("dynamicCellContentTable")
        self.scaleIndicatorDiv = self.element("scaleIndicatorDiv")
        self.zoomExtentBtn = self.element("zoomExtentBtn")
        self.dynamicSpaceViewSwitcherBtn = self.element("dynamicSpaceViewSwitcherBtn")
        self.dynamicObjectIconWithPort = self.element("dynamicObjectIconWithPort")
        self.mapScaleLineInnerDiv = self.element("mapScaleLineInnerDiv")

    def _wait_for_center_panel_title(self, treeNode, delimiter="/", timeout=Constants.OBJECT_WAIT):
        title = treeNode.split(delimiter)[-1]
        self.centerPanelTitle.wait_until_element_contains(title, timeout)
    
    def _wait_for_center_checkboxes_status(self, status, timeout=Constants.OBJECT_WAIT):
        if status:
            driver.wait_for_condition("return $('#ContentListTbl input[role=checkbox]:checked').length>0", timeout)
        else:
            driver.wait_for_condition("return $('#ContentListTbl input[role=checkbox]:checked').length==0", timeout)
            
    def get_center_checkboxes_status(self, status):  
        if status:
            return driver.execute_javascript("return $('#ContentListTbl input[role=checkbox]:checked').length>0")
        else:
            return driver.execute_javascript("return $('#ContentListTbl input[role=checkbox]:checked').length==0")      

    def check_login_success(self, username): 
        SeleniumAssert.element_attribute_value_should_be(self.usernameLbl, "title", username)

    def close_registration_dialog(self):
        self._wait_for_processing()
        if self.remindlaterBtn.is_element_existed():
            self.remindlaterBtn.click_element()
            self.remindlaterBtn.wait_until_element_is_not_visible()
        self._wait_for_processing()

    def click_tree_node_on_site_manager(self, treeNode, delimiter="/", timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        temp = 0
        while temp <= timeout:
            self.siteTreeDiv.click_tree_node(treeNode, delimiter)
            self._wait_for_center_panel_title(treeNode, delimiter)
            self.centerPanelContentList.wait_for_element_outer_html_not_change()
            if driver.execute_javascript("return $('#ContentListTbl input[role=checkbox]:checked').length==0"):
                break
            temp += 1
        self._wait_for_processing()
    
    def get_table_row_map_with_header_on_content_table(self, headers, values, delimiter=","):
        return self.contentTbl._get_table_row_map_with_header(headers, values, delimiter)
    
    def check_table_row_map_with_header_on_content_table(self, headers, values, expected):
        Assert.should_be_equal_as_integers(self.get_table_row_map_with_header_on_content_table(headers, values), int(expected) + 1)
    
    def click_table_cell_on_content_table(self, row, column):
        self.contentTbl._click_table_cell(row, column)
    
    def wait_for_object_exist_on_content_table(self, objectName, timeOut=Constants.OBJECT_WAIT):
        self.dynamicObjectOnContentTbl.arguments = [objectName]
        self.dynamicObjectOnContentTbl.wait_until_element_is_visible(timeOut)
        
        return self.dynamicObjectOnContentTbl
    
    def wait_for_object_exist_on_content_table_with_refresh(self, objectName=None, timeout=Constants.OBJECT_WAIT):
        self.dynamicObjectOnContentTbl.arguments = [objectName]
        temp = 0
        while(temp <= timeout):
            if self.dynamicObjectOnContentTbl.return_wait_for_element_visible_status(2):
                break
            self.refreshBtn.click_visible_element()
            temp += 2
    
    def select_object_on_content_table(self, objectName):
        self.appDiv.wait_for_element_outer_html_not_change()
        if(objectName != "all"):
            objectCell = self.wait_for_object_exist_on_content_table(objectName)
            objectCell.return_wait_for_element_invisible_status(1)
            objectCell.wait_until_element_is_visible()
            returnRow = self.get_table_row_map_with_header_on_content_table("Name", objectName)
            self.click_table_cell_on_content_table(returnRow, 12)
            if not "highlight" in Element(objectCell.locator() + "/ancestor::tr").get_element_attribute("class"):
                self.click_table_cell_on_content_table(returnRow, 12)
        else:
            self.allChk.click_visible_element()
            count = 0
            while self.get_center_checkboxes_status(False) and count < constants.SELENPY_DEFAULT_TIMEOUT:
                self.allChk.click_visible_element()
                count += 1
        self._wait_for_center_checkboxes_status(True)
    
    def open_trace_window(self, treeNode, endPoint, delimiter="/"):
        self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.select_object_on_content_table(endPoint)
        self.traceBtn.click_visible_element()
    
    def check_trace_object_on_site_manager(self, indexObject, mpoType=None, objectPosition=None, objectPath=None, objectType=None, portIcon=None, connectionType=None, scheduleIcon=None, informationDevice=None):
        self._check_trace_object(self.traceMapDiv, indexObject, mpoType, objectPosition, objectPath, objectType, portIcon, connectionType, scheduleIcon, informationDevice)
                    
    def switch_view_mode_on_trace(self, viewType="Vertical"):
        """Choose the mode(Horizontal or Vertical) that we want to switch."""
        traceMapXpath = self._define_trace_map_xpath(self.traceMapDiv)
        self.dynamicVerticalTraceTbl.arguments = [traceMapXpath]
        isTraceTableExist = self.dynamicVerticalTraceTbl.is_element_existed()
        if((isTraceTableExist == False and viewType == "Vertical") or (isTraceTableExist and viewType == "Horizontal")):
            self.switchTraceViewBtn.click_visible_element()
            
    def select_view_trace_tab_on_site_manager(self, viewTab):
        self._select_view_trace_tab(self.traceMapDiv, viewTab)
        
    def delete_tree_node_on_site_manager(self, treeNode, delimiter="/"):
        self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.click_delete_button()
        '''Handle for Bulk-29529-02-05'''
        temp = 0
        while temp < constants.SELENPY_DEFAULT_TIMEOUT:
            if self.confirmDialogBtn.return_wait_for_element_visible_status():
                break
            else:
                self.click_delete_button()
        temp += 1
        ''''''
        self.confirmDialogBtn.click_element()
        self.confirmDialogBtn.wait_until_page_does_not_contain_element()
        if self.twoChoiceNoDiv.return_wait_for_element_visible_status(2):
            self.twoChoiceNoDiv.click_element()
        self._wait_for_processing()
        treeNodeXpath = self._build_tree_node_xpath(self.siteTreeDiv, treeNode, delimiter)
        Element(treeNodeXpath).wait_until_element_is_not_visible()
    
    def drag_and_drop_object_on_site_tree(self, selectedNode, targetNode, delimiter="/"):
        self.click_tree_node_on_site_manager(selectedNode, delimiter)
        self.click_tree_node_on_site_manager(targetNode, delimiter)
        selectNodeLocator = self._build_tree_node_xpath(self.siteTreeDiv, selectedNode, delimiter)
        targetNodeLocator = self._build_tree_node_xpath(self.siteTreeDiv, targetNode, delimiter)
        selectedNode = Element(selectNodeLocator)
        selectedNode.drag_and_drop(targetNodeLocator)
        selectedNode.wait_until_page_does_not_contain_element()

    def copy_and_paste_object_on_site_tree(self, selectedNode, targetNode, delimiter="/"):
        self.click_tree_node_on_site_manager(selectedNode, delimiter)
        self.copyBtn.click_visible_element()
        self.click_tree_node_on_site_manager(targetNode, delimiter)
        self.pasteBtn.click_visible_element()

    def select_context_menu_on_site_tree(self, contextMenuItem, treeNode, delimiter="/"):
        self._does_tree_node_exist(self.siteTreeDiv, treeNode, delimiter)
        treeNodeItem = Element(self._build_tree_node_xpath(self.siteTreeDiv, treeNode, delimiter))
        treeNodeItem.open_context_menu()
        self.dynamicContextMenuItem.arguments = [contextMenuItem]
        temp = 0
        while self.dynamicContextMenuItem.is_element_existed() and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.dynamicContextMenuItem.click_visible_element()
            temp += 1
        self.dynamicContextMenuItem.wait_until_element_is_not_visible()

    def click_add_button(self):
        self.addBtn.wait_until_element_is_active()
        self.addBtn.click_visible_element()
        temp = 0
        while not self.dialogCancelBtn.return_wait_for_element_visible_status() and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.addBtn.mouse_over()
            self.addBtn.click_element()
            temp += 1
        
    def click_edit_button(self):
        self.editBtn.wait_until_element_is_active()
        self.editBtn.click_visible_element()
        temp = 0
        while not self.dialogCancelBtn.return_wait_for_element_visible_status() and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.editBtn.mouse_over()
            self.editBtn.click_element()
            temp += 1
    
    def click_delete_button(self):
        self.deleteBtn.wait_until_element_is_active()
        self.deleteBtn.click_visible_element()
        
    def click_save_object_button(self):
        """Use keyword to click Save button on Add Object window"""
        self.saveObjectBtn.wait_until_element_is_active()
        self.saveObjectBtn.click_element()
    
    def click_save_add_object_button(self):
        """Use keyword to click Save button after input value on Object Properties window"""
        self.confirmDialogBtn.wait_until_element_is_active()
        self.confirmDialogBtn.click_element()
        self._wait_for_processing()
    
    def select_object_to_add_in_site(self, treeNode, objectType):
        """Use keyword to select object object to add (ex: Building, Campus, City...) and then go to Properties Object page for user to input value
    ...    We have 2 arguments:
    ...    - 'treeNode': 
    ...    - 'objectType': object to add (ex: Building, Campus, City...)"""
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self.select_single_object(objectType)
        self.click_save_object_button()
        
    def _add_object(self, treeNode, objectType, name, description=None):
        self.select_object_to_add_in_site(treeNode, objectType)
        if objectType == "Cable Vault":
            self.cableVaultNameTxt.wait_until_element_is_visible()
            self.cableVaultNameTxt.input_text(name)
        else:
            self.nameTxt.wait_until_element_is_visible()
            self.nameTxt.input_text(name)
        self.descriptionTxt.input_text(description)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
        
    def add_building(self, treeNode, name, description=None):
        return self._add_object(treeNode, "Building", name, description)
        
    def add_cable_vault(self, treeNode, name, description=None):
        return self._add_object(treeNode, "Cable Vault", name, description)

    def add_campus(self, treeNode, name, description=None):
        return self._add_object(treeNode, "Campus", name, description)
        
    def add_city(self, treeNode, name, description=None):
        return self._add_object(treeNode, "City", name, description)
    
    def add_cubicle(self, treeNode, name, zoneMode=None, contact=None, description=None):
        self.select_object_to_add_in_site(treeNode, "Cubicle")
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if zoneMode is not None:
            self.zoneModeCbb.select_from_list_by_label(zoneMode)
        if contact is not None:
            self.contactCbb.select_from_list_by_label(contact)
        self.descriptionTxt.input_text(description)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
    
    def add_floor(self, treeNode, name, contact=None, description=None):
        self.select_object_to_add_in_site(treeNode, "Floor")
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if contact is not None:
            self.contactCbb.select_from_list_by_label(contact)
        self.descriptionTxt.input_text(description)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
    
    def add_faceplate(self, treeNode, name, outletType="RJ-45", maximumOutlet=None, description=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Faceplates", "Faceplate")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if outletType != "RJ-45":
            self.faceplatePortTypeCbb.select_from_list_by_label(outletType)
        if maximumOutlet is not None:
            self.maximumOutletsCbb.select_from_list_by_label(maximumOutlet)
        self.descriptionTxt.input_text(description)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
        
    def add_consolidation_point(self, treeNode, name, consolidationType="(24-Port)", portType="RJ-45", maximumPorts=None, quantity=None):
        """
        Kw use to add consolidation point into Room.
        consolidationType have 4 options: (24-Port), (32-Port), (36-Port), (48-Port)
        """
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Consolidation Point " + consolidationType)
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if portType != "RJ-45":
            self.portTypeCbb.select_from_list_by_label(portType)
        if maximumPorts is not None:
            self.totalPortsTxt.select_from_list_by_label(maximumPorts)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def check_total_trace_on_site_manager(self, totalTrace):
        self._check_total_trace(self.traceMapDiv, totalTrace)
    
    def _select_menu_item_on_toolbar(self, treeNode=None, objectName=None, menu=None, item=None, delimiter="/"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        if objectName is not None:
            self.select_object_on_content_table(objectName)
        temp = 0
        while temp <= constants.SELENPY_DEFAULT_TIMEOUT:
            menu.wait_until_element_is_active()
            menu.mouse_over()
            self.centerPanelContentList.wait_for_element_outer_html_not_change()
            if "disabled" not in item.get_element_attribute("class"):
                break
            menu.mouse_out()
            temp += 1
        item.click_visible_element()
        count = 0
        while item.return_wait_for_element_visible_status() and count < constants.SELENPY_DEFAULT_TIMEOUT:
            item.click_visible_element()
            count += 1
           
    def add_splice_enclosure(self, treeNode, name, position=None, slotCapacity=None, locationInRack=None, rackUnits=None, equipmentImageName=None, confirmSave=True, waitForExist=True):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Splice Enclosures", "Splice Enclosure")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.positionTxt.input_text(position)
        self.rackUnitsTxt.input_text(rackUnits)
        self.slotCapacityTxt.input_text(slotCapacity)
        if locationInRack is not None:
            self.locationInRackCbb.select_from_list_by_label(locationInRack)
        if equipmentImageName is not None:
            self.select_equipment_image(equipmentImageName)
        if confirmSave:
            self.click_save_add_object_button()
        if waitForExist:
            self.wait_for_object_exist_on_content_table(name)
        
    def _open_connections_window(self, connectionType, treeNode=None, objectName=None, delimiter="/"):
        self._select_menu_item_on_toolbar(treeNode, objectName, self.connectionBtn, connectionType, delimiter)
    
    def open_conduits_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.conduitsLnk, treeNode, objectName)
        
    def open_define_equipment_patches_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.defineEquipmentPatchLnk, treeNode, objectName)
    
    def open_events_window (self, eventType="Event Log", treeNode=None, objectName=None, delimiter="/"):
        """eventType = Event Log or Event Log For Object or Priority Event Log"""
        self.dynamicEventsLnk.arguments = [eventType]
        self._select_menu_item_on_toolbar(treeNode, objectName, self.eventBtn, self.dynamicEventsLnk, delimiter)
        
    def open_front_to_back_cabling_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.frontToBackCablingLnk, treeNode, objectName)
        
    def open_osp_cabling_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.ospCablingLnk, treeNode, objectName)
        
    def open_patching_window (self, treeNode=None, objectName=None, delimiter="/"):
        self._open_connections_window(self.patchingLnk, treeNode, objectName, delimiter)
    
    def open_replace_network_equipment_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.replaceNetworkEquipmentLnk, treeNode, objectName)
        
    def open_circuit_provisioning_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.circuitProvisioningLnk, treeNode, objectName)
        
    def open_upgrade_to_ipatch_window (self, treeNode=None, objectName=None):
        self._open_connections_window(self.upgradeToiPatchLnk, treeNode, objectName)
        
    def select_single_object (self, objecttype):
        """" This kw is use for select object when Site Object, Building Object, Floor Object,..."""
        self.dynamicObjectTypeLbl.arguments = [objecttype]
        self.dynamicObjectTypeLbl.click_visible_element()

    def add_mainframe (self, treeNode, name="Mainframe 001", zone=1, position=1):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Mainframe")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.fill_mainframe_info(name, zone, position)
        self.click_save_add_object_button()
        expectedObj = "{0}:{1} {2}".format(zone, position, name)
        self.wait_for_object_exist_on_content_table(expectedObj)
        
    def add_mainframe_object (self, treeNode, objectType, name="Mainframe 001", position=1, quantity=1, portType=None, totalPort=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        if(objectType == "Frame"):
            self._select_object_and_object_type("Frames", "Frame")
        elif(objectType == "Mainframe Cage"):
            self._select_object_and_object_type("Cages", "Mainframe Cage")
        elif(objectType == "Mainframe Cage Card"):
            self._select_object_and_object_type("Cards", "Mainframe Cage Card")
        else:
            self._select_object_and_object_type("Interfaces", "Mainframe Interface")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.fill_mainframe_info(name, position=position)
        if(objectType == "Mainframe Interface"):
            self.portTypeCbb.select_from_list_by_label(portType)
            self.totalPortsTxt.input_text(totalPort)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_managed_switch (self, treeNode, name, ipAddress, ipType="IPv4", updateMneName=True):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Managed Network Equipment")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if ipType == "IPv4":
            self._fill_ipv4(ipAddress)
        self.updateMneNameChk.select_checkbox(updateMneName)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_network_equipment (self, treeNode, name, ipType=None, ipAddress=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Network Equipment")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if ipType == "IPv4":
            self._fill_ipv4(ipAddress)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
        
    def add_network_equipment_port (self, treeNode, name, portType=None, listChannel=None, listServiceType=None, portConfiguration=None, critical=False, notAvailable=False, reserved=False, uplinkPort=False, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Components", "Network Equipment Port")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if (portType is not None):
            self.portTypeCbb.select_from_list_by_label(portType)
        if portConfiguration is not None:
            self.portConfigurationCbb.select_from_list_by_label(portConfiguration)
        if listChannel is not None:
            self._edit_service_for_port(listChannel, listServiceType)
        self.criticalChk.select_checkbox(critical)
        self.notAvailableChk.select_checkbox(notAvailable)
        self.reservedChk.select_checkbox(reserved)
        self.uplinkPortChk.select_checkbox(uplinkPort)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_network_equipment_component (self, treeNode, componentType, name, portType=None, totalPorts=None, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        if (componentType == "Network Equipment Card"):
            self._select_object_and_object_type("Components", "Network Equipment Card")
        else:
            self._select_object_and_object_type("Components", "Network Equipment GBIC Slot")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if (portType is not None):
            self.portTypeCbb.select_from_list_by_label(portType)
        self.totalPortsTxt.input_text(totalPorts)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        if (quantity is not None):
            self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
    
    def add_person (self, treeNode, firstName, lastName):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("People", "Person")
        self.click_save_object_button()
        self.firstNameTxt.wait_until_element_is_visible()
        self.firstNameTxt.input_text(firstName)
        self.lastNameTxt.input_text(lastName)
        self.click_save_add_object_button()
        expectedPerson = "{0}, {1}".format(lastName, firstName)
        self.wait_for_object_exist_on_content_table(expectedPerson)
        
    def add_generic_panel (self, treeNode, name="Panel 01", rackUnits=1, locationInRack="Front", portType="RJ-45", service=None, maximumPorts=None, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Generic Panel")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.rackUnitsTxt.input_text(rackUnits)
        self.locationInRackCbb.select_from_list_by_label(locationInRack)
        self.portTypeCbb.select_from_list_by_label(portType)
        self._edit_service_for_port("Service", service)
        self.totalPortsTxt.input_text(maximumPorts)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
        
    def add_poe_device (self, treeNode, name="PoE 01", rackUnits=None, totalPorts=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "PoE Device")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.rackUnitsTxt.input_text(rackUnits)
        self.totalPortsTxt.input_text(totalPorts)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_device_in_rack (self, treeNode, name, rackUnits=None, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Device in Rack")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.rackUnitsTxt.input_text(rackUnits)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)

    def add_device_in_rack_port (self, treeNode, name, portType=None, critical=False, notAvailable=False, reserved=False, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Components", "Device in Rack Port")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if (portType is not None):
            self.portTypeCbb.select_from_list_by_label(portType)
        self.criticalChk.select_checkbox(critical)
        self.notAvailableChk.select_checkbox(notAvailable)
        self.reservedChk.select_checkbox(reserved)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_device_in_rack_component (self, treeNode, componentType, name, portType=None, totalPorts=None, quantity=None):
        """
        Valid value for componentType: Device in Rack Card, Device in Rack GBIC Slot
        """
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Components", componentType)
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if (portType is not None):
            self.portTypeCbb.select_from_list_by_label(portType)
        self.totalPortsTxt.input_text(totalPorts)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        if (quantity is not None):
            self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_rack (self, treeNode, name, rackType="Rack (7 ft - 45U)", zone=None, position=1, NDD=False, capacityU=None, waitForCreate=True):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Racks / Cabinets", rackType)
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self._fill_rack_info (name, zone, position, NDD, capacityU)
        self.click_save_add_object_button()
        if zone is None:
            zone = 1
        expectedObj = "{0}:{1} {2}".format(zone, position, name)
        if waitForCreate:
            self.wait_for_object_exist_on_content_table(expectedObj)
        return "{0}/{1}:{2} {3}".format(treeNode, zone, position, name)
    
    def go_to_another_view_on_site_manager(self, viewType):
        """Valid values for 'viewType' argument: Contents, Devices, Bundle View, Spaces"""
        self.dynamicViewTypeImg.arguments = [viewType]
        self.dynamicViewTypeImg.click_visible_element()
        self._wait_for_loading_tree()
        
    def toggle_spaces_view_lock_state(self, treeNode=None, state="Unlock"):
        """
        Valid values for 'state' argument: Lock, Unlock
        Default value for 'state' = Unlock
        """
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode)
        
        self.dynamicLockToggleLnk.arguments = [state]
        
        if self.dynamicLockToggleLnk.is_element_existed():
            self.dynamicLockToggleLnk.click_element()        
    
    def place_object_on_space(self, containerTreeNode=None, objectTreeNode=None, position=None, delimiter=","):
        """
       'treeNode' is the tree node to place the object
       'tree_node_object' is the tree node containing object
       'position': is an array the coordinates of destination, contains left and top (left,top) (left must be greater than 5, top must be greater than 5) (ex: [10;10]) 
        """
        self.toggle_spaces_view_lock_state(containerTreeNode)  
        self._does_tree_node_exist(self.siteTreeDiv, objectTreeNode)
        if self.hidePropertiesDiv.is_element_existed():
            self.hidePropertiesDiv.click_visible_element()
        siteTreeObject = Element(self._build_tree_node_xpath(self.siteTreeDiv, objectTreeNode))
        leftHideTree = self.hideTreeDiv.get_horizontal_position()
        topHideTree = self.hideTreeDiv.get_vertical_position()
        heightHideTree = self.hideTreeDiv.get_element_size()[1]
        destination = position.split(delimiter)
        leftDes = leftHideTree + int(destination[0])
        topDes = topHideTree + int(destination[1]) + heightHideTree
        siteTreeObject.drag_and_drop_by_offset(leftDes, topDes)
        
    def synchronize_managed_switch(self, treeNode=None, objectName=None):
        self.click_tree_node_on_site_manager(treeNode)
        if objectName is not None:
            self.select_object_on_content_table(objectName)
        self.dynamicSnmpMenuLnk.arguments = ["Synchronize"]
        self.open_snmp_window(self.dynamicSnmpMenuLnk)
        self.synchronizeYesLnk.click_visible_element()

    def discover_managed_switch(self, treeNode=None, objectName=None):
        self.click_tree_node_on_site_manager(treeNode)
        if objectName is not None:
            self.select_object_on_content_table(objectName)
        self.dynamicSnmpMenuLnk.arguments = ["Discover Devices"]
        self.open_snmp_window(self.dynamicSnmpMenuLnk)
        self.synchronizeYesLnk.click_visible_element()

    def open_synchronize_status_window(self):
        self.dynamicSnmpMenuLnk.arguments = ["SNMP Status"]
        self.open_snmp_window(self.dynamicSnmpMenuLnk)

    def _fill_ipv4 (self, ipAddress):
        subIp = ipAddress.split(".")
        tempCount = 1
        for sub in subIp:
            self.dynamicIpV4Txt.arguments = [tempCount]
            self.dynamicIpV4Txt.click_element()
            self.dynamicIpV4Txt.input_text(sub)
            tempCount = tempCount + 1
    
    def edit_port_on_content_table (self, treeNode, name, newName=None, portType=None, uplinkPort=None, critical=None, notAvailable=None, reserved=None, staticRear=None, staticFront=None, static=None, connectionId=None, serviceTicketId=None, cordLength=None, cordType=None, cordColor=None, portField1=None, portField2=None, portField3=None, portField4=None, portField5=None, delimiterTree="/", listChannel=None, listServiceType=None, delimiter=","):
        self.click_tree_node_on_site_manager(treeNode, delimiterTree)
        node = treeNode.split(delimiterTree)[-1]
        self.dynamicPropertyValue.arguments = ["Module Type"]
        moduleTypeExisted = self.dynamicPropertyValue.is_element_visible()
        if moduleTypeExisted:
            startPoint = node.index("(")
            endPoint = node.index(")")
            moduleType = node[startPoint+1:endPoint]
            self.wait_for_property_on_properties_pane("Module Type", moduleType)
            self.wait_for_property_on_properties_pane("Name", node[0:startPoint-1])
        else:
            self.wait_for_property_on_properties_pane("Name", node)
        self.select_object_on_content_table(name)
        self._wait_for_processing()
        self.click_edit_button()
        self._wait_for_processing()
        self.criticalChk.wait_until_element_is_visible()
        if newName is not None:
            self.nameTxt.input_text(newName)
        if (portType is not None):
            self.portTypeCbb.select_from_list_by_label(portType)
        if uplinkPort is not None:
            self.uplinkPortChk.select_checkbox(uplinkPort)
        if critical is not None:
            self.criticalChk.select_checkbox(critical)
        if notAvailable is not None:
            self.notAvailableChk.select_checkbox(notAvailable)
        if reserved is not None:
            self.reservedChk.select_checkbox(reserved)
        if staticRear is not None:
            self.staticRearChk.select_checkbox(staticRear)
        if staticFront is not None:
            self.staticFrontChk.select_checkbox(staticFront)
        if static is not None:
            self.staticChk.select_checkbox(static)
        
        # Port Fields section
        self.connectionIdTxt.input_text(connectionId)
        self.serviceTicketIdTxt.input_text(serviceTicketId)
        self.cordLengthTxt.input_text(cordLength)
        self.cordTypeTxt.input_text(cordType)
        self.cordColorTxt.input_text(cordColor)
        self.portField1Txt.input_text(portField1)
        self.portField2Txt.input_text(portField2)
        self.portField3Txt.input_text(portField3)
        self.portField4Txt.input_text(portField4)
        self.portField5Txt.input_text(portField5)   
        
        #Edit Services
        self._edit_service_for_port(listChannel, listServiceType, delimiter)
        
        self.click_save_add_object_button()
        self.confirmDialogBtn.wait_until_element_is_not_visible()
        self._wait_for_processing()
        if name == "all":
            self._wait_for_center_checkboxes_status(False)
    
    def does_tree_node_exist_on_site_manager (self, treeNode, delimiter="/"):
        return self.siteTreeDiv.does_tree_node_exist(treeNode, delimiter)
#         return self._does_tree_node_exist(self.siteTreeDiv, treeNode, delimiter)
        
    def cut_and_paste_object_on_site_tree (self, sourceTreeNode, destinationTreeNode):
        self.click_tree_node_on_site_manager(sourceTreeNode)
        self.cutBtn.click_element()
        self._wait_for_processing()
        self.click_tree_node_on_site_manager(destinationTreeNode)
        self.pasteBtn.click_element()
        self._wait_for_processing()
    
    def check_cable_vaults_filter_icon(self, icon):
        SeleniumAssert.element_attribute_value_should_contain(self.cableVaultBtn, "src", icon)
        
    def check_cable_vaults_filter_icon_tooltip(self, tooltip):
        SeleniumAssert.element_attribute_value_should_be(self.cableVaultBtn, "title", tooltip)
        
    def check_icon_object_on_site_tree(self, treeNode, icon, delimiter="/"):
        self.does_tree_node_exist_on_site_manager(treeNode)
        nodeXpath = self._build_tree_node_xpath(self.siteTreeDiv, treeNode, delimiter)
        self._wait_for_processing()
        self.treeObjectIcon.arguments = [nodeXpath, icon]
        SeleniumAssert.element_should_be_visible(self.treeObjectIcon)
        
    def check_object_exist_on_content_table(self, treeNode=None, objectName=None, delimiter="/"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.tableObjectNameLbl.arguments = [objectName]
        SeleniumAssert.element_should_be_visible(self.tableObjectNameLbl)
    
    def check_multi_objects_exist_on_content_table(self, treeNode=None, objectNames=None, delimiter="/"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        for objectName in objectNames:
            self.tableObjectNameLbl.arguments = [objectName]
            SeleniumAssert.element_should_be_visible(self.tableObjectNameLbl)
                 
    def check_object_not_exist_on_content_table(self, treeNode=None, objectName=None, delimiter="/"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.tableObjectNameLbl.arguments = [objectName]
        SeleniumAssert.element_should_not_be_visible(self.tableObjectNameLbl) 
    
    def check_multi_objects_not_exist_on_content_table(self, treeNode=None, objectNames=None, delimiter="/"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        for objectName in objectNames:
            self.tableObjectNameLbl.arguments = [objectName]
            SeleniumAssert.element_should_not_be_visible(self.tableObjectNameLbl) 
            
    def check_tree_node_exist_on_site_manager(self, treeNode, delimiter="/"):
        treeNodeExist = self.does_tree_node_exist_on_site_manager(treeNode, delimiter)
        Assert.should_be_true(treeNodeExist, treeNode + " does not exist")
    
    def check_multi_tree_nodes_exist_on_site_manager(self, treeNodes, delimiter="/"):
        for treeNode in treeNodes:
            self.check_tree_node_exist_on_site_manager(treeNode, delimiter)
    
    def check_tree_node_not_exist_on_site_manager(self, treeNode, delimiter="/"):
        treeNodeExist = self.does_tree_node_exist_on_site_manager(treeNode, delimiter)
        Assert.should_be_true(treeNodeExist == False, treeNode + " exists")  
    
    def check_multi_tree_nodes_not_exist_on_site_manager(self, treeNodes, delimiter="/"):
        for treeNode in treeNodes:
            self.check_tree_node_not_exist_on_site_manager(treeNode, delimiter)
            
    def close_trace_window(self):
        self.cancelTraceBtn.click_visible_element()
        self.cancelTraceBtn.wait_until_element_is_not_visible()
        
    def check_popup_error_message(self, text, acceptPopup=None):
        errMsgText = self.popupErrorMsg.get_text()
        Assert.should_be_equal_as_strings(text, errMsgText)
        if acceptPopup is not None:
            self.confirmSavePopupBtn.click_visible_element()
            self.confirmSavePopupBtn.wait_until_element_is_not_visible()
        
    def check_icon_object_on_spaces_tab(self, treeNode, spaceObject, iconImage):
        self.objectSpaceviewIcon.arguments = [spaceObject]
        self.iconImageObject.arguments = [os.environ['system'], iconImage]
        self.click_tree_node_on_site_manager(treeNode)
        if self.labelHideBtn.is_element_existed():
            self.labelBtn.click_visible_element()
        self.objectSpaceviewIcon.wait_until_element_is_visible()
        SeleniumAssert.element_attribute_value_should_be(self.objectSpaceviewIcon, "xlink:href", self.iconImageObject.locator())
        
    def check_object_exist_on_spaces_view(self, treeNode=None, spaceObject=None):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode)
        if self.labelHideBtn.is_element_existed():
            self.labelBtn.click_visible_element()
        self.dynamicObjectSpaceviewLabel.arguments = [spaceObject]
        SeleniumAssert.element_should_be_visible(self.dynamicObjectSpaceviewLabel)
    
    def check_multi_objects_exist_on_spaces_view(self, treeNode=None, spaceObjects=None):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode)
        if self.labelHideBtn.is_element_existed():
            self.labelBtn.click_visible_element()
        for spaceObject in spaceObjects:
            self.dynamicObjectSpaceviewLabel.arguments = [spaceObject]
            SeleniumAssert.element_should_be_visible(self.dynamicObjectSpaceviewLabel)
            
    def check_object_not_exist_on_spaces_view(self, treeNode=None, spaceObject=None):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode)        
        if self.labelHideBtn.is_element_existed():
            self.labelBtn.click_visible_element()
        self.dynamicObjectSpaceviewLabel.arguments = [spaceObject]
        SeleniumAssert.element_should_not_be_visible(self.dynamicObjectSpaceviewLabel)
            
    def check_multi_objects_not_exist_on_spaces_view(self, treeNode=None, spaceObjects=None):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode)        
        if self.labelHideBtn.is_element_existed():
            self.labelBtn.click_visible_element()
        for spaceObject in spaceObjects:
            self.dynamicObjectSpaceviewLabel.arguments = [spaceObject]
            SeleniumAssert.element_should_not_be_visible(self.dynamicObjectSpaceviewLabel)
                
    def switch_geomap_view(self, view):
        """ view = Satellite or Map"""
        self.dynamicSpaceViewSwitcherBtn.arguments = [view]
        self.dynamicSpaceViewSwitcherBtn.click_element_if_exist()
        self.dynamicSpaceViewSwitcherBtn.wait_until_element_is_not_visible()
                        
    def show_tree(self, show=True):
        if show:
            self.showTreeBtn.click_visible_element()
            self.hideTreeBtn.wait_until_element_is_visible()
        else:
            self.hideTreeBtn.click_visible_element()
            self.showTreeBtn.wait_until_element_is_visible()

    def assign_layer_image_to_object(self, treeNode, imageName=None, confirmBlank=False, lockState="Unlock"):
        """
       'treeNode' is the tree node to place the object
       'imageName' is the selected image label in the combo box
       'confirmBlank': valid value is True or False
       'finalLock': the state for toggle spaces view lock
        """
        self.toggle_spaces_view_lock_state(treeNode)
        self.imageLayerCbb.select_from_list_by_label(imageName)
        if confirmBlank is not False:
            self.confirmDialogBtn.click_visible_element()
        self.toggle_spaces_view_lock_state(state=lockState)
        
    def zoom_map(self, zoomMode, zoomTimes):
        """
       'zoomMode': valid values are "in" or "out"
       'zoomTimes' number of mouse click for zooming
        """
        self.dynamicZoomMapBtn.arguments = [zoomMode]
        i = 0
        self.dynamicZoomMapBtn.wait_until_page_contains_element()
        while i < int(zoomTimes):
            self.dynamicZoomMapBtn.click_visible_element()
            self.mapGraphSvg.wait_for_element_outer_html_not_change()
            i += 1
        
    def open_snmp_window(self, snmpType, treeNode=None, objectName=None): 
        """ To open sub-window under SNMP menu item """ 
        self._select_menu_item_on_toolbar(treeNode, objectName, self.snmpLnk, snmpType) 
        
    def _fill_rack_info(self, name, zone=None, position=None, NDD=False, capacityU=None):
        self.nameTxt.input_text(name)
        if zone is not None:
            self.zoneCbb.select_from_list_by_label(zone)
        self.positionTxt.input_text(position)
        self.nddChk.select_checkbox(NDD)
        self.slotCapacityTxt.input_text(capacityU)
    
    def _select_object_and_object_type(self, roomObject, objectType):
        """
       'roomObject': e.g Racks / Cabinets
       'objectType' e.g Rack (7 ft - 45U)
        """
        self.dynamicObjectlbl.arguments = [roomObject]
        self.dynamicObjectTypeLbl.arguments = [objectType]
        if not self.dynamicObjectTypeLbl.is_element_existed():
            self.dynamicObjectlbl.wait_until_element_is_visible()
            self.dynamicObjectlbl.click_visible_element()
            self.dynamicObjectTypeLbl.wait_until_element_is_visible()
        self.dynamicObjectTypeLbl.click_visible_element()
        
    def add_device (self, treeNode, deviceType, name, assignToUser=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Devices", deviceType)
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if (assignToUser is not None):
            self.dynamicAssignUser.arguments = [assignToUser]
            self.assignBtn.click_element()
            self.dynamicAssignUser.wait_until_element_is_visible()
            self.dynamicAssignUser.click_element()
            self.assignSaveBtn.click_element()
            self.assignUserTable.wait_until_element_is_not_visible()
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
    
    def add_room (self, treeNode, name, zoneMode=None):
        self.select_object_to_add_in_site(treeNode, "Room")
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if zoneMode is not None:
            self.zoneModeCbb.select_from_list_by_label(zoneMode)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        return treeNode + "/" + name
        
    def create_object (self, treeNode="Site", buildingName=None, floorName=None, roomName=None, rackName=None, NDD=False, zoneMode=None):
        self.click_tree_node_on_site_manager(treeNode)
        if (buildingName is not None):
            self.add_building(treeNode, buildingName)
        if (floorName is not None):
            self.add_floor(treeNode + "/" + buildingName, floorName)
        if (roomName is not None):
            self.add_room(treeNode + "/" + buildingName + "/" + floorName, roomName, zoneMode)
        if (rackName is not None):
            self.add_rack(treeNode + "/" + buildingName + "/" + floorName + "/" + roomName, rackName, NDD=NDD)
    
    def wait_for_port_color_on_content_table(self, objectName, color, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        self.dynamicObjectOnContentTbl.arguments = [objectName]
        self.dynamicPortColor.arguments = [self.dynamicObjectOnContentTbl.locator(), color]
        temp = 0
        while temp <= timeout:
            if self.dynamicPortColor.return_wait_for_element_visible_status(2):
                break
            self.refreshBtn.click_element()
            temp += 2
            
    def check_switch_port_color_on_content_table (self, objectName, color):
        self.dynamicObjectOnContentTbl.arguments = [objectName]
        self.dynamicPortColor.arguments = [self.dynamicObjectOnContentTbl.locator(), color]
        SeleniumAssert.element_should_be_visible(self.dynamicPortColor)
            
    def open_cabling_window (self, treeNode=None, objectName=None, delimiter="/"):
        self._open_connections_window(self.cablingLnk, treeNode, objectName, delimiter)

    def open_unmanaged_quareo_connections_window(self, treeNode=None, objectName=None):
        self._open_connections_window(self.quareoUnmanagedConnectionsLnk, treeNode, objectName)
    
    def open_remove_circuit_window (self, treeNode=None, objectName=None):
        self.dynamicEventsLnk.arguments = ["Remove Circuit"]
        self._open_connections_window(self.dynamicEventsLnk, treeNode, objectName)
    
    def check_trace_table_exist_on_site_manager(self):
        defineTraceMapDialog = self._define_trace_map_xpath(self.traceMapDiv)
        self.dynamicVerticalTraceTbl.arguments = [defineTraceMapDialog]
        self.dynamicVerticalTraceTbl.wait_until_element_is_visible()
        SeleniumAssert.element_should_be_visible(self.dynamicVerticalTraceTbl)
        
    def delete_tree_node_if_exist_on_site_manager(self, treeNode, delimiter="/"):
        isExist = self.does_tree_node_exist_on_site_manager(treeNode, delimiter)
        if isExist:
            self.delete_tree_node_on_site_manager(treeNode, delimiter)
    
    def click_filter_button_on_left_tree_site_manager(self, buttonName):
        """ buttonName = cableVault, faceplate, rack, person, devices""" 
        self.dynamicLeftTreeFilterBtn.arguments = [buttonName]
        self.dynamicLeftTreeFilterBtn.click_visible_element()
        self.dynamicLeftTreeFilterBtn.wait_until_element_is_visible()
        
    def check_map_zoomable(self, zoomMode, numberOfZoom):
        orgValue = self.mapScaleLineInnerDiv.get_element_size()[0]
        temp = 0
        while temp < int(numberOfZoom):
            self.zoom_map(zoomMode, 1)
            curValue = self.mapScaleLineInnerDiv.get_element_size()[0]
            Assert.should_not_be_equal_as_strings(curValue, orgValue)
            orgValue = curValue
            temp += 1
            
    def check_map_unzoomable(self, zoomMode, numberOfZoom):
        orgValue = self._get_element_js_property(self.mapGraph, "style.left")
        temp = 0
        while temp < int(numberOfZoom):
            self.zoom_map(zoomMode, 1)
            curValue = self._get_element_js_property(self.mapGraph, "style.left")
            Assert.should_be_equal_as_strings(curValue, orgValue)
            orgValue = curValue
            temp += 1
            
    def check_map_div_display(self):
        self.mapDiv.wait_until_element_is_visible()
        self.mapDiv.wait_for_element_outer_html_not_change() 
        SeleniumAssert.element_should_be_visible(self.mapDiv)
        
    def check_maptiler_link_display(self):
        self.mapTilerLnk.wait_until_page_contains_element()
        SeleniumAssert.element_should_be_visible(self.mapTilerLnk)
        
    def check_openstreetmap_link_display(self):
        self.openStreetMapLnk.wait_until_page_contains_element()
        SeleniumAssert.element_should_be_visible(self.openStreetMapLnk)
        
    def check_map_view_button_display(self):
        self.dynamicSpaceViewSwitcherBtn.arguments = ["Map"]
        self.dynamicSpaceViewSwitcherBtn.wait_until_element_is_visible()
        SeleniumAssert.element_should_be_visible(self.dynamicSpaceViewSwitcherBtn)
        
    def check_satellite_view_button_display(self):
        self.dynamicSpaceViewSwitcherBtn.arguments = ["Satellite"]
        self.dynamicSpaceViewSwitcherBtn.wait_until_element_is_visible()
        SeleniumAssert.element_should_be_visible(self.dynamicSpaceViewSwitcherBtn)
        
    def get_satellite_view_button_horizontal_position(self):
        self.dynamicSpaceViewSwitcherBtn.arguments = ["Satellite"]
        return self.dynamicSpaceViewSwitcherBtn.get_horizontal_position()
    
    def get_map_view_button_horizontal_position(self):
        self.dynamicSpaceViewSwitcherBtn.arguments = ["Map"]
        return self.dynamicSpaceViewSwitcherBtn.get_horizontal_position()
    
    def fill_mainframe_info(self, name=None, zone=None, position=1):
        self.nameTxt.input_text(name)
        if zone is not None:
            self.zoneCbb.select_from_list_by_label(zone)
        self.positionTxt.input_text(position)        
        
    def check_google_link_display(self):
        self.googleLnk.wait_until_page_contains_element()
        SeleniumAssert.element_should_be_visible(self.googleLnk)
        
    def check_googleguidelines_link_display(self):
        self.googleGuidelinesLnk.wait_until_page_contains_element()
        SeleniumAssert.element_should_be_visible(self.googleGuidelinesLnk)
        
    def click_google_link(self):
        self.googleLnk.wait_until_page_contains_element()
        self.googleLnk.click_visible_element()
        
    def click_googleguidelines_link(self):
        self.googleGuidelinesLnk.wait_until_page_contains_element()
        self.googleGuidelinesLnk.click_visible_element()
        
    def uplink_button_should_be_visible_on_trace_of_site_manager(self):
        SeleniumAssert.element_should_be_visible(self.showHideUplinkBtn)

    def uplink_button_should_not_be_visible_on_trace_of_site_manager(self):
        SeleniumAssert.element_should_not_be_visible(self.showHideUplinkBtn)

    def uplink_tab_should_be_visible_on_trace_of_site_manager(self):
        SeleniumAssert.element_should_be_visible(self.uplinkTab)

    def uplink_tab_should_not_be_visible_on_trace_of_site_manager(self):
        SeleniumAssert.element_should_not_be_visible(self.uplinkTab)

    def click_uplink_button_on_site_manager(self):
        self.showHideUplinkBtn.click_visible_element()

    def add_media_converter(self, treeNode, name, rackUnits=None, fiberType="LC", totalPorts=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Media Converter")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if rackUnits is not None:
            self.rackUnitsTxt.input_text(rackUnits)
        if totalPorts is not None:
            self.totalPortsTxt.input_text(totalPorts)
        if fiberType != "LC":
            self.portTypeCbb.select_from_list_by_label(fiberType)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_splice_tray(self, treeNode, name, position=None, spliceType=None, totalSplices=None, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Trays", "Splice Tray")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if position is not None:
            self.positionTxt.input_text(position)
        if spliceType is not None:    
            self.spliceTypeCbb.select_from_list_by_label(spliceType)
        if totalSplices is not None: 
            self.totalSplicesTxt.input_text(totalSplices)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        if quantity is not None: 
            self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
    
    def open_circuit_history (self, treeNode=None, objectName=None):
        self._select_menu_item_on_toolbar(treeNode, objectName, self.historyBtn, self.circuitHistoryLnk)
        
    def select_view_type_on_trace(self, viewType=None):
        if viewType is not None:
            traceMapXpath = self._define_trace_map_xpath(self.traceMapDiv)
            self.viewTypeTraceCbb.arguments = [traceMapXpath]
            self.viewTypeTraceCbb.wait_until_element_is_visible()
            self.viewTypeTraceCbb.select_from_list_by_label(viewType)
            
    def _build_property_xpath(self, attribute):
        self.dynamicPropertyValue.arguments = [attribute]
        return self.dynamicPropertyValue
     
    def _get_value_property_on_properties_pane(self,attribute):
        self.propertiesDiv.wait_for_element_outer_html_not_change()
        observedText = self._build_property_xpath(attribute).get_text()
        observedText.replace(u'\xa0', " ")
        
        return observedText
        
    def wait_for_property_on_properties_pane(self, attribute, value, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            text = self._get_value_property_on_properties_pane(attribute)
            if str(value) == str(text): 
                break;
            self.refreshBtn.click_element()
            
    def check_object_properties_on_properties_pane(self, attributes=None, values=None, delimiter=","):
        listAttribute = attributes.split(delimiter)
        listValue = values.split(delimiter)
        temp = 0
        for attribute in listAttribute:
            observedText = self._get_value_property_on_properties_pane(attribute)
            Assert.should_be_equal(observedText, listValue[temp])
            temp += 1
        
    def add_rack_group (self, treeNode, name):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Locations", "Rack Group")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_blade_enclosure(self, treeNode, name, rackUnits="1", quantity="1"):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Blade Enclosure")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.rackUnitsTxt.input_text(rackUnits)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_blade_server(self, treeNode, name, deviceInRackType="Device in Rack"):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Equipment", "Blade Server")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.deviceInRackTypeCbb.select_from_list_by_label(deviceInRackType)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        
    def add_blade_server_port (self, treeNode, name, portType=None, critical=False, notAvailable=False, reserved=False, quantity=None):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type("Components", "Blade Server Port")
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        if (portType is not None):
            self.portTypeCbb.select_from_list_by_label(portType)
        self.criticalChk.select_checkbox(critical)
        self.notAvailableChk.select_checkbox(notAvailable)
        self.reservedChk.select_checkbox(reserved)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)
        
    def check_tree_node_selected_on_site_manager(self, treeNode, delimiter="/"):
        self._check_tree_node_selected(self.siteTreeDiv, treeNode, delimiter)
        
    def check_table_row_map_with_header_checkbox_selected_on_content_table(self, headers, values, delimiter=","):
        self.wait_for_object_exist_on_content_table(values)
        self.contentTbl._check_table_row_map_with_header_checkbox_selected(headers, values, delimiter)
        
    def add_quareo(self, treeNode, quareoType, name, ipAddress, delimiter="/"):
        listNode = treeNode.split(delimiter)
        qDFNode = listNode[0] + delimiter + "Quareo Discovery Folder"
        driver.reload_page()
        if self.does_tree_node_exist_on_site_manager(qDFNode, delimiter):
            self.delete_tree_node_on_site_manager(qDFNode, delimiter)
        self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.click_add_button()
        self._select_object_and_object_type("AMPTRAC & Quareo Equipment", quareoType)
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self._fill_ipv4(ipAddress)
        self.click_save_add_object_button()
        self.wait_for_object_exist_on_content_table(name)
        
    def remove_cabling_by_context_menu_on_site_tree(self, treeNode, delimiter="/"):
        self.select_context_menu_on_site_tree("Remove Cabling", treeNode, delimiter)
        self._accept_context_menu()
        
    def synchronize_by_context_menu_on_site_tree(self, treeNode, delimiter="/"):
        self.select_context_menu_on_site_tree("Synchronize", treeNode, delimiter)
        self._wait_for_processing()
        self.contextMenuSyncYesLnk.click_element_if_exist()
        self.contextMenuSyncYesLnk.wait_until_element_is_not_visible()
        self._wait_for_processing()
        
    def does_priority_event_icon_object_exist_on_content_pane(self, treeNode=None, objectName=None, delimiter="/"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.wait_for_object_exist_on_content_table(objectName)
        self.dynamicPriorityEventIcon.arguments = [objectName]
        
        return self.dynamicPriorityEventIcon.is_element_existed()
    
    def check_priority_event_icon_object_not_exist_on_content_pane(self, treeNode, objectName, delimiter="/"):
        Assert.should_not_be_true(self.does_priority_event_icon_object_exist_on_content_pane(treeNode, objectName, delimiter))
        
    def check_priority_event_icon_object_on_content_pane(self, treeNode, objectName, delimiter="/", timeOut=Constants.OBJECT_WAIT_PROBE):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.dynamicObjectOnContentTbl.arguments = [objectName]
        temp = 0
        while self.dynamicObjectOnContentTbl.is_element_existed() and temp < timeOut:
            if self.dynamicObjectOnContentTbl.return_wait_for_element_visible_status(1):
                state = True
                break
            else:
                state = False
                self.refreshBtn.click_visible_element()
            temp += 1
        Assert.should_be_true(state)   
    
    def open_work_order_queue_window(self):
        self._select_menu_item_on_toolbar(None, None, self.workOrdersBtn, self.workOrderQueueLnk)
    
    def sort_content_table_by_column(self, column, typeSort="asc"):
        self.contentTbl._sort_column_by_name(column, typeSort)
    
    def delete_object_on_content_table(self, treeNode=None, objectName="all"):
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode)
        self.select_object_on_content_table(objectName)
        self._wait_for_processing()
        self.click_delete_button()
        self.confirmDialogBtn.click_visible_element()
        self.confirmDialogBtn.wait_until_element_is_not_visible()
        if self.dialogNoBtn.return_wait_for_element_visible_status(2):
            self.dialogNoBtn.click_element()
            self.dialogNoBtn.wait_until_element_is_not_visible()
        self._wait_for_processing()
        
    def select_equipment_image(self, equipmentName):
        self.selectImageBtn.click_visible_element()
        self.selectImageCbb.wait_until_element_is_visible()
        self.selectImageCbb.select_from_list_by_label(equipmentName)
        self.confirmPopupBtn.click_element()
        
    def edit_splice_enclosure(self, treeNode, name=None, position=None, locationInRack=None, slotCapacity=None, rackUnits=None, equipmentImageName=None, confirmSave=True):
        self.click_tree_node_on_site_manager(treeNode)
        self.click_edit_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.rackUnitsTxt.input_text(rackUnits)
        self.positionTxt.input_text(position)
        if locationInRack is not None:
            self.locationInRackCbb.select_from_list_by_label(locationInRack)
        self.slotCapacityTxt.input_text(slotCapacity)
        if equipmentImageName is not None:
            self.select_equipment_image(equipmentImageName)
        if confirmSave:
            self.click_save_add_object_button()
            self._wait_for_processing()
            
    def check_equipment_image_exist_on_properties_window(self, imageFileName):
        self.dynamicPropertiesEquipmentImage.arguments = [imageFileName]
        SeleniumAssert.element_should_be_visible(self.dynamicPropertiesEquipmentImage)
        
    def check_image_exist_on_rack_view(self, objectName, objectImage, rackViewType="Front"):
        if rackViewType == "Front":
            self.rackVIewFrontDiv.wait_until_element_is_visible()
            self.dynamicEquipmentImageRackViewFront.arguments = [objectName, objectImage]
            SeleniumAssert.element_should_be_visible(self.dynamicEquipmentImageRackViewFront)
        else:
            self.rackVIewZeroUDiv.wait_until_element_is_visible()
            self.dynamicEquipmentImageRackViewZeroU.arguments = [objectName, objectImage]
            SeleniumAssert.element_should_be_visible(self.dynamicEquipmentImageRackViewZeroU)
            
    def uplink_button_should_be_enabled_on_trace_of_site_manager(self):
        SeleniumAssert.element_should_be_enabled(self.showHideUplinkBtn)
        
    def uplink_button_should_be_disabled_on_trace_of_site_manager(self):
        SeleniumAssert.element_should_be_disabled(self.showHideUplinkBtn)
    
    def _edit_systimax_equipment_module_info(self, multiModule, delimiter=";"):
        """multiModule user can input listMoodule need to edit. Example: Module 1A,True,LC 12 Port,DM 08; Module 1B..."""
        listMultiModule = multiModule.split(delimiter)
        for listModule in listMultiModule:
            listModuleObject = listModule.split(",")
            self.dynamicModuleChk.arguments = [listModuleObject[0]]
            if listModuleObject[1] != "False":
                self.dynamicModuleChk.select_checkbox(True)
                self.dynamicModuleTypeCbb.arguments = [listModuleObject[0]]
                self.dynamicModuleTypeCbb.select_from_list_by_label(listModuleObject[2])
                if listModuleObject[3] != "":
                    self.dynamicOrientationCbb.arguments = [listModuleObject[0]]
                    self.dynamicOrientationCbb.select_from_list_by_label(listModuleObject[3])
            else:
                self.dynamicModuleChk.select_checkbox(False)
        
    def add_systimax_fiber_equipment(self, treeNode, systimaxEquipmentType, name, multiModule, quantity=None):
        """multiModule user can input listMoodule need to edit. Example: Module 1A,True,LC 12 Port,DM 08; Module 1B..."""
        self._add_fiber_equipment(treeNode, "SYSTIMAX Fiber Equipment", systimaxEquipmentType, name, multiModule, quantity)
        
    def does_icon_object_exist_on_content_pane(self, objectName, icon, treeNode=None, delimiter="/"):                        
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.wait_for_object_exist_on_content_table(objectName)                           
        self.dynamicObjectIconWithPort.arguments = [objectName, icon]
        return self.dynamicObjectIconWithPort.is_element_existed()
    
    def check_icon_object_not_exist_on_content_pane(self, objectName, icon, treeNode=None, delimiter="/"):        
        Assert.should_not_be_true(self.does_icon_object_exist_on_content_pane(objectName, icon, treeNode, delimiter), "The icon " + icon + " exists on the object " + objectName)
        
    def check_icon_object_exist_on_content_pane(self, objectName, icon, treeNode=None, delimiter="/"):        
        Assert.should_be_true(self.does_icon_object_exist_on_content_pane(objectName, icon, treeNode, delimiter), "The icon " + icon + " does not exist on the object " + objectName) 

    def _edit_service_for_port(self, listChannel, listServiceType=None, delimiter=","):
        if listServiceType is not None:
            arrayChannel = listChannel.split(delimiter)
            arrayServiceType = listServiceType.split(delimiter)
            if len(arrayChannel) == len(arrayServiceType):
                for i in range(len(arrayChannel)):
                    self.dyanmicServiceChannelCbb.arguments = [arrayChannel[i]]
                    self.dyanmicServiceChannelCbb.select_from_list_by_label(arrayServiceType[i])

    def add_ipatch_fiber_equipment(self, treeNode, iPatchEquipmentType, name, multiModule, quantity=None):
        """multiModule user can input listMoodule need to edit. Example: Module 1A,True,LC 12 Port,DM 08; Module 1B..."""
        self._add_fiber_equipment(treeNode, "iPatch Fiber Equipment", iPatchEquipmentType, name, multiModule, quantity)
        
    def _add_fiber_equipment(self, treeNode, fiberType, equipmentType, name, multiModule, quantity=None):
        """fiberType: iPatch Fiber Equipment or SYSTIMAX Fiber Equipment
        multiModule user can input listMoodule need to edit. Example: Module 1A,True,LC 12 Port,DM 08; Module 1B..."""
        self.click_tree_node_on_site_manager(treeNode)
        self.click_add_button()
        self._select_object_and_object_type(fiberType, equipmentType)
        self.click_save_object_button()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self._edit_systimax_equipment_module_info(multiModule)
        self.click_save_add_object_button()
        self.quantityTxt.wait_until_element_is_visible()
        self.quantityTxt.input_text(quantity)
        self.objectToAddOkBtn.click_element()
        self.wait_for_object_exist_on_content_table(name)

    def open_work_order_history_window(self):
        self._select_menu_item_on_toolbar(None, None, self.workOrdersBtn, self.workOrderHistoryLnk)
        
    def open_services_window(self, serviceType="Provide Service", treeNode=None, objectName=None, delimiter="/"):
        """serviceType = Provide Service, Change Service, Move Services, Provide Services for Server, Deploy Servers, Decommission Server"""
        self.dynamicEventsLnk.arguments = [serviceType]
        self._select_menu_item_on_toolbar(treeNode, objectName, self.servicesBtn, self.dynamicEventsLnk, delimiter)

    def does_icon_mpo_port_type_exist_on_content_pane(self, objectName, mpoPortType, treeNode=None, delimiter="/"):                        
        if treeNode is not None:
            self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.wait_for_object_exist_on_content_table(objectName)                           
        self.dynamicMPOPortType.arguments = [objectName, mpoPortType]
        return self.dynamicMPOPortType.is_element_existed()

    def check_icon_mpo_port_type_exist_on_content_pane(self, objectName, mpoPortType, treeNode=None, delimiter="/"):        
        Assert.should_be_true(self.does_icon_mpo_port_type_exist_on_content_pane(objectName, mpoPortType, treeNode, delimiter), "The MPOPortType " + mpoPortType + " does not exist on the object " + objectName) 

    def open_work_order_for_object_window(self, treeNode, objectName):
        self.click_tree_node_on_site_manager(treeNode)
        self.select_object_on_content_table(objectName)
        self._select_menu_item_on_toolbar(None, None, self.workOrdersBtn, self.workOrderForObjectLnk)
    
    def open_work_on_hold_window(self):
        self._select_menu_item_on_toolbar(None, None, self.workOrdersBtn, self.showWorkOnHoldLnk)
        
    def check_work_orders_on_hold_icon_on_site_manager(self, color):
        observedClass = self.workOrdersBtn.get_element_attribute("class")
        if color == "red":
            Assert.should_be_true("workorder_hold" in observedClass)
        else:
            Assert.should_be_true(not "workorder_hold" in observedClass)
    
    def remove_cabling_by_context_menu_on_content_pane(self, treeNode, objectName, delimiter="/"):
        self.click_tree_node_on_site_manager(treeNode, delimiter)
        self.wait_for_object_exist_on_content_table(objectName)
        self.dynamicObjectOnContentTbl.arguments=[objectName]
        self.dynamicObjectOnContentTbl.open_context_menu()
        self.dynamicContextMenuItem.arguments = ["Remove Cabling"]
        self.dynamicContextMenuItem.click_visible_element()
        self.dynamicContextMenuItem.wait_until_element_is_not_visible()
        self._accept_context_menu()
        
    def _accept_context_menu(self):
        self.twoChoiceYesDiv.click_element_if_exist()
        self.twoChoiceYesDiv.wait_until_element_is_not_visible()
        self._wait_for_processing()
        if self.overrideChoiceDiv.is_element_existed():
            self.overrideChoiceDiv.click_visible_element()
            self.overrideChoiceDiv.wait_until_element_is_not_visible()
            self._wait_for_processing()
        else:  
            self.twoChoiceYesDiv.click_element_if_exist()
            self.twoChoiceYesDiv.wait_until_element_is_not_visible()
            self._wait_for_processing()
                 
    def wait_for_work_order_icon_on_content_table(self, objectName, exist=True, timeOut=Constants.OBJECT_WAIT):
        self.dynamicObjectOnContentTbl.arguments = [objectName]
        woXpath = self.dynamicObjectOnContentTbl.locator() + "/preceding-sibling::td[@aria-describedby='ContentListTbl_ScheduledWork']/img"
        if exist:
            Element(woXpath).wait_until_element_is_visible(timeOut)
        else:
            Element(woXpath).wait_until_element_is_not_visible(timeOut)

    def wait_for_port_icon_exist_on_content_table(self, objectName, portType, timeOut=Constants.OBJECT_WAIT):
        self.dynamicObjectIcon.arguments = [objectName]
        self.dynamicObjectIcon.wait_until_element_attribute_contains("style", portType, timeOut)
        
    def wait_for_port_icon_change_on_content_table(self, objectName, timeOut=Constants.OBJECT_WAIT_PROBE):
        self.dynamicObjectIcon.arguments = [objectName]
        firstValue = self.dynamicObjectIcon.get_element_attribute("style")
        temp = 0
        while temp < timeOut:
            secondValue = self.dynamicObjectIcon.get_element_attribute("style")
            if not secondValue is firstValue: break
            time.sleep(1)
            temp += 1
    
    def click_zoom_extent_button(self):
        self.zoomExtentBtn.click_enabled_element()
        self.mapDiv.wait_for_element_outer_html_not_change()
        
    def check_scale_indicator_displays_on_geo_map(self):
        self.scaleIndicatorDiv.wait_until_element_is_visible() 
        SeleniumAssert.element_should_be_visible(self.scaleIndicatorDiv)
        
    def switch_scale_indicator_unit(self, unit):
        if not unit in self.scaleIndicatorDiv.get_text():
            self.scaleIndicatorDiv.click_visible_element()
    
    def check_scale_indicator_value(self, value): 
        Assert.should_be_equal_as_strings(value, self.scaleIndicatorDiv.get_text())
