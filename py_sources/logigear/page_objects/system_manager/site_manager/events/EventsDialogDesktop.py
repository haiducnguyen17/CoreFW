from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.elements.element import Element
from logigear.core.assertion import SeleniumAssert
import time
from logigear.core.config import constants

class EventsDialogDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.filterBtn = self.element("filterBtn")
        self.eventLogTbl = self.element("eventLogTbl")
        self.refreshBtn = self.element("refreshBtn")
        self.clearAllBtn = self.element("clearAllBtn")
        self.locateBtn = self.element("locateBtn")
        self.selectItemCbb = self.element("selectItemCbb")
        self.dynamicDescription = self.element("dynamicDescription")
        self.dynamicDateTime = self.element("dynamicDateTime")
        self.dynamicTextXpath = self.element("dynamicTextXpath")
        self.dynamicDescriptionWithTime = self.element("dynamicDescriptionWithTime")
        self.dynamicDescriptionWithoutTime = self.element("dynamicDescriptionWithoutTime")
        self.dynamicDescriptionWithTimeWithOutPosition = self.element("dynamicDescriptionWithTimeWithOutPosition")
        self.dynamicDescriptionWithoutTimeWithOutPosition = self.element("dynamicDescriptionWithoutTimeWithOutPosition")
        self.detailsBridgeXpath = self.element("detailsBridgeXpath")
        self.clearEventBtn = self.element("clearEventBtn")
        self.eventDesRows = self.element("eventDesRows")
        self.eventCollapseBtn = self.element("eventCollapseBtn")
        self.eventSubRows = self.element("eventSubRows")
    
    def _build_event_xpath (self, eventDescription, eventDateTime=None, position=1):
        self.dynamicDescription.arguments = [eventDescription]
        if (eventDateTime is not None and position is not None):
            self.dynamicDateTime.arguments = [eventDateTime]
            self.dynamicDescriptionWithTime.arguments = [self.dynamicDateTime.locator(), self.dynamicDescription.locator(), position]
            eventXpath = self.dynamicDescriptionWithTime
        elif (eventDateTime is None and position is not None):
            self.dynamicDescriptionWithoutTime.arguments = [self.dynamicDescription.locator(), position]
            eventXpath = self.dynamicDescriptionWithoutTime
        elif (eventDateTime is not None and position is None):
            self.dynamicDateTime.arguments = [eventDateTime]
            self.dynamicDescriptionWithTimeWithOutPosition.arguments = [self.dynamicDateTime.locator(), self.dynamicDescription.locator()]
            eventXpath = self.dynamicDescriptionWithTimeWithOutPosition
        elif (eventDateTime is None and position is None):
            self.dynamicDescriptionWithoutTimeWithOutPosition.arguments = [self.dynamicDescription.locator()]
            eventXpath = self.dynamicDescriptionWithoutTimeWithOutPosition
        return eventXpath
    
    def _does_event_exist(self, eventDescription, eventDateTime=None, position=1):
        eventPos = self._build_event_xpath(eventDescription, eventDateTime, position)
        self._select_iframe(self.secondIframe, self.refreshBtn)
        self._wait_for_processing()
        isEventExisted = eventPos.is_element_existed()
        driver.unselect_frame()
        
        return isEventExisted
    
    def _check_event_details(self, eventDetails, eventDescription, eventDateTime=None, position=1, delimiter="/"):
        textDetailsList = eventDetails.split(delimiter)
        detailsXpath = self.detailsBridgeXpath.locator()
        eventPos = self._build_event_xpath(eventDescription, eventDateTime, position)
        self.secondIframe.wait_until_page_contains_element()
        self._select_iframe(self.secondIframe, self.eventLogTbl)
        self.selectItemCbb.wait_until_element_is_visible()
        self.selectItemCbb.select_from_list_by_label(1000)
        
        self._expand_events()
            
        for text in textDetailsList:
            subDetails = detailsXpath
            self.dynamicTextXpath.arguments = [text]
            strTextXpath = self.dynamicTextXpath.locator()
            detailsXpath = subDetails + strTextXpath
            
        fullDetailsXpath = eventPos.locator() + detailsXpath
        SeleniumAssert.element_should_be_visible(Element(fullDetailsXpath))
        driver.unselect_frame()
    
    def _locate_event(self, eventDescription, eventDateTime=None, position=1):
        eventPos = self._build_event_xpath(eventDescription, eventDateTime, position)
        self._select_iframe(self.secondIframe, self.refreshBtn)
        eventPos.click_element()
        self.locateBtn.click_visible_element()
        self._wait_for_processing()
        driver.unselect_frame()
        
    def _clear_event(self, clearType, eventDescription=None, eventDateTime=None, position=1):
        self._select_iframe(self.secondIframe, self.refreshBtn)
        self._wait_for_processing()
        if clearType == 'All':
            self.clearAllBtn.click_visible_element()
        else:
            eventPos = self._build_event_xpath(eventDescription, eventDateTime, position)
            eventPos.click_element()
            self.clearEventBtn.click_visible_element()
        driver.unselect_frame()
        self.dialogOkBtn.click_visible_element()
    
    def _get_total_event(self):
        return len(self.eventDesRows.get_webelements())
    
    def _get_total_sub_row(self):
        return len(self.eventSubRows.get_webelements())
    
    def _get_number_of_event(self, eventDescription, eventDateTime=None, position=1):
        eventPos = self._build_event_xpath(eventDescription, eventDateTime, position)
        self._select_iframe(self.secondIframe, self.refreshBtn)
        self._wait_for_processing()
        numberEvent = len(eventPos.get_webelements())
        driver.unselect_frame()
        
        return numberEvent
    
    def _wait_for_events_expand(self, currentEvents, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            time.sleep(0.3)
            if self._get_total_sub_row() == currentEvents: 
                return True
            else:
                return False
            
    def _wait_for_events_collapse(self, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            time.sleep(0.3)
            if self._get_total_sub_row() == 0: 
                return True
            else:
                return False
            
    def _expand_events(self):
        temp = 0 
        currentEvents = self._get_total_event()
        while not self._get_total_sub_row() == currentEvents and temp < constants.SELENPY_DEFAULT_TIMEOUT:
            self.eventCollapseBtn.click_visible_element()
            time.sleep(0.3)
            if "Collapse" in self.eventCollapseBtn.get_element_attribute("class") and self._get_total_sub_row() == currentEvents:
                break
            temp += 1
            
    def _collapse_events(self):
        temp = 0 
        while not self._get_total_sub_row() == 0 and temp <= constants.SELENPY_DEFAULT_TIMEOUT:
            self.eventCollapseBtn.click_visible_element()
            time.sleep(0.3)
            if "Expand" in self.eventCollapseBtn.get_element_attribute("class") and self._get_total_sub_row() == 0:
                break
            temp += 1