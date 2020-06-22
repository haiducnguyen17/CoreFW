from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.site_manager.work_orders import workOrders
from logigear.core.assertion import Assert
from logigear.core.config import constants

class CreateWorkOrderPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.woIframe = self.element("woIframe")
        self.conclusionDiv = self.element("conclusionDiv")
        self.showTraceBtn = self.element("showTraceBtn")
        self.traceMapDiv = self.element("traceMapDiv")
        self.editWOIframe = self.element("editWOIframe")
        self.saveEditBtn = self.element("saveEditBtn")
                    
    def create_work_order(self, woName=None, summary=None, priority=None, technician=None, scheduling=None, onHold=False, earliestDate=None, latestDate=None, inactivityAlert=None, clickNext=True):
        workOrders._fill_information_for_work_order(self.woIframe, woName, summary, priority, technician, scheduling, onHold, earliestDate, latestDate, inactivityAlert)
        if clickNext:
            self.confirmDialogBtn.click_visible_element(timeout=constants.SELENPY_OBJECT_WAIT)
            self.confirmDialogBtn.wait_until_element_is_not_visible()
            
        # Confirm Attention
        if self.woIframe.is_element_existed():
            driver.select_frame(self.woIframe)
            if self.attentionYesBtn.is_element_existed(): 
                self.attentionYesBtn.click_element()
                self.attentionYesBtn.wait_until_element_is_not_visible()
            self._wait_for_processing()
            driver.unselect_frame()
        
    def check_task_list_information_on_create_wo_window(self, position, name, taskType, treeFrom, connectionType, treeTo):
        workOrders._check_task_list_information(self.woIframe, position, name, taskType, treeFrom, connectionType, treeTo)

    def check_service_conclusion(self, conclusion):
        self._select_iframe(self.woIframe, self.conclusionDiv)
        self._wait_for_processing()
        Assert.should_be_equal(self.conclusionDiv.get_element_attribute("textContent"), conclusion)
        driver.unselect_frame()
        
    def check_trace_object_on_create_work_order(self, indexObject, mpoType=None, objectPosition=None, objectPath=None, objectType=None, portIcon=None, connectionType=None, scheduleIcon=None, informationDevice=None, closeDialog=False):
        self._select_iframe(self.woIframe, self.traceMapDiv)
        self.showTraceBtn.click_element_if_exist()
        self.traceMapDiv.wait_until_element_is_visible()
        self._check_trace_object(self.traceMapDiv, indexObject, mpoType, objectPosition, objectPath, objectType, portIcon, connectionType, scheduleIcon, informationDevice)
        driver.unselect_frame()
        if closeDialog:
            self.confirmDialogBtn.click_visible_element()   

    def edit_work_order(self, woName=None, summary=None, priority=None, technician=None, scheduling=None, onHold=False, earliestDate=None, latestDate=None, inactivityAlert=None, clickNext=True):
        driver.select_frame(workOrders.woQueueIframe)
        workOrders._fill_information_for_work_order(self.editWOIframe, woName, summary, priority, technician, scheduling, onHold, earliestDate, latestDate, inactivityAlert)
        driver.select_frame(workOrders.woQueueIframe)
        self._select_iframe(self.editWOIframe, self.saveEditBtn)
        if clickNext:
            self.saveEditBtn.click_visible_element()
            self.saveEditBtn.wait_until_element_is_not_visible()
        driver.unselect_frame()
        
    def check_elements_are_disabled_on_edit_wo_information(self, woName=None, workType=None, createdBy=None, dateCreated=None, expectedDate=None,summary=None, priority=None, technician=None, scheduling=None, onHold=None, earliestDate=None, latestDate=None):
        driver.select_frame(workOrders.woQueueIframe)
        workOrders._check_elements_are_disabled_on_wo_information(self.editWOIframe, woName, workType, createdBy, dateCreated, expectedDate,summary, priority, technician, scheduling, onHold, earliestDate, latestDate)
        driver.unselect_frame()
        
    def is_work_order_name_txt_displayed(self):
        self._select_iframe(self.woIframe, workOrders.woNameTxt)
        isVisible = workOrders.woNameTxt.is_element_visible()  
        driver.unselect_frame()
        return isVisible
