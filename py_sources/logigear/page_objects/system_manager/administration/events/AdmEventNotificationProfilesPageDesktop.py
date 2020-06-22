from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.assertion import Assert
from logigear.core.elements.table_element import TableElement
from logigear.page_objects.system_manager.administration import administration


class AdmEventNotificationProfilesPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.previousStep1Btn = self.element("previousStep1Btn")
        self.nextStep1Btn = self.element("nextStep1Btn")
        self.nextOtherStepBtn = self.element("nextOtherStepBtn")
        self.previousOtherStepBtn = self.element("previousOtherStepBtn")
        self.submitBtn = self.element("submitBtn")
        self.limitNotificationTimeEmailBtn = self.element("limitNotificationTimeEmailBtn")
        self.limitNotificationTimeProgramBtn = self.element("limitNotificationTimeProgramBtn")
        self.eventProfileNameTxt = self.element("eventProfileNameTxt")
        self.eventProfileDescriptionTxt = self.element("eventProfileDescriptionTxt")
        self.editExecuteProgramImg = self.element("editExecuteProgramImg")
        self.sendEmailChk = self.element("sendEmailChk")
        self.overrideSubjectChk = self.element("overrideSubjectChk")
        self.includeEventDetailsChk = self.element("includeEventDetailsChk")
        self.limitNotificationTimeEmailChk = self.element("limitNotificationTimeEmailChk")
        self.executeLocalServerProgramChk = self.element("executeLocalServerProgramChk")
        self.limitNotificationTimeProgramChk = self.element("limitNotificationTimeProgramChk")
        self.useIntegrationServiceOnlyChk = self.element("useIntegrationServiceOnlyChk")
        self.sendTrapsChk = self.element("sendTrapsChk")
        self.overrideSubjectTxt = self.element("overrideSubjectTxt")
        self.executeLocalServerProgramTxt = self.element("executeLocalServerProgramTxt")
        self.limitNotificationTimeProgramTxt = self.element("limitNotificationTimeProgramTxt")
        self.destinationServerTxt = self.element("destinationServerTxt")
        self.emailServerCbb = self.element("emailServerCbb")
        self.recipientsTxt = self.element("recipientsTxt")
        self.programParametersTxt = self.element("programParametersTxt")
        self.profileLocationTree = self.element("profileLocationTree")
        self.profileEventsTbl = self.element("profileEventsTbl", TableElement)        
        self.profileTbl = self.element("profileTbl", TableElement)        
        self.selectAllChk = self.element("selectAllChk")
        self.dynamicProfileNameCell = self.element("dynamicProfileNameCell")
        self.sendEmailChk = self.element("sendEmailChk")
        self.emailSeverSlb = self.element("emailSeverSlb")
        self.recipientsTxt = self.element("recipientsTxt")
        self.dynamicEventChk = self.element("dynamicEventChk")
        self.deleteBtn = self.element("deleteBtn")
                    
    def select_events_in_event_notification_profiles(self, events, delimiter):
        if events == "All":
            self.selectAllChk.select_checkbox()
        else:
            eventsList = events.split(delimiter)
            for i in range(0, len(eventsList)):
                self.dynamicEventChk.arguments = [eventsList[i]]
                self.dynamicEventChk.select_checkbox()    
                self._wait_for_processing()
                
    def add_event_notification_profile(self, profileName=None, profileDescription=None, events=None, locationPath=None, integrationService=None, sendEmail=None, emailServer=None, recipients=None, submit=True, delimiter="/"):
        self._select_iframe(self.uniqueIframe, self.addBtn)
        self.addBtn.click_visible_element()
        self.eventProfileNameTxt.wait_until_element_is_visible()
        driver.unselect_frame()
        self.fill_event_notification_profile(profileName, profileDescription, events, locationPath, integrationService, sendEmail, emailServer, recipients, delimiter)        
        if submit:    
            self.submit_event_notification_profile(profileName)
                        
    def fill_event_notification_profile(self, profileName=None, profileDescription=None,
                                        events=None, locationPath=None, integrationService=None,
                                        sendEmail=None, emailServer=None, recipients=None, delimiter="/"):
        ### Step 1 - Input Name & Description ####
        driver.select_frame(self.uniqueIframe)        
        if profileName is not None or profileDescription is not None:
            self.eventProfileNameTxt.input_text(profileName)
            self.eventProfileDescriptionTxt.input_text(profileDescription)
            self.nextStep1Btn.click_visible_element()
            self._wait_for_processing()
            self.profileEventsTbl.wait_until_element_is_visible()
        
        ### Step 2 - Select Events ###
        if events is not None:
            self.select_events_in_event_notification_profiles(events, delimiter)
            self.nextOtherStepBtn.click_visible_element()
            self.profileLocationTree.wait_until_element_is_visible()  
        
        ### Step 3 - Select Location ###
        if locationPath is not None:             
            self._click_tree_node_checkbox(self.profileLocationTree, locationPath, delimiter)
            self.nextOtherStepBtn.click_visible_element()
            self.emailServerCbb.wait_until_element_is_visible()

        ### Step 4 - Input Information for Notification Method ###
        
        # ## For Integration Service
        if integrationService is not None:
            self.useIntegrationServiceOnlyChk
            
        # ## For Email
        if sendEmail is not None:
            self.sendEmailChk.select_checkbox(sendEmail)
            self.emailSeverSlb.select_from_list_by_label(emailServer)
            self.recipientsTxt.input_text(recipients)
            self.includeEventDetailsChk.select_checkbox()
        driver.unselect_frame()
            
    def delete_event_notification_profile(self, profileName):
        self._select_iframe(self.uniqueIframe, self.profileTbl)
        eventRow = self.profileTbl._get_table_row_map_with_header("Name" , profileName, ",")
        if eventRow != 0:
            self.profileTbl._click_table_cell(eventRow, 1)
            self.deleteBtn.click_visible_element()
            driver.unselect_frame()
            self.confirmDialogBtn.click_visible_element() 
            self._select_iframe(self.uniqueIframe, self.profileTbl)
        self.dynamicProfileNameCell.arguments = [profileName]
        self.dynamicProfileNameCell.wait_until_element_is_not_visible()            
        driver.unselect_frame() 
        
    def edit_event_notification_profile(self, profileName, profileDescription=None, events=None, locationPath=None, integrationService=None, sendEmail=None, emailServer=None, recipients=None, submit=True, delimiter="/"):
        self._select_iframe(self.uniqueIframe, self.addBtn)
        eventRow = self.profileTbl._get_table_row_map_with_header("Name" , profileName, ",")
        self.profileTbl._click_table_cell(eventRow, 1)
        administration.editBtn.click_visible_element()
        self.eventProfileNameTxt.wait_until_element_is_visible()
        if profileDescription is None:
            self.nextStep1Btn.click_visible_element()
            self._wait_for_processing()
            self.profileEventsTbl.wait_until_element_is_visible()
            driver.unselect_frame()
        else:
            driver.unselect_frame()
            self.fill_event_notification_profile(None, profileDescription, events, locationPath, integrationService, sendEmail, emailServer, recipients, delimiter)        
        if submit:    
            self.submit_event_notification_profile(profileName)
        
    def submit_event_notification_profile(self, profileName):
        self._select_iframe(self.uniqueIframe, self.submitBtn)
        self.submitBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        self._select_iframe(self.uniqueIframe, self.addBtn) 
        self.profileTbl.wait_until_element_is_visible()
        self.dynamicProfileNameCell.arguments = [profileName]
        self.dynamicProfileNameCell.wait_until_element_is_visible()
        driver.unselect_frame()

    # Check methods
    def check_event_exist_on_event_notification_profiles_page(self, eventNames, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.profileEventsTbl)
        listEventNames = eventNames.split(delimiter)
        for eventName in listEventNames:        
            eventRow = self.profileEventsTbl._get_table_row_map_with_header("Name" , eventName, ",")            
            Assert.should_be_true(eventRow > 0, eventName + " does not exist")
        driver.unselect_frame()
        
    def check_event_not_exist_on_event_notification_profiles_page(self, eventNames, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.profileEventsTbl)
        listEventNames = eventNames.split(delimiter)
        for eventName in listEventNames:
            eventRow = self.profileEventsTbl._get_table_row_map_with_header("Name" , eventName, ",")        
            Assert.should_be_true(eventRow == 0, eventName + " exists")
        driver.unselect_frame()

    def check_multiple_checkboxes_states_on_event_notification_profiles_page(self, events, enabled, selected, delimiter=","):
        """state: Enabled, Disabled, Selected, Unselected"""
        listEvents = events.split(delimiter)
        driver.select_frame(self.uniqueIframe)
        for event in listEvents:
            self.dynamicEventChk.arguments = [event]
            self._check_multiple_states_of_checkbox(self.dynamicEventChk, enabled, selected)
        driver.unselect_frame()
