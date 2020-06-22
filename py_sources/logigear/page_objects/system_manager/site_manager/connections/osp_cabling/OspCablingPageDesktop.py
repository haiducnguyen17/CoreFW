from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection


class OspCablingPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.ospCablingIframe = self.element("ospCablingIframe")
        self.treeFromDiv = self.element("treeFromDiv")
        self.treeToDiv = self.element("treeToDiv")
        
    def click_tree_node_osp_cabling(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""  
        self._click_frame_tree_node(self.ospCablingIframe, treePanel, self.treefromDiv, self.treetoDiv, treeNode, delimiter)
    
    def does_tree_node_exist_on_osp_cabling(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        return self._does_frame_tree_node_exist(self.ospCablingIframe, treePanel, self.treefromDiv, self.treetoDiv, treeNode, delimiter)
    
    def expand_tree_node_exist_on_osp_cabling(self, treePanel, treeNode, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        self.does_tree_node_exist_on_osp_cabling(treePanel, treeNode, delimiter)
        
    def check_icon_object_on_osp_cabling_tree(self, treePanel, treeNode, icon, delimiter="/"):
        """tree_panel = From or To, tree_node with format as example Site/TM_MNE_236/Room1"""
        connection._check_icon_object_on_connections_window(self.ospCablingIframe, treePanel, connection.cabTreeFromDiv,connection.cabTreeToDiv, treeNode, icon, delimiter)
    
    def close_osp_cabling_window(self):
        self.close_dialog()
       
