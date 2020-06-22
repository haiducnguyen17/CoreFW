from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.assertion import Assert, SeleniumAssert

class CablingPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
    
    def does_tree_node_exist_on_cabling(self, treePanel, treeNode, delimiter="/"):
        return self._does_frame_tree_node_exist(connection.cablingFrame, treePanel, connection.cabTreeFromDiv, connection.cabTreeToDiv, treeNode, delimiter)
    
    def click_tree_node_cabling(self, treePanel, treeNode, delimiter="/"):
        self._click_frame_tree_node(connection.cablingFrame, treePanel, connection.cabTreeFromDiv, connection.cabTreeToDiv, treeNode, delimiter)
    
    def expand_tree_node_exist_on_cabling(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_cabling(treePanel, treeNode, delimiter)
    
    def check_icon_object_on_cabling_tree(self, treePanel, treeNode, icon, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        connection._check_icon_object_on_connections_window(connection.cablingFrame, treePanel, connection.cabTreeFromDiv, connection.cabTreeToDiv, treeNode, icon, delimiter)
        
    def check_tree_node_exist_on_cabling(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        checkNodeExist = self.does_tree_node_exist_on_cabling(treePanel, treeNode, delimiter)
        Assert.should_be_true(checkNodeExist)
    
    def check_multi_tree_nodes_exist_on_cabling(self, treePanel, treeNodes, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        for treeNode in treeNodes:
            self.check_tree_node_exist_on_cabling(treePanel, treeNode, delimiter)
    
    def check_tree_node_not_exist_on_cabling(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        checkNodeExist = self.does_tree_node_exist_on_cabling(treePanel, treeNode, delimiter)
        Assert.should_be_true(checkNodeExist == False)
    
    def check_multi_tree_nodes_not_exist_on_cabling(self, treePanel, treeNodes, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        for treeNode in treeNodes:
            self.check_tree_node_not_exist_on_cabling(treePanel, treeNode, delimiter)
    
    def close_cabling_window(self):
        self.close_dialog()      
        
    def create_cabling(self, typeConnect="Connect", cableFrom=None, cableTo=None, mpoTab=None, mpoType=None, mpoBranches=None, portsTo=None, delimiter=","):
        """typeConnect': Connect or Disconnect
    ...    'cableFrom': the source tree node (containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01/01
    ...    'cableTo': the destination tree node (not containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01
    ...    'mpoTab': when cabling for mpo port type(2 options: Mpo12, Mpo24)
    ...    'mpoType': Options: Mpo12_Mpo12, Mpo12_4xLC, Mpo12_6xLC, Mpo24_Mpo24, Mpo24_12xLC, Mpo24_3xMpo12, Mpo24_2xMpo12, Mpo12_6xLC_EB
    ...    'mpoBranches': when cabling for mpo port type(is depended on mpo_type). Ex: B1,B2,B3
    ...    'portsTo': containing 1 or many end points. Ex: 02,03,04. Quantity of ports_to must be equal quantity of mpo_branches
    ...    'delimiter': the delimiter for mpo_branches and ports_to, the default value is ,"""
        
        listPortTo = portsTo.split(delimiter)
        if mpoBranches is not None:
            listMpoBranch = mpoBranches.split(delimiter)
        
        driver.select_frame(connection.cablingFrame)
        self._wait_for_processing()
        
        connection.cabTreeFromDiv.click_tree_node(cableFrom)
        
        connection._select_mpo_connection_tab(mpoTab)
        connection._select_mpo_connection_type(mpoType)
        
        temp = 0
        for portTo in listPortTo:
            if mpoBranches is not None:
                connection._select_mpo_branch(listMpoBranch[temp])
            pathTo = cableTo + "/" + portTo
            connection.cabTreeToDiv.click_tree_node(pathTo)
            connection._set_connection(typeConnect)
            self._wait_for_processing(3)
            temp += 1
            
        driver.unselect_frame()
          
    def open_trace_window_on_cabling(self, treePanel=None, treeNode=None):
        driver.select_frame(connection.cablingFrame)
        self._wait_for_processing()
        if treePanel is not None and treeNode is not None:
            if treePanel == "From":
                self._click_tree_node(connection.cabTreeFromDiv, treeNode)
            elif treePanel == "To":
                self._click_tree_node(connection.cabTreeToDiv, treeNode)
        connection.traceBtn.click_visible_element()
        driver.unselect_frame()
        
    def check_mpo_connection_type_information_on_cabling_window(self, mpoConnectionTab=None, mpoConnectionType=None, mpoBranches=None, title=None):
        connection._check_mpo_connection_type_information(connection.cablingFrame, mpoConnectionTab, mpoConnectionType, mpoBranches, title)

    def check_mpo_connection_type_state_on_cabling_window(self, mpoConnectionType, isEnabled, mpoConnectionTab=None):
        connection._check_mpo_connection_type_state(connection.cablingFrame, mpoConnectionType, isEnabled, mpoConnectionTab)
        
    def check_port_status_on_cabling_window(self, treePanel=None, treeNode=None, expectedStatus=None):
        driver.select_frame(connection.cablingFrame)
        self._wait_for_processing()
        if treePanel is not None and treeNode is not None:
            if treePanel == "From":
                self._click_tree_node(connection.cabTreeFromDiv, treeNode)
                SeleniumAssert.element_attribute_value_should_contain(connection.cableFromPathDiv, "textContent", expectedStatus)
            elif treePanel == "To":
                self._click_tree_node(connection.cabTreeToDiv, treeNode)
                SeleniumAssert.element_attribute_value_should_contain(connection.cableToPathDiv, "textContent", expectedStatus)
        driver.unselect_frame()
        
    def check_connect_button_state_on_cabling_window(self,isEnabled):
        connection._check_connect_button_state(connection.cablingFrame, isEnabled)
        
    def check_icon_mpo_port_type_on_cabling_window(self, treePanel, treeNode, portType, isExisted=True, delimiter="/"):
        connection._check_icon_mpo_port_type_on_connections_window(connection.cablingFrame, treePanel, connection.cabTreeFromDiv, connection.cabTreeToDiv, treeNode, portType, isExisted, delimiter) 
    