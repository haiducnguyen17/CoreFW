from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.elements.tree_element import TreeElement

class ConduitsPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        self.treeFromDiv = self.element("treeFromDiv", TreeElement)
        self.treeToDiv = self.element("treeToDiv", TreeElement)
        self.addConduitBtn = self.element("addConduitBtn")
        self.conduitsFrame = self.element("conduitsFrame")
        self.addConduitsCancelBtn = self.element("addConduitsCancelBtn")
        
    def click_tree_node_conduits(self, treePanel, treeNode, delimiter="/"):
        self._click_frame_tree_node(self.conduitsFrame, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
        
    def does_tree_node_exist_on_conduits(self, treePanel, treeNode, delimiter="/"):
        self._does_frame_tree_node_exist(self.conduitsFrame, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, delimiter)
        
    def expand_tree_node_exist_on_conduits(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_conduits(treePanel, treeNode, delimiter)
        
    def close_manage_conduits_window(self):
        self.close_dialog()
        
    def close_add_conduits_window(self):
        driver.select_frame(self.conduitsFrame)
        self.addConduitsCancelBtn.click_visible_element()
        driver.unselect_frame()
        
    def click_add_conduits_button(self):
        driver.select_frame(self.conduitsFrame)
        self.addConduitBtn.click_visible_element()
        self.treeFromDiv.wait_until_element_is_visible()
        driver.unselect_frame()
        
    def check_icon_object_on_conduits_tree(self, treePanel, treeNode, icon, delimiter="/"):
        connection._check_icon_object_on_connections_window(self.conduitsFrame, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
