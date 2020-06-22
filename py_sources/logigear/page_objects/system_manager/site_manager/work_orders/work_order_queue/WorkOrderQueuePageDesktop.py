from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.table_element import TableElement
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert, Assert
from logigear.page_objects.system_manager.site_manager.work_orders import workOrders
from logigear.core.elements.element import Element
from logigear.core.config import constants
from logigear.data import Constants

class WorkOrderQueuePageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.markCompleteBtn = self.element("markCompleteBtn")
        self.dynamicObjectOnWoQueueTbl = self.element("dynamicObjectOnWoQueueTbl")
        self.allChk = self.element("allChk")
        self.woQueueTbl = self.element("woQueueTbl")
        self.woQueueTbl.__class__ = TableElement
        self.woQueueGridIframe = self.element("woQueueGridIframe")
        self.editBtn = self.element("editBtn")
        self.markCompleteLnk = self.element("markCompleteLnk")
        
    def wait_for_object_exist_on_wo_queue_table(self, objectName, timeOut=Constants.OBJECT_WAIT_PROBE):
        self.dynamicObjectOnWoQueueTbl.arguments = [objectName]
        self.dynamicObjectOnWoQueueTbl.wait_until_element_is_visible(timeOut)
        
    def wait_for_object_not_exist_on_wo_queue_table(self, objectName, timeOut=Constants.OBJECT_WAIT_PROBE):
        self.dynamicObjectOnWoQueueTbl.arguments = [objectName]
        self.dynamicObjectOnWoQueueTbl.wait_until_element_is_not_visible(timeOut)
        
    def get_table_row_map_with_header_on_wo_queue_table(self, headers, values, delimiter=","):
        return self.woQueueTbl._get_table_row_map_with_header(headers, values, delimiter)
        
    def select_object_on_wo_queue_table(self, objectName, delimiter=","):
        woList = objectName.split(delimiter)
        if(objectName != "all"):
            for wo in woList:
                self.wait_for_object_exist_on_wo_queue_table(wo)
                returnRow = self.get_table_row_map_with_header_on_wo_queue_table("Work Order", wo)
                self.woQueueTbl._click_table_cell(returnRow,1)
        else:
            self.allChk.wait_until_element_is_enabled()
            self.allChk.select_checkbox()
    
    def complete_work_order(self, woNames, delimiter=","):
        self._select_iframe(workOrders.woQueueIframe, self.markCompleteBtn)
        temp = 0
        while temp < constants.SELENPY_DEFAULT_TIMEOUT:
            if self.editBtn.is_element_inactive():
                self.select_object_on_wo_queue_table(woNames, delimiter)
                self.woQueueTbl.wait_for_element_outer_html_not_change()
            else:
                break
            temp += 1
        count = 0
        while count < constants.SELENPY_DEFAULT_TIMEOUT:
            if not self.dialogOkBtn.return_wait_for_element_visible_status():
                self.markCompleteBtn.click_element()
                driver.unselect_frame()
            else:
                break
            count += 1
        self.dialogOkBtn.click_visible_element()
        driver.select_frame(workOrders.woQueueIframe)
        self._wait_for_processing()
        driver.unselect_frame()
        
    def close_work_order_queue(self):
        self.dialogCancelBtn.click_visible_element()
        self.dialogCancelBtn.return_wait_for_element_invisible_status()
        
    def check_wo_information_on_wo_queue(self, columns, values, priority=None, scheduling=None, dateCreated=None, expectedDate=None, additionalInformation=None, inactivityAlert=None):
        self._select_iframe(workOrders.woQueueIframe, self.markCompleteBtn)
        returnRow = self.get_table_row_map_with_header_on_wo_queue_table(columns, values)
        Assert.should_be_true(returnRow > 0)
        ######### Expand WO #############
        self.woQueueTbl._click_table_cell(returnRow,1,"double")
        self._select_iframe(self.woQueueGridIframe, workOrders.priorityCbb)
        if priority is not None:
            priorityCbbValue = workOrders.priorityCbb.get_selected_list_label()
            Assert.should_be_equal(priorityCbbValue, priority)
        if scheduling is not None:
            schedulingCbbValue = workOrders.schedulingCbb.get_selected_list_label()
            Assert.should_be_equal(schedulingCbbValue, scheduling)
        if dateCreated is not None:
            SeleniumAssert.element_attribute_value_should_be(workOrders.dateCreatedTxt, "value", dateCreated)
        if expectedDate is not None:
            SeleniumAssert.element_attribute_value_should_be(workOrders.expectedDateTxt, "value", expectedDate)
        if inactivityAlert is not None:
            SeleniumAssert.element_attribute_value_should_be(workOrders.inactivityAlertTxt, "value", inactivityAlert)
        if additionalInformation is not None:
            SeleniumAssert.element_text_should_be(workOrders.additionalInformationTxt, additionalInformation)
        driver.unselect_frame()        
        
    def check_task_list_information_on_work_order_queue_window(self, position, name, taskType, treeFrom, connectionType, treeTo):
        self._select_iframe(workOrders.woQueueIframe, self.markCompleteBtn)
        workOrders._check_task_list_information(self.woQueueGridIframe, position, name, taskType, treeFrom, connectionType, treeTo)
        driver.unselect_frame()
        
    def check_wo_not_exit_on_wo_queue_window(self, woName):
        self.dynamicObjectOnWoQueueTbl.arguments = [woName]
        SeleniumAssert.element_should_not_be_visible(self.dynamicObjectOnWoQueueTbl)
        
    def check_work_order_priority_color(self, woName, color):
        self._select_iframe(workOrders.woQueueIframe, self.markCompleteBtn)
        returnRow = self.get_table_row_map_with_header_on_wo_queue_table("Work Order", woName)
        dynamicCellXpath = self.woQueueTbl.locator() + "//tr[" + str(returnRow) + "]/td[@aria-describedby='WorkOrderQueueGrid_Priority']/div"
        eleCell = Element(dynamicCellXpath)
        SeleniumAssert.element_attribute_value_should_contain(eleCell, "style", color)
        driver.unselect_frame()
        
    def click_edit_button_on_wo_queue_window(self, woName):
        self._select_iframe(workOrders.woQueueIframe, self.markCompleteBtn)
        returnRow = self.get_table_row_map_with_header_on_wo_queue_table("Work Order", woName)
        self.woQueueTbl._click_table_cell(returnRow,1)
        self.editBtn.click_enabled_element()
        driver.unselect_frame()
        
    def delete_wo_on_wo_queue_window(self, woName):
        self._select_iframe(workOrders.woQueueIframe, self.markCompleteBtn)
        returnRow = self.get_table_row_map_with_header_on_wo_queue_table("Work Order", woName)
        self.woQueueTbl._click_table_cell(returnRow,1)
        self.deleteBtn.click_enabled_element()
        driver.unselect_frame() 
        self.confirmDialogBtn.click_enabled_element()
