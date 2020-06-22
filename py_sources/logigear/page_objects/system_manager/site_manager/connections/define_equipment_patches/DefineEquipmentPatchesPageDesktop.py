from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.elements.tree_element import TreeElement

class DefineEquipmentPatchesPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.depIframe = self.element("depIframe")
        self.treeFromDiv = self.element("treeFromDiv", TreeElement)
        self.treeToDiv = self.element("treeToDiv", TreeElement)
        
    def click_tree_node_define_equipment_patches(self, treePanel, treeNode, delimiter="/"):
        """ treePanel = From or To, tree_node with format as example Site/TM_MNE_236/Room1 """
        self._click_frame_tree_node(self.depIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)

    def does_tree_node_exist_on_define_equipment_patches(self, treePanel, treeNode, delimiter="/"):
        """ treePanel = From or To, tree_node with format as example Site/TM_MNE_236/Room1 """
        return self._does_frame_tree_node_exist(self.depIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
        
    def expand_tree_node_exist_on_define_equipment_patches(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_define_equipment_patches(treePanel, treeNode, delimiter)
        
    def check_icon_object_on_define_equipment_patches_tree(self, treePanel, treeNode, icon, delimiter="/"):
        connection._check_icon_object_on_connections_window(self.depIframe, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
                            
    def close_define_equipment_patches_window(self):
        self.close_dialog()
