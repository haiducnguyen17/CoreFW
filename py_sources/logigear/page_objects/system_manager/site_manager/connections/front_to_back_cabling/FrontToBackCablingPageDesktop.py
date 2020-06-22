from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.connections import connection
from logigear.core.drivers import driver


class FrontToBackCablingPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        
    def click_tree_node_front_to_back_cabling(self, treePanel, treeNode, delimiter="/"):
        self._click_frame_tree_node(connection.cablingFrame, treePanel, connection.cabTreeFromDiv,connection.cabTreeToDiv, treeNode, delimiter)
        
    def does_tree_node_exist_on_front_to_back_cabling(self, treePanel, treeNode, delimiter="/"):
        self._does_frame_tree_node_exist(connection.cablingFrame, treePanel, connection.cabTreeFromDiv,connection.cabTreeToDiv, treeNode, delimiter)
        
    def expand_tree_node_exist_on_front_to_back_cabling(self, treePanel, treeNode, delimiter="/"):
        self.does_tree_node_exist_on_front_to_back_cabling(treePanel, treeNode, delimiter)
        
    def close_front_to_back_cabling_window(self):
        self.close_dialog()      

    def check_icon_object_on_front_to_back_cabling_tree(self, treePanel, treeNode, icon, delimiter="/"):
        connection._check_icon_object_on_connections_window(connection.cablingFrame, treePanel, connection.cabTreeFromDiv,connection.cabTreeToDiv, treeNode, icon, delimiter)
        
    def create_front_to_back_cabling(self, cabFrom, cabTo, portsFrom, portsTo, typeConnect="Connect", mpoTab=None, mpoType=None, mpoBranches=None, delimiter=",", delimiterTree="/"):
        """'type': Connect or Disconnect
    ...    'cabFrom': the source tree node (not containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01
    ...    'cabTo': the destination tree node (not containing the end point). Ex: Site/Building/Floor 01/Room 01/1:1 Rack 001/Switch 01
    ...    'mpoTab': when cabling for mpo port type(2 options: Mpo12, Mpo24)
    ...    'mpoType': Options: Mpo12_Mpo12, Mpo12_4xLC, Mpo12_6xLC, Mpo24_Mpo24, Mpo24_12xLC, Mpo24_3xMpo12, Mpo24_2xMpo12, Mpo12_6xLC_EB(*Mpo12-3xMpo12* and *Mpo12-2xMpo12*) => describe 3xMpo12-Mpo24, 2xMpo12-Mpo24
    ...    'mpoBranches': when cabling for mpo port type(is depended on mpo_type). Ex: B1,B2,B3
    ...    'portsFrom': containing 1 or many end points. Ex: 02,03,04. Quantity of ports_to must be equal quantity of mpo_branches
    ...    'portsTo': containing 1 or many end points. Ex: 02,03,04. Quantity of ports_to must be equal quantity of mpo_branches
    ...    'delimiter': the delimiter for mpo_branches and ports_to, the default value is ,"""
        listPortFrom = portsFrom.split(delimiter)
        listPortTo = portsTo.split(delimiter)
        numberPortFrom = len(listPortFrom)
        numberPortTo = len(listPortTo)
        
        driver.select_frame(connection.cablingFrame)
        self._wait_for_processing
        
        if mpoBranches is None:
            pathFrom = cabFrom + delimiterTree + portsFrom
            connection.cabTreeFromDiv.click_tree_node(pathFrom)
            pathTo = cabTo + delimiterTree + portsTo
            connection.cabTreeToDiv.click_tree_node(pathTo)
            connection._set_connection(typeConnect)
            self._wait_for_processing()
        else:
            listMpoBranch = mpoBranches.split(delimiter) 
            temp = 0   
            for branch in listMpoBranch:
                if numberPortFrom == 1 and temp == 0:
                    pathFrom = cabFrom + delimiterTree + portsFrom
                    connection.cabTreeFromDiv.click_tree_node(pathFrom)
                elif numberPortFrom > 1:
                    pathFrom = cabFrom + delimiterTree + listPortFrom[temp]
                    connection.cabTreeFromDiv.click_tree_node(pathFrom)
                if temp == 0:
                    connection._select_mpo_connection_tab(mpoTab)
                connection._select_mpo_connection_type(mpoType)
                connection._select_mpo_branch(branch)
                if numberPortTo == 1 and temp == 0:
                    pathTo = cabTo + delimiterTree + portsTo
                    connection.cabTreeToDiv.click_tree_node(pathTo)
                elif numberPortTo > 1:
                    pathTo = cabTo + delimiterTree + listPortTo[temp]
                    connection.cabTreeToDiv.click_tree_node(pathTo)
                connection._set_connection(typeConnect)
                self._wait_for_processing()
                temp += 1
        
        driver.unselect_frame()
        
    def check_mpo_connection_type_information_on_front_to_back_cabling_window(self, mpoConnectionTab=None, mpoConnectionType=None, mpoBranches=None, title=None):
        connection._check_mpo_connection_type_information(connection.cablingFrame, mpoConnectionTab, mpoConnectionType, mpoBranches, title)

    def check_mpo_connection_type_icon_not_exist_on_front_to_back_cabling_window(self, mpoConnectionType, mpoConnectionTab=None):
        connection._check_mpo_connection_type_icon_not_exist(connection.cablingFrame, mpoConnectionType, mpoConnectionTab)
