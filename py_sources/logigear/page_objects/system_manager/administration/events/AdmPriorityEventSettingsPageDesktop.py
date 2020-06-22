from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.assertion import Assert
from logigear.core.elements.table_element import TableElement
from logigear.page_objects.system_manager.administration import administration

class AdmPriorityEventSettingsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.selectAllBtn = self.element("selectAllBtn")
        self.eventsTbl = self.element("eventsTbl", TableElement) 
        self.priorityEventsTitle = self.element("priorityEventsTitle")
        self.dynamicPriorityChk = self.element("dynamicPriorityChk")
    
    def _check_event_exist_state_at_priority_event_settings(self, events, stateExist, delimiter=","):
        """"stateExist: True, False"""
        listEvents = events.split(delimiter)
        self._select_iframe(self.uniqueIframe, self.eventsTbl)
        for event in listEvents:
            eventRow = self.eventsTbl._get_table_row_map_with_header("Name" , event, ",")
            if stateExist:        
                Assert.should_be_true(eventRow > 0, event + " does not exist")
            else:
                Assert.should_be_true(eventRow == 0, event + " exists")
        driver.unselect_frame()
    
    def check_event_exist_at_priority_event_settings(self, events, delimiter=","):
        self._check_event_exist_state_at_priority_event_settings(events, True, delimiter)       
            
    def check_event_not_exist_at_priority_event_settings(self, events, delimiter=","):
        self._check_event_exist_state_at_priority_event_settings(events, False, delimiter)       

    def check_multiple_checkboxes_states_at_priority_event_settings(self, events, enabled, selected, delimiter=","):
        """state: Enabled, Disabled, Selected, Unselected"""
        listEvents = events.split(delimiter)
        self._select_iframe(self.uniqueIframe, self.eventsTbl)
        for event in listEvents:
            self.dynamicPriorityChk.arguments = [event]
            self._check_multiple_states_of_checkbox(self.dynamicPriorityChk, enabled, selected)
        driver.unselect_frame()
        
    def set_priority_event_checkbox(self, event, value=True):
        self._select_iframe(self.uniqueIframe, self.eventsTbl)
        self.dynamicPriorityChk.arguments = [event]
        self.dynamicPriorityChk.select_checkbox(value)
        administration.saveBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        self.confirmDialogBtn.wait_until_element_is_not_visible()