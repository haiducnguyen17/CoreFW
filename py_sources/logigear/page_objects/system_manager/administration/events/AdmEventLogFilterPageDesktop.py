from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert
from logigear.page_objects.system_manager.administration import administration
from logigear.core.elements.table_element import TableElement


class AdmEventLogFilterPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.nameTxt = self.element("nameTxt")
        self.eventTypeTable = self.element("eventTypeTable", TableElement)
        self.ipatchEventsTab = self.element("ipatchEventsTab")
        self.systemManagerEventsTab = self.element("systemManagerEventsTab")
        self.snmpEventsTab = self.element("snmpEventsTab")
        self.ipatchEventTable = self.element("ipatchEventTable")
        self.systemManagerEventsTable = self.element("systemManagerEventsTable")
        self.snmpEventsTable = self.element("snmpEventsTable")
        self.cancelBtn = self.element("cancelBtn")        
        self.dynamicEventsChk = self.element("dynamicEventsChk")
        self.dynamicEventsTab = self.element("dynamicEventsTab")
        self.dynamicEventsExpandTab = self.element("dynamicEventsExpandTab")
        self.dynamicEventsItem = self.element("dynamicEventsItem")
           
    def click_add_event_log_filter(self):
        self._select_iframe(self.uniqueIframe, self.eventTypeTable)
        self.addBtn.click_visible_element()
        self.nameTxt.wait_until_element_is_visible()
        driver.unselect_frame()
        
    def select_event_log_filter_tab (self, eventTab):
        self.dynamicEventsTab.arguments = [eventTab]
        self._select_iframe(self.uniqueIframe, self.dynamicEventsTab)
        self.dynamicEventsTab.click_visible_element()
        self.dynamicEventsExpandTab.arguments = [eventTab]
        self.dynamicEventsExpandTab.wait_until_element_is_visible()
        driver.unselect_frame()    
    
    def click_event_log_filter_page_save_button(self):
        self._select_iframe(self.uniqueIframe, self.confirmDialogBtn)
        self.confirmDialogBtn.click_visible_element()
        self.confirmDialogBtn.wait_until_element_is_visible()
        driver.unselect_frame()

    def click_event_log_filter_page_cancel_button(self):
        self._select_iframe(self.uniqueIframe, self.cancelBtn)        
        self.close_dialog()          
        driver.unselect_frame()
    
    def fill_data_in_add_event_log_filter(self, eventName=None, eventTab=None, events=None, save=False, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.nameTxt)
        self.nameTxt.input_text(eventName)
        if eventTab is not None:      
            self.dynamicEventsTab.arguments = [eventTab]                    
            self.dynamicEventsTab.click_visible_element()
            self.dynamicEventsExpandTab.arguments = [eventTab]
            self.dynamicEventsExpandTab.wait_until_element_is_visible()
        if events is not None:
            listEvents = events.split(delimiter)
            for event in listEvents:
                self.dynamicEventsChk.arguments = [event]
                self.dynamicEventsChk.select_checkbox(True)
        if save:
            self.confirmDialogBtn.click_visible_element()
            driver.unselect_frame()
            self.confirmDialogBtn.wait_until_element_is_visible()            
            self.confirmDialogBtn.click_visible_element()
        else:
            driver.unselect_frame()       
    
    def add_event_log_filter(self, eventName=None, eventTabs=None, events=None, save=False, delimiter=","):
        self.click_add_event_log_filter()
        self.fill_data_in_add_event_log_filter(eventName, eventTabs, events, save, delimiter)
    
    def edit_event_log_filter(self, eventName=None, newEventName=None, eventTabs=None, events=None, save=False, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.eventTypeTable)
        returnRow = self.eventTypeTable._get_table_row_map_with_header("Name", eventName, ",")
        self.eventTypeTable._click_table_cell(returnRow, 1)               
        administration.editBtn.click_visible_element()
        driver.unselect_frame()
        self.fill_data_in_add_event_log_filter(newEventName, eventTabs, events, save, delimiter)   
            
    def delete_event_log_filter(self, eventName=None):
        self._select_iframe(self.uniqueIframe, self.eventTypeTable)
        returnRow = self.eventTypeTable._get_table_row_map_with_header("Name", eventName, ",")
        if (returnRow != 0):
            self.eventTypeTable._click_table_cell(returnRow, 1)               
            administration.deleteBtn.click_visible_element()                       
            driver.unselect_frame()
            self.dialogOkBtn.wait_until_element_is_visible()                       
            self.dialogOkBtn.click_visible_element()     
            self.dialogOkBtn.wait_until_element_is_not_visible()       
        else:
            driver.unselect_frame()   
                    
    # Check Methods
    def _check_event_exist_state_in_add_event_log_filter(self, events, stateExist, delimiter=","):
        """"stateExist: True, False"""
        listEvents = events.split(delimiter)
        driver.select_frame(self.uniqueIframe)
        for event in listEvents: 
            self.dynamicEventsItem.arguments = [event]
            if stateExist:            
                SeleniumAssert.page_should_contain_element(self.dynamicEventsItem, self.dynamicEventsItem.locator() + " does not exist")
            else:
                SeleniumAssert.page_should_not_contain_element(self.dynamicEventsItem, self.dynamicEventsItem.locator() + " exists")
        driver.unselect_frame()
     
    def check_event_exist_in_add_event_log_filter(self, events, delimiter=","):
        self._check_event_exist_state_in_add_event_log_filter(events, True, delimiter)
            
    def check_event_not_exist_in_add_event_log_filter(self, events, delimiter=","):
        self._check_event_exist_state_in_add_event_log_filter(events, False, delimiter)
        
    def check_multiple_checkboxes_states_in_add_event_log_filter(self, events, enabled, selected, delimiter=","):
        """state: Enabled, Disabled, Selected, Unselected"""
        listEvents = events.split(delimiter)
        driver.select_frame(self.uniqueIframe)
        for event in listEvents:
            self.dynamicEventsChk.arguments = [event]    
            self._check_multiple_states_of_checkbox(self.dynamicEventsChk, enabled, selected)
        driver.unselect_frame()
