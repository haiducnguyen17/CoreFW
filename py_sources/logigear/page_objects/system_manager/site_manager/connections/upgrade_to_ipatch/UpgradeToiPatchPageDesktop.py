from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection


class UpgradeToiPatchPageDesktop (GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.iframe = self.element("utiIframe")
        self.treeFromDiv = self.element("treeFromDiv")
        self.treeToDiv = self.element("treeToDiv")
        self.treeObjectIcon = self.element("treeObjectIcon")
        
    def click_tree_node_upgrade_to_ipatch(self, treePanel, treeNode, delimiter="/"):
        """ treePanel = From or To, tree_node with format as example Site/TM_MNE_236/Room1 """
        self._click_frame_tree_node(self.iframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
        
    def does_tree_node_exist_on_upgrade_to_ipatch(self, treePanel, treeNode, delimiter="/"):
        """ treePanel = From or To, tree_node with format as example Site/TM_MNE_236/Room1 """
        return self._does_frame_tree_node_exist(self.iframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
        
    def expand_tree_node_exist_on_upgrade_to_ipatch(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_upgrade_to_ipatch(treePanel, treeNode, delimiter)
        
    def check_icon_object_on_upgrade_to_ipatch_tree(self, treePanel, treeNode, icon, delimiter="/"):
        connection._check_icon_object_on_connections_window(self.iframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
                            
    def close_upgrade_to_ipatch_window(self):
        self.close_dialog()
    
