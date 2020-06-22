from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.assertion import Assert, SeleniumAssert
from logigear.core.elements.tree_element import TreeElement

class PatchingPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.treeFromDiv = self.element("treeFromDiv", TreeElement)
        self.treeToDiv = self.element("treeToDiv", TreeElement)
        self.completePatchBtn = self.element("completePatchBtn")
        self.patchingIframe = self.element("patchingIframe")
        self.patchingTraceDiv = self.element("patchingTraceDiv")
        self.dynamicTaskName = self.element("dynamicTaskName")
        self.dynamicTaskType = self.element("dynamicTaskType")
        self.dynamicTaskTreeFrom = self.element("dynamicTaskTreeFrom")
        self.dynamicTaskConnectType = self.element("dynamicTaskConnectType")
        self.dynamicTaskTreeTo = self.element("dynamicTaskTreeTo")
        self.dynamicTaskListTable = self.element("dynamicTaskListTable")
        self.statusFromDiv = self.element("statusFromDiv")
        self.statusToDiv = self.element("statusToDiv")
        self.dynamicPortStatus = self.element("dynamicPortStatus")
        
    def create_patching(self, patchFrom, patchTo, portsFrom, portsTo, typeConnect="Connect", mpoTab=None, mpoType=None, mpoBranches=None, delimiter=",", delimiterTree="/", createWo=True, clickNext=True):
        """'type': Connect or Disconnect
    ...    'patchFrom': the source tree node (not containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01
    ...    'patchTo': the destination tree node (not containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01
    ...    'mpoTab': when patching for mpo port type(2 options: Mpo12, Mpo24)
    ...    'mpoType': Options: Mpo12_Mpo12, Mpo12_4xLC, Mpo12_6xLC, Mpo24_Mpo24, Mpo24_12xLC, Mpo24_3xMpo12, Mpo24_2xMpo12, Mpo12_6xLC_EB (*Mpo12-3xMpo12* and *Mpo12-2xMpo12*) => describe 3xMpo12-Mpo24, 2xMpo12-Mpo24
    ...    'mpoBranches': when patching for mpo port type(is depended on mpo_type). Ex: B1,B2,B3
    ...    'portsFrom': containing 1 or many end points. Ex: 02,03,04. Quantity of ports_to must be equal quantity of mpo_branches
    ...    'portsTo': containing 1 or many end points. Ex: 02,03,04. Quantity of ports_to must be equal quantity of mpo_branches
    ...    'delimiter': the delimiter for mpo_branches and ports_to, the default value is ,"""
        listPortFrom = portsFrom.split(delimiter)
        listPortTo = portsTo.split(delimiter)
        numberPortFrom = len(listPortFrom)
        numberPortTo = len(listPortTo)
        
        driver.select_frame(self.patchingIframe)
        self._wait_for_processing()
        self.treeFromDiv.wait_until_element_is_visible()
        self._wait_for_loading_tree()
        
        if mpoBranches is None:
            pathFrom = patchFrom + delimiterTree + portsFrom
            self.treeFromDiv.click_tree_node(pathFrom, delimiterTree)
            pathTo = patchTo + delimiterTree + portsTo
            self.treeToDiv.click_tree_node(pathTo, delimiterTree)
            connection._set_connection(typeConnect)
            self._wait_for_processing()
        else:
            listMpoBranch = mpoBranches.split(delimiter) 
            temp = 0   
            for branch in listMpoBranch:
                if numberPortFrom == 1:
                    pathFrom = patchFrom + delimiterTree + portsFrom
                else:
                    pathFrom = patchFrom + delimiterTree + listPortFrom[temp]
                self.treeFromDiv.click_tree_node(pathFrom, delimiterTree)
                if temp == 0:
                    connection._select_mpo_connection_tab(mpoTab)
                    connection._select_mpo_connection_type(mpoType)
                connection._select_mpo_branch(branch)
                if numberPortTo == 1:
                    pathTo = patchTo + delimiterTree + portsTo
                else:
                    pathTo = patchTo + delimiterTree + listPortTo[temp]
                self.treeToDiv.click_tree_node(pathTo, delimiterTree)
                connection._set_connection(typeConnect)
                self._wait_for_processing()
                temp += 1
        
        connection.createWoChk.select_checkbox(createWo)
        driver.unselect_frame()
        if clickNext:
            self.save_patching_window()
    
    def save_patching_window(self):
        self.save_dialog()
        self._wait_for_processing()
        if self.patchingIframe.is_element_existed():
            driver.select_frame(self.patchingIframe)
            self._wait_for_processing()
            driver.unselect_frame()
        
    def click_tree_node_patching(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""  
        self._click_frame_tree_node(self.patchingIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
        
    def does_tree_node_exist_on_patching(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        return self._does_frame_tree_node_exist(self.patchingIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
    
    def expand_tree_node_exist_on_patching(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        self.does_tree_node_exist_on_patching(treePanel, treeNode, delimiter)
        
    def check_icon_object_on_patching_tree(self, treePanel, treeNode, icon, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        connection._check_icon_object_on_connections_window(self.patchingIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
    
    def close_patching_window(self):
        self.close_dialog()
        
    def check_tree_node_exist_on_patching(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""     
        checkNodeExist = self.does_tree_node_exist_on_patching(treePanel, treeNode, delimiter)
        Assert.should_be_true(checkNodeExist, treeNode + " does not exist on Patching window")
        
    def check_multi_tree_nodes_exist_on_patching(self, treePanel, treeNodes, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""     
        for treeNode in treeNodes:
            self.check_tree_node_exist_on_patching(treePanel, treeNode, delimiter)
    
    def check_tree_node_not_exist_on_patching(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        checkNodeExist = self.does_tree_node_exist_on_patching(treePanel, treeNode, delimiter)
        Assert.should_be_true(checkNodeExist == False, treeNode + " exists on Patching window")
     
    def check_trace_object_on_patching(self, indexObject, mpoType=None, objectPosition=None, objectPath=None, objectType=None, portIcon=None, connectionType=None, scheduleIcon=None, informationDevice=None):
        driver.select_frame(self.patchingIframe)
        self._wait_for_processing()
        self.patchingTraceDiv.wait_until_page_contains_element()
        self._check_trace_object(self.patchingTraceDiv, indexObject, mpoType, objectPosition, objectPath, objectType, portIcon, connectionType, scheduleIcon, informationDevice)
        driver.unselect_frame()
        
    def select_view_trace_tab_on_patching(self, viewTab):
        driver.select_frame(self.patchingIframe)
        self.patchingTraceDiv.wait_for_element_outer_html_not_change()
        self._select_view_trace_tab(self.patchingTraceDiv, viewTab)
        driver.unselect_frame()
        
    def check_multi_tree_nodes_not_exist_on_patching(self, treePanel, treeNodes, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        for treeNode in treeNodes:    
            self.check_tree_node_not_exist_on_patching(treePanel, treeNode, delimiter)
    
    def check_mpo_connection_type_information_on_patching_window(self, mpoConnectionTab=None, mpoConnectionType=None, mpoBranches=None, title=None):
        connection._check_mpo_connection_type_information(self.patchingIframe, mpoConnectionTab, mpoConnectionType, mpoBranches, title)
        
    def select_view_tab_on_patching(self, viewTab):
        self._select_iframe(self.patchingIframe, connection.createWoChk)
        connection._select_view_tab(viewTab)
        driver.unselect_frame()

    def check_mpo_connection_type_state_on_patching_window(self, mpoConnectionType, isEnabled, mpoConnectionTab=None):
        connection._check_mpo_connection_type_state(self.patchingIframe, mpoConnectionType, isEnabled, mpoConnectionTab)
     
    def check_task_list_information_on_patching_window(self, position, name, taskType, treeFrom, connectionType, treeTo):
        self.dynamicTaskListTable.arguments = [position]
        self.dynamicTaskName.arguments = [self.dynamicTaskListTable.locator(), name]
        self.dynamicTaskType.arguments = [self.dynamicTaskListTable.locator(), taskType]
        self.dynamicTaskTreeFrom.arguments = [self.dynamicTaskListTable.locator(), treeFrom]
        self.dynamicTaskConnectType.arguments = [self.dynamicTaskListTable.locator(), connectionType]
        self.dynamicTaskTreeTo.arguments = [self.dynamicTaskListTable.locator(), treeTo]
        driver.select_frame(self.patchingIframe)
        self.dynamicTaskTreeTo.mouse_over()
        SeleniumAssert.element_should_be_visible(self.dynamicTaskName)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskType)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskTreeFrom)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskConnectType)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskTreeTo)
        driver.unselect_frame()
        
    def check_port_status_on_patching_window(self, statusPanel, treeNode, status):
        if statusPanel == "From":
            self.click_tree_node_patching("From", treeNode)
            self.dynamicPortStatus.arguments = [self.statusFromDiv.locator(), status]
        else:
            self.click_tree_node_patching("To", treeNode)
            self.dynamicPortStatus.arguments = [self.statusToDiv.locator(), status]
        driver.select_frame(self.patchingIframe)
        SeleniumAssert.element_should_be_visible(self.dynamicPortStatus)
        driver.unselect_frame()
        
    def check_icon_mpo_port_type_on_patching_window(self, treePanel, treeNode, portType, isExisted=True, delimiter="/"):
        connection._check_icon_mpo_port_type_on_connections_window(self.patchingIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, portType, isExisted, delimiter)
        
    def check_mpo_connection_type_icon_not_exist_on_patching_window(self, mpoConnectionType, mpoConnectionTab=None):
        connection._check_mpo_connection_type_icon_not_exist(self.patchingIframe, mpoConnectionType, mpoConnectionTab)
