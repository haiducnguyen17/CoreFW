from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection


class ReplaceNetworkEquipmentPageDesktop(GeneralPage):
 
    def __init__(self):
        GeneralPage.__init__(self)
        self.rneIframe = self.element("rneIframe")
        self.treefromDiv = self.element("treefromDiv")
        self.treetoDiv = self.element("treetoDiv")

    def click_tree_node_replace_network_equipment(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        self._click_frame_tree_node(self.replaceNetworkEquipmentIframe, treePanel, self.treefromDiv, self.treetoDiv, treeNode, delimiter)
        
    def does_tree_node_exist_on_replace_network_equipment(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        return self._does_frame_tree_node_exist(self.replaceNetworkEquipmentIframe, treePanel, self.treefromDiv, self.treetoDiv, treeNode, delimiter)
    
    def expand_tree_node_exist_on_replace_network_equipment(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        self.does_tree_node_exist_on_replace_network_equipment(treePanel, treeNode, delimiter)
        
    def check_icon_object_on_replace_network_equipment_tree(self, treePanel, treeNode, icon, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        connection._check_icon_object_on_connections_window(self.rneIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
    
    def close_replace_network_equipment_window(self):
        self.close_dialog()
        
