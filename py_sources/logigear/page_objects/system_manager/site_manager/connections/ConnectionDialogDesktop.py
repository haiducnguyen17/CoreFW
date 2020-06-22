from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert, Assert
from logigear.core.elements.tree_element import TreeElement
from logigear.core.config import constants
from logigear.core.assertion.robot_assertion import RobotAssertion


class ConnectionDialogDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.dynamicConnectionType = self.element("dynamicConnectionType")
        self.dynamicViewTab = self.element("dynamicViewTab")
        self.dynamicConnectionBtn = self.element("dynamicConnectionBtn")
        self.dynamicMpoBranch = self.element("dynamicMpoBranch")
        self.cablingFrame = self.element("cablingFrame")
        self.cabTreeFromDiv = self.element("cabTreeFromDiv", TreeElement)
        self.cabTreeToDiv = self.element("cabTreeToDiv", TreeElement)
        self.cabCancelBtn = self.element("cabCancelBtn")
        self.dynamicSelectedConnectionType = self.element("dynamicSelectedConnectionType")
        self.connectionTabs = self.element("connectionTabs")
        self.dynamicDisabledConnectionType = self.element("dynamicDisabledConnectionType")
        self.createWoChk = self.element("createWoChk")
        self.cableFromPathDiv = self.element("cableFromPathDiv")
        self.cableToPathDiv = self.element("cableToPathDiv")
        
    def _set_connection(self, typeConnect="Connect"):
        self.dynamicConnectionBtn.arguments = [typeConnect]
        self.dynamicConnectionBtn.wait_until_element_attribute_does_not_contain("src", "Disabled")
        self.dynamicConnectionBtn.click_visible_element()
        self.dynamicConnectionBtn.wait_until_element_attribute_contains("src", "Disabled", constants.SELENPY_DEFAULT_TIMEOUT)
    
    def _select_mpo_branch(self, mpoBranch=None):
        if mpoBranch is not None:
            self.dynamicMpoBranch.arguments = [mpoBranch]
            self.dynamicMpoBranch.click_visible_element()
            temp = 0
            while(not "selectedBranch" in self.dynamicMpoBranch.get_element_attribute("class") and temp < constants.SELENPY_DEFAULT_TIMEOUT):
                self.dynamicMpoBranch.click_element()
                temp += 1
    
    def _select_view_tab(self, viewTab=None):
        if viewTab is not None:
            self.dynamicViewTab.arguments = [viewTab]
            self.dynamicViewTab.click_visible_element()
            
    def _select_mpo_connection_tab(self, mpoConnectionTab=None):
        if mpoConnectionTab is not None:
            self._select_view_tab(mpoConnectionTab + " Connection Type")
            self.connectionTabs.wait_for_element_outer_html_not_change()
            
    def _select_mpo_connection_type(self, mpoConnectionType=None):
        if mpoConnectionType is not None:
            self.dynamicConnectionType.arguments = [mpoConnectionType, mpoConnectionType]
            self.masterRightDiv.wait_for_element_outer_html_not_change()
            self.dynamicConnectionType.click_element_if_exist()
            
    def _check_icon_object_on_connections_window(self, frame, treePanel, fromDivTree, toDivTree, treeNode, icon, delimiter="/"):
        self._does_frame_tree_node_exist(frame, treePanel, fromDivTree, toDivTree, treeNode, delimiter)
        nodeXpath = self._build_page_tree_node_xpath(treePanel, fromDivTree, toDivTree, treeNode, delimiter)
        driver.select_frame(frame)
        self.treeObjectIcon.arguments = [nodeXpath, icon]
        SeleniumAssert.element_should_be_visible(self.treeObjectIcon)
        driver.unselect_frame()
        
    def _check_mpo_connection_type_information(self, frame, mpoConnectionTab=None, mpoConnectionType=None, mpoBranches=None, title=None):
        self.dynamicConnectionType.arguments = [mpoConnectionType, mpoConnectionType]
        self.dynamicSelectedConnectionType.arguments = [mpoConnectionType]
        self.dynamicViewTab.arguments = [mpoConnectionTab + " Connection Type"]
        self._select_iframe(frame, self.dynamicViewTab)
        self._wait_for_processing()
        self._select_mpo_connection_tab(mpoConnectionTab)
        self._select_mpo_connection_type(mpoConnectionType)
        if (mpoConnectionTab is not None) and (mpoConnectionType is not None):
            SeleniumAssert.element_should_be_visible(self.dynamicConnectionType)
            SeleniumAssert.element_should_be_visible(self.dynamicSelectedConnectionType)
        if mpoBranches is not None:
            listMpoBranch = mpoBranches.split(",") 
            for branch in listMpoBranch:
                self.dynamicMpoBranch.arguments = [branch]
                SeleniumAssert.element_should_be_visible(self.dynamicMpoBranch)
        if title is not None:
            self._check_title_attribute(self.dynamicConnectionType, title)        
        driver.unselect_frame()

    def _check_mpo_connection_type_state(self, frame, mpoConnectionType, isEnabled, mpoConnectionTab=None):
        ''''mpoConnectionType': Options: Mpo12_Mpo12, Mpo12_4xLC, Mpo12_6xLC, Mpo24_Mpo24, Mpo24_12xLC, Mpo24_3xMpo12, Mpo24_2xMpo12, Mpo12_6xLC_EB'''
        driver.select_frame(frame)
        self._select_mpo_connection_tab(mpoConnectionTab)
        if isEnabled:            
            self.dynamicConnectionType.arguments = [mpoConnectionType, mpoConnectionType]
            elementEnabledExist = self.dynamicConnectionType.return_wait_for_element_visible_status(3)
            Assert.should_be_true(elementEnabledExist)
        else:
            self.dynamicDisabledConnectionType.arguments = [mpoConnectionType, mpoConnectionType]
            elementDisabledExist = self.dynamicDisabledConnectionType.return_wait_for_element_visible_status(3)
            Assert.should_be_true(elementDisabledExist)
        driver.unselect_frame()
   
    def _check_connect_button_state(self, frame, isEnabled):
        driver.select_frame(frame)
        self.dynamicConnectionBtn.arguments = ["Connect"]
        if isEnabled:            
            SeleniumAssert.element_attribute_value_should_not_contain(self.dynamicConnectionBtn, "src", "Disabled")            
        else:
            SeleniumAssert.element_attribute_value_should_contain(self.dynamicConnectionBtn, "src", "Disabled")  
        driver.unselect_frame()
        
    def _check_icon_mpo_port_type_on_connections_window(self, frame, treePanel, fromDivTree, toDivTree, treeNode, portType, isExisted, delimiter="/"):
        self._does_frame_tree_node_exist(frame, treePanel, fromDivTree, toDivTree, treeNode, delimiter)
        nodeXpath = self._build_page_tree_node_xpath(treePanel, fromDivTree, toDivTree, treeNode, delimiter)
        driver.select_frame(frame)
        self.treePortTypeIcon.arguments = [nodeXpath, portType]
        if isExisted: 
            SeleniumAssert.element_should_be_visible(self.treePortTypeIcon)
        else:
            SeleniumAssert.element_should_not_be_visible(self.treePortTypeIcon)        
        driver.unselect_frame()
        
    def _check_mpo_connection_type_icon_not_exist(self, frame, mpoConnectionType, mpoConnectionTab=None):
        ''''mpoConnectionType': Options: Mpo12_Mpo12, Mpo12_4xLC, Mpo12_6xLC, Mpo24_Mpo24, Mpo24_12xLC, Mpo24_3xMpo12, Mpo24_2xMpo12, Mpo12_6xLC_EB'''
        driver.select_frame(frame)
        self._select_mpo_connection_tab(mpoConnectionTab)
        self.dynamicConnectionType.arguments = [mpoConnectionType, mpoConnectionType]
        self.dynamicDisabledConnectionType.arguments = [mpoConnectionType, mpoConnectionType]
        SeleniumAssert.element_should_not_be_visible(self.dynamicConnectionType)
        SeleniumAssert.element_should_not_be_visible(self.dynamicDisabledConnectionType)           
        driver.unselect_frame()
