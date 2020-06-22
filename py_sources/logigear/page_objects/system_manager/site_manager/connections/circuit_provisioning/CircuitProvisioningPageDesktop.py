from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.elements.tree_element import TreeElement

class CircuitProvisioningPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        self.ccFrame = self.element("ccFrame")
        self.treeFromDiv = self.element("treeFromDiv", TreeElement)
        self.treeToDiv = self.element("treeToDiv", TreeElement)
        
    def click_tree_node_circuit_provisioning(self, treePanel, treeNode, delimiter="/"):
        self._click_frame_tree_node(self.ccFrame, treePanel, self.treeFromDiv,
                                    self.treeToDiv, treeNode, delimiter)
    
    def does_tree_node_exist_on_circuit_provisioning(self, treePanel, treeNode, delimiter="/"):
        self._does_frame_tree_node_exist(self.ccFrame, treePanel, self.treeFromDiv
                                         , self.treeToDiv, treeNode, delimiter)
    
    def expand_tree_node_on_circuit_provisioning(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_circuit_provisioning(treePanel, treeNode, delimiter)
    
    def check_icon_object_on_circuit_provisioning_tree(self, treePanel, treeNode, icon, delimiter="/"):
        connection._check_icon_object_on_connections_window(self.ccFrame, treePanel, self.treeFromDiv, self.treeToDiv, treeNode, icon, delimiter)
    
    def close_circuit_provisioning_window(self):
        self.close_dialog()
