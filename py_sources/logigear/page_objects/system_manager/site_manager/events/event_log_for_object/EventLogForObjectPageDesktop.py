from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.assertion import Assert
from logigear.page_objects.system_manager.site_manager.events import event


class EventLogForObjectPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
    
    def check_event_exist_on_event_log_for_object(self, eventDescription, eventDateTime=None, position=1):
        isExisted = event._does_event_exist(eventDescription, eventDateTime, position)
        Assert.should_be_equal(isExisted, True)
        
    def check_event_not_exist_on_event_log_for_object(self, eventDescription, eventDateTime=None, position=1):
        isExisted = event._does_event_exist(eventDescription, eventDateTime, position)
        Assert.should_be_equal(isExisted, False)        
            
    def check_event_details_on_event_log_for_object(self, eventDetails, eventDescription, eventDateTime=None, position=1, delimiter="/"):
        event._check_event_details(eventDetails, eventDescription, eventDateTime, position, delimiter)
        
    def close_event_log_for_object(self):
        self.close_dialog()
    
    def locate_event_on_event_log_for_object(self, eventDescription, eventDateTime=None, position=1):
        event._locate_event(eventDescription, eventDateTime, position)
        
    def clear_event_on_event_log_for_object(self, clearType, eventDescription=None, eventDateTime=None, position=1):
        event._clear_event(clearType, eventDescription, eventDateTime, position)