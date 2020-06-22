from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.assertion import Assert
from logigear.core.drivers import driver


class QuareoUnmanagedConnectionsPageDesktop(GeneralPage):
 
    def __init__(self):
        GeneralPage.__init__(self)
        self.qUCIframe = self.element("qUCIframe")
        self.showRearPortLeftChk = self.element("showRearPortLeftChk")
        self.showRearPortRightChk = self.element("showRearPortRightChk")
        self.filterList = self.element("filterList")
        self.treeFromDiv = self.element("treeFromDiv")
        self.treeToDiv = self.element("treeToDiv")
    
    def click_tree_node_quareo_unmanaged(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""  
        self._click_frame_tree_node(self.qUCIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
    
    def does_tree_node_exist_on_quareo_unmanaged(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        return self._does_frame_tree_node_exist(self.qUCIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
    
    def expand_tree_node_exist_on_quareo_unmanaged(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_quareo_unmanaged(treePanel, treeNode, delimiter)
    
    def check_icon_object_on_quareo_unmanaged_tree(self, treePanel, treeNode, icon, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        connection._check_icon_object_on_connections_window(self.qUCIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
        
    def check_tree_node_exist_on_quareo_unmanaged(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        checkNodeExist = self.does_tree_node_exist_on_quareo_unmanaged(treePanel, treeNode, delimiter)
        Assert.should_be_true(checkNodeExist)
    
    def check_multi_tree_nodes_exist_on_quareo_unmanaged(self, treePanel, treeNodes, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        for treeNode in treeNodes:
            self.check_tree_node_exist_on_quareo_unmanaged(treePanel, treeNode, delimiter)
    
    def check_tree_node_not_exist_on_quareo_unmanaged(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        checkNodeExist = self.does_tree_node_exist_on_quareo_unmanaged(treePanel, treeNode, delimiter)
        Assert.should_be_true(checkNodeExist == False)
    
    def check_multi_tree_nodes_not_exist_on_quareo_unmanaged(self, treePanel, treeNodes, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1, the icon name to check"""
        for treeNode in treeNodes:
            self.check_tree_node_not_exist_on_quareo_unmanaged(treePanel, treeNode, delimiter)
    
    def _filter_on_quareo_unmanaged(self, filterType):
        """filterType: Unassigned Quareo ports OR Assigned Quareo ports"""
        driver.select_frame(self.qUCIframe)
        self.filterList.select_from_list_by_label(filterType)
        driver.unselect_frame()
        
    def create_quareo_unmanaged_connections(self, filterType, typeConnect="Connect", cableFrom=None, cableTo=None, portsTo=None, delimiter=","):
        """typeConnect': Connect or Disconnect
    ...    'filterType': Unassigned Quareo ports OR Assigned Quareo ports
    ...    'cableFrom': the source tree node (containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01/01
    ...    'cableTo': the destination tree node (not containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01
    ...    'portsTo': containing 1 or many end points. Ex: 02,03,04. Quantity of ports_to must be equal quantity of mpo_branches
    ...    'delimiter': the delimiter for mpo_branches and ports_to, the default value is ,"""
        
        self._filter_on_quareo_unmanaged(filterType)
        
        listPortTo = portsTo.split(delimiter)
        
        driver.select_frame(self.qUCIframe)
        self._wait_for_processing()
        
        self._click_tree_node(self.treeFromDiv, cableFrom)
        
        temp = 0
        for portTo in listPortTo:
            pathTo = cableTo + "/" + portTo
            self._click_tree_node(self.treeToDiv, pathTo)
            connection._set_connection(typeConnect)
            self._wait_for_processing()
            temp += 1
            
        driver.unselect_frame()
    
    def close_quareo_unmanaged_window(self):
        self.close_dialog()