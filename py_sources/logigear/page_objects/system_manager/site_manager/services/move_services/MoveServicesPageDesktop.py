'''
Created on May 4, 2020

@author: tiep.tra
'''
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.services import services
from logigear.core.drivers import driver
from logigear.core.elements.tree_element import TreeElement
from logigear.core.elements.table_element import TableElement

class MoveServicesPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.moveTreeDiv = self.element("moveTreeDiv", TreeElement)
        self.viewFilterCbb = self.element("viewFilterCbb")
        self.viewServiceFilterCbb = self.element("viewServiceFilterCbb")
        self.moveBtn = self.element("moveBtn")
        self.selectObjectTbl = self.element("selectObjectTbl", TableElement)
        
    def move_services(self, viewObjectFilter=None, moveTreeNode=None, moveTo=None, viewServiceFilter=None, selectObjects=None, moveServiceFrom=None, moveServiceTo=None, delimiterTree="/"):
        services.serviceIframe.wait_until_page_contains_element()
        driver.select_frame(services.serviceIframe)
        
        # Select Object To Move
        if viewObjectFilter is not None:
            self.viewFilterCbb.wait_until_element_is_visible()
            self.viewFilterCbb.select_from_list_by_label(viewObjectFilter)
            self.moveTreeDiv.click_tree_node(moveTreeNode, delimiterTree)
            driver.unselect_frame()
            self.dialogOkBtn.click_visible_element()
            self._select_iframe(services.serviceIframe, services.leftTreeDiv)
        
        # Select New Location
        services.rightTreeDiv.wait_until_element_is_visible()
        if moveTo is not None:
            services.rightTreeDiv.click_tree_node(moveTo, delimiterTree)
        self.moveBtn.click_visible_element()
        
        # Move Services For Object
        if viewServiceFilter is not None:
            self.viewServiceFilterCbb.select_from_list_by_label(viewServiceFilter)
        if selectObjects is not None:
            listObject = selectObjects.split(",")
            for selectobject in listObject:
                returnRow = self.selectObjectTbl._get_table_row_map_with_header("Object", selectobject)
                self.selectObjectTbl._click_table_cell(returnRow, 2)
        if moveServiceFrom is not None:
            services.leftTreeDiv.click_tree_node(moveServiceFrom, delimiterTree)
        if moveServiceTo is not None:
            services.rightTreeDiv.click_tree_node(moveServiceTo, delimiterTree)
        self.moveBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        driver.select_frame(services.serviceIframe)
        self.moveBtn.wait_until_element_attribute_contains("disabled", "true")
        driver.unselect_frame()
        self.dialogOkBtn.click_visible_element()
        