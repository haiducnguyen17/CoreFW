from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.assertion import SeleniumAssert
from logigear.core.drivers import driver
from logigear.core.utilities import utils

class WorkOrdersDialogDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.dynamicTaskName = self.element("dynamicTaskName")
        self.dynamicTaskType = self.element("dynamicTaskType")
        self.dynamicTaskTreeFrom = self.element("dynamicTaskTreeFrom")
        self.dynamicTaskConnectType = self.element("dynamicTaskConnectType")
        self.dynamicTaskTreeTo = self.element("dynamicTaskTreeTo")
        self.woNameTxt = self.element("woNameTxt")
        self.summaryTxt = self.element("summaryTxt")
        self.priorityCbb = self.element("priorityCbb")
        self.technicianCbb = self.element("technicianCbb")
        self.schedulingCbb = self.element("schedulingCbb")
        self.onHoldChk = self.element("onHoldChk")
        self.earliestDateTxt = self.element("earliestDateTxt")
        self.latestDateTxt = self.element("latestDateTxt")
        self.inactivityAlertChk = self.element("inactivityAlertChk")
        self.inactivityAlertTxt = self.element("inactivityAlertTxt")   
        self.woQueueIframe = self.element("woQueueIframe")
        self.expectedDateTxt = self.element("expectedDateTxt")
        self.dateCreatedTxt = self.element("dateCreatedTxt")
        self.createdByTxt = self.element("createdByTxt")
        self.workTypeTxt = self.element("workTypeTxt")
        self.additionalInformationTxt = self.element("additionalInformationTxt")
                        
    def _check_task_list_information(self, frame, position, name, taskType, treeFrom, connectionType, treeTo):
        self.dynamicTaskName.arguments = [position, name]
        self.dynamicTaskType.arguments = [position, taskType]
        self.dynamicTaskTreeFrom.arguments = [position, treeFrom]
        self.dynamicTaskConnectType.arguments = [position, connectionType]
        self.dynamicTaskTreeTo.arguments = [position, treeTo]
        driver.select_frame(frame)
        self.dynamicTaskTreeTo.mouse_over()
        SeleniumAssert.element_should_be_visible(self.dynamicTaskName)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskType)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskTreeFrom)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskConnectType)
        SeleniumAssert.element_should_be_visible(self.dynamicTaskTreeTo)
        driver.unselect_frame()    
        
    def _fill_information_for_work_order(self, frame, woName=None, summary=None, priority=None, technician=None, scheduling=None, onHold=False, earliestDate=None, latestDate=None, inactivityAlert=None):
        self._select_iframe(frame, self.woNameTxt)
        self._wait_for_processing()
        if woName is not None:
            self.woNameTxt.wait_until_element_is_enabled()
            self.woNameTxt.input_text(woName)
        if summary is not None:
            self.summaryTxt.input_text(summary)
        if priority is not None:
            self.priorityCbb.select_from_list_by_label(priority)          
        if technician is not None:
            self.technicianCbb.select_from_list_by_label(technician)
        if scheduling is not None:
            self.schedulingCbb.select_from_list_by_label(scheduling)
        if earliestDate is not None:
            self.earliestDateTxt.set_customize_attribute_for_element_by_js("value", earliestDate)
        if latestDate is not None:
            self.latestDateTxt.set_customize_attribute_for_element_by_js("value", latestDate)
        if inactivityAlert is not None:
            currentTime = utils.get_current_date_time(resultFormat="%Y-%m-%d")
            self.inactivityAlertChk.select_checkbox(inactivityAlert)
            self.inactivityAlertTxt.set_customize_attribute_for_element_by_js("value", currentTime)
        self.onHoldChk.select_checkbox(onHold)
        driver.unselect_frame()   
        
    def _check_elements_are_disabled_on_wo_information(self, frame, woName=None, workType=None, createdBy=None, dateCreated=None, expectedDate=None,summary=None, priority=None, technician=None, scheduling=None, onHold=None, earliestDate=None, latestDate=None):
        self._select_iframe(frame, self.woNameTxt)
        self._wait_for_processing()
        if woName is not None:
            SeleniumAssert.element_should_be_disabled(self.woNameTxt)
        if workType is not None:
            SeleniumAssert.element_should_be_disabled(self.workTypeTxt)            
        if summary is not None:
            SeleniumAssert.element_should_be_disabled(self.summaryTxt)
        if priority is not None:
            SeleniumAssert.element_should_be_disabled(self.priorityCbb)
        if technician is not None:
            SeleniumAssert.element_should_be_disabled(self.technicianCbb)
        if scheduling is not None:
            SeleniumAssert.element_should_be_disabled(self.schedulingCbb)
        if earliestDate is not None:
            SeleniumAssert.element_should_be_disabled(self.earliestDateTxt)
        if latestDate is not None:
            SeleniumAssert.element_should_be_disabled(self.latestDateTxt)
        if onHold is not None:
            SeleniumAssert.element_should_be_disabled(self.onHoldChk)
        if createdBy is not None:
            SeleniumAssert.element_should_be_disabled(self.createdByTxt)
        if dateCreated is not None:
            SeleniumAssert.element_should_be_disabled(self.dateCreatedTxt)
        if expectedDate is not None:
            SeleniumAssert.element_should_be_disabled(self.expectedDateTxt)                        
        driver.unselect_frame()           