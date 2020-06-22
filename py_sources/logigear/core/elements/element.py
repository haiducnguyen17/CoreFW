from logigear.core import elementKeywords, formElementKeywords, waitingKeywords, selectElementKeywords, \
    tableElementKeywords
from logigear.core.elements.base_element import BaseElement
from logigear.core.drivers import driver
from logigear.core.config import constants
from logigear.core.helpers import logger
import time
from selenium.common.exceptions import StaleElementReferenceException


class Element(BaseElement):
    
    """
        ElementKeywords
        
    """

    def get_webelement(self):
        return elementKeywords.get_webelement(self.locator())
    
    def get_webelements(self):
        return elementKeywords.get_webelements(self.locator())
    
    def get_element_attribute(self, attribute, count=constants.SELENPY_DEFAULT_TIMEOUT):
        temp = 0
        while temp < count: 
            try:
                return elementKeywords.get_element_attribute(self.locator(), attribute)
            except StaleElementReferenceException:
                temp += 1 

    def get_horizontal_position(self):
        return elementKeywords.get_horizontal_position(self.locator())

    def get_element_size(self):
        return elementKeywords.get_element_size(self.locator())

    def cover_element(self):
        elementKeywords.cover_element(self.locator())

    def get_value(self):
        return elementKeywords.get_value(self.locator())
        
    def get_text(self, count=constants.SELENPY_DEFAULT_TIMEOUT):
        temp = 0
        while temp < count: 
            try:
                return elementKeywords.get_text(self.locator())
            except StaleElementReferenceException:
                temp += 1 
        
    def clear_element_text(self):
        elementKeywords.clear_element_text(self.locator())

    def get_vertical_position(self):
        return elementKeywords.get_vertical_position(self.locator())

    def click_button(self, modifier=False):
        elementKeywords.click_button(self.locator(), modifier)

    def click_image(self, modifier=False):
        elementKeywords.click_image(self.locator(), modifier)
        
    def click_link(self, modifier=False):
        elementKeywords.click_link(self.locator(), modifier)

    def click_element(self, modifier=False, action_chain=False, count=constants.SELENPY_DEFAULT_TIMEOUT):
        temp = 0
        while temp < count:
            try:
                elementKeywords.click_element(self.locator(), modifier, action_chain)
                break
            except StaleElementReferenceException:
                temp += 1
        
    def click_element_by_js(self):
        driver.execute_javascript("arguments[0].click();", self.get_webelement())
    
    def double_click_element(self):
        elementKeywords.double_click_element(self.locator())
        
    def is_element_visible(self):
        try:
            return driver.execute_javascript("function isVisible(e){var t=e.getBoundingClientRect(),"
                                  +"n=document.elementFromPoint(t.x+t.width/2,t.y+t.height/2),"
                                  +"i=!1;for(let t=0;t<3;t++)e==n?i=!0:n=n.parentElement;return i}"
                                  +"return isVisible(arguments[0]);", self.get_webelement())
            
        except:
            return False
    
    def is_element_present(self):
        try:
            return self.get_webelement() is not None
        except:
            return False
    
    def is_element_existed(self):
        return self._return_running_method(elementKeywords.element_should_be_visible, self.locator())
    
    def is_element_enabled(self):
        return self._return_running_method(elementKeywords.element_should_be_enabled, self.locator())
    
    def is_element_active(self):
        return self.wait_until_element_is_active(1)
            
    def is_element_inactive(self):
        return self.wait_until_element_is_inactive(1)
        
    def mouse_over(self, count=constants.SELENPY_DEFAULT_TIMEOUT):
        temp = 0
        while temp < count: 
            try:
                elementKeywords.mouse_over(self.locator())
                break
            except StaleElementReferenceException:
                temp += 1
        
    def get_element_count(self):
        return elementKeywords.get_element_count(self.locator())
    
    def click_visible_element(self, modifier=False, action_chain=False, timeout=constants.SELENPY_DEFAULT_TIMEOUT, count=constants.SELENPY_DEFAULT_TIMEOUT):
        temp = 0
        while temp < count: 
            try:
                self.wait_until_element_is_visible(timeout)
                self.mouse_over()
                self.click_element(modifier, action_chain)
                break
            except StaleElementReferenceException:
                temp += 1
                  
    def click_enabled_element(self):
        self.wait_until_element_is_enabled(timeout=constants.SELENPY_OBJECT_WAIT)
        self.mouse_over()
        self.click_element()
    
    def return_wait_for_element_visible_status(self, timeOut=constants.SELENPY_DEFAULT_TIMEOUT):
        return self._return_running_method(self.wait_until_element_is_visible, timeOut)
    
    def return_wait_for_element_invisible_status(self, timeOut=constants.SELENPY_DEFAULT_TIMEOUT):
        return self._return_running_method(self.wait_until_element_is_not_visible, timeOut)
    
    def return_wait_for_enabled_element(self, timeOut=constants.SELENPY_DEFAULT_TIMEOUT):
        return self._return_running_method(self.wait_until_element_is_enabled, timeOut)
    
    def return_wait_for_disabled_element(self, timeOut=constants.SELENPY_DEFAULT_TIMEOUT):
        return self._return_running_method(self.wait_until_element_is_disabled, timeOut)

    def set_focus_to_element(self, count=constants.SELENPY_DEFAULT_TIMEOUT):
        logger.info("Set focus to element '{}'".format(self.locator()))
        temp = 0
        while temp < count: 
            try:
                elementKeywords.set_focus_to_element(self.locator())
                break
            except StaleElementReferenceException:
                temp += 1 
        
    def scroll_element_into_view(self):
        elementKeywords.scroll_element_into_view(self.locator())
        
    def drag_and_drop(self, target):
        elementKeywords.drag_and_drop(self.locator(), target)
    
    def drag_and_drop_by_offset(self, xOffSet, yOffSet):
        elementKeywords.drag_and_drop_by_offset(self.locator(), xOffSet, yOffSet)
        
    def mouse_down(self):
        elementKeywords.mouse_down(self.locator())
        
    def mouse_out(self):
        elementKeywords.mouse_out(self.locator())
    
    def mouse_up(self):
        elementKeywords.mouse_up(self.locator())
        
    def open_context_menu(self):
        elementKeywords.open_context_menu(self.locator())
        
    def simulate_event(self, event):
        elementKeywords.simulate_event(self.locator(), event)
        
    def press_keys(self, locator=None, *keys):
        """Simulates the user pressing key(s) to an element or on the active browser.


        If ``locator`` evaluates as false, see `Boolean arguments` for more
        details, then the ``keys`` are sent to the currently active browser.
        Otherwise element is searched and ``keys`` are send to the element
        identified by the ``locator``. In later case, keyword fails if element
        is not found. See the `Locating elements` section for details about
        the locator syntax.

        """
        elementKeywords.press_keys(locator, keys)
    
    def press_key(self, key):
        elementKeywords.press_key(self.locator(), key)
    
    def get_all_links(self):
        return elementKeywords.get_all_links()
    
    def mouse_down_on_link(self):
        elementKeywords.mouse_down_on_link(self.locator())
    
    def mouse_down_on_image(self):
        elementKeywords.mouse_down_on_image(self.locator())
        
    def add_location_strategy(self, strategy_name, strategy_keyword, persist=False):
        elementKeywords.add_location_strategy(strategy_name, strategy_keyword, persist)
        
    def remove_location_strategy(self, strategy_name):
        elementKeywords.remove_location_strategy(strategy_name)
        
    def parse_modifier(self, modifier):
        elementKeywords.parse_modifier(modifier)
        
    def click_element_if_exist(self):
        isElementExist = self.return_wait_for_element_visible_status()
        if isElementExist:
            self.click_visible_element()
            
    def click_element_if_enabled(self):
        isElementEnabled = self.is_element_enabled()
        if isElementEnabled:
            self.click_visible_element()
    
    def set_customize_attribute_for_element_by_js(self, attribute, value):
        """Please use xpath for the element you want to set value"""
        elementXpath = self.locator()
        positionXpath = elementXpath.find("xpath=")
        if positionXpath != -1:
            elementLocator = elementXpath[6:]
            driver.execute_javascript("document.evaluate(\"" + elementLocator + "\", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue."+ attribute +" = \"" + value + "\"")
        
    """
        WaitingElementKeywords
        
    """    

    def _return_running_method(self, functionName, *args):
        try:
            functionName(*args)
            return True
        except:
            return False
            
    def wait_until_element_contains(self, text, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until element '{}' contains '{}' in '{}'".format(self.locator(), text, timeout))
        waitingKeywords.wait_until_element_contains(self.locator(), text, timeout, error)
        
    def wait_until_element_does_not_contain(self, text, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until element '{}' does not contain '{}' in '{}'".format(self.locator(), text, timeout))
        waitingKeywords.wait_until_element_does_not_contain(self.locator(), text, timeout, error)
        
    def wait_until_element_is_visible(self, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until element '{}' is visible in '{}'".format(self.locator(), timeout))
        waitingKeywords.wait_until_element_is_visible(self.locator(), timeout, error)
       
    def wait_until_element_is_not_visible(self, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until element '{}' is not visible in '{}'".format(self.locator(), timeout))
        waitingKeywords.wait_until_element_is_not_visible(self.locator(), timeout, error)
        
    def wait_until_element_is_enabled(self, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until element '{}' is enabled in '{}'".format(self.locator(), timeout))
        waitingKeywords.wait_until_element_is_enabled(self.locator(), timeout, error)
    
    def wait_until_element_is_disabled(self, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until element '{}' is disabled in '{}'".format(self.locator(), timeout))
        waitingKeywords._wait_until(
            lambda: not waitingKeywords.is_element_enabled(self.locator()),
            "Element '%s' was not disabled in <TIMEOUT>." % self.locator(),
            timeout, error
        )
    
    def wait_until_page_contains_element(self, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until page contains element '{}' in '{}'".format(self.locator(), timeout))
        waitingKeywords.wait_until_page_contains_element(self.locator(), timeout, error)
        
    def wait_until_page_does_not_contain_element(self, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
        logger.info("Wait until page does not contains element '{}' in '{}'".format(self.locator(), timeout))
        waitingKeywords.wait_until_page_does_not_contain_element(self.locator(), timeout, error) 
    
    def wait_for_element_outer_html_not_change(self, timeout=constants.SELENPY_OBJECT_WAIT):
        logger.info("Wait for outer HTML of element '{}' not change in '{}'".format(self.locator(), timeout))
        curOuterHtml = self.get_element_attribute("outerHTML")
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            time.sleep(0.5)
            tmp = self.get_element_attribute("outerHTML")
            if tmp == curOuterHtml: break
            curOuterHtml = tmp
     
    def wait_until_element_attribute_contains(self, attribute, value, timeout=constants.SELENPY_OBJECT_WAIT):
        logger.info("Wait until attribute '{}' of element '{}' contains {} in '{}'".format(attribute, self.locator(), value, timeout))
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            time.sleep(0.3)
            attValue = self.get_element_attribute(attribute)
            if value in attValue: 
                return True  
        return False
        
    def wait_until_element_attribute_does_not_contain(self, attribute, value, timeout=constants.SELENPY_OBJECT_WAIT):
        logger.info("Wait until attribute '{}' of element '{}' does not contain {} in '{}'".format(attribute, self.locator(), value, timeout))
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            time.sleep(0.3)
            attValue = self.get_element_attribute(attribute)
            if value not in attValue: 
                return True        
        return False
          
    def wait_until_element_is_active(self, timeout=constants.SELENPY_OBJECT_WAIT):
        logger.info("Wait until element '{}' is active in {}".format(self.locator(), timeout))
        return self.wait_until_element_attribute_does_not_contain("class", "inactive", timeout)
            
    def wait_until_element_is_inactive(self, timeout=constants.SELENPY_OBJECT_WAIT):
        logger.info("Wait until element '{}' is inactive in {}".format(self.locator(), timeout))
        return self.wait_until_element_attribute_contains("class", "inactive", timeout)
    
    """
        FormElementKeywords
        
    """     

    def input_text(self, text, clear=True):
        if text is not None:
            if text != "":
                formElementKeywords.input_text(self.locator(), text, clear)
            else:
                self.set_focus_to_element()
                self.press_key("\\1")
                self.press_key("\\127")
    
    def input_password(self, password, clear=True):
        formElementKeywords.input_password(self.locator(), password, clear)
        
    def submit_form(self, locator=None):
        """Submits a form identified by ``locator``.

        If ``locator`` is not given, first form on the page is submitted.

        """
        formElementKeywords.submit_form(locator)
    
    def is_checkbox_selected(self):
        return self._return_running_method(formElementKeywords.checkbox_should_be_selected, self.locator())
        
    def select_checkbox(self, status=True):
        temp = 0
        if status:
            while self.is_checkbox_selected() is not status and temp < constants.SELENPY_DEFAULT_TIMEOUT:
                formElementKeywords.select_checkbox(self.locator())
                temp += 1
        else:
            while self.is_checkbox_selected() is not status and temp < constants.SELENPY_DEFAULT_TIMEOUT:
                formElementKeywords.unselect_checkbox(self.locator())
                temp += 1
    
    def select_radio_button(self, group_name, value):
        formElementKeywords.select_radio_button(group_name, value)
    
    def choose_file(self, file_path):
        formElementKeywords.choose_file(self.locator(), file_path)
    
    def is_checked(self):
        e = formElementKeywords._get_checkbox(self.locator())
        return e.is_selected();

    """
        SelectElementKeywords
        
    """

    def get_list_items(self, values=False):
        return selectElementKeywords.get_list_items(self.locator(), values)
        
    def get_selected_list_label(self):
        return selectElementKeywords.get_selected_list_label(self.locator())
        
    def get_selected_list_labels(self):
        return selectElementKeywords.get_selected_list_labels(self.locator())
        
    def get_selected_list_value(self):
        return selectElementKeywords.get_selected_list_value(self.locator())
    
    def get_selected_list_values(self):
        return selectElementKeywords.get_selected_list_values(self.locator())
        
    def select_all_from_list(self):
        selectElementKeywords.select_all_from_list(self.locator())
    
    def select_from_list_by_index(self, *indexes):
        selectElementKeywords.select_from_list_by_index(self.locator(), indexes)
        
    def select_from_list_by_value(self, *values):
        selectElementKeywords.select_from_list_by_value(self.locator(), values)
        
    def select_from_list_by_label(self, label):
        selectElementKeywords.select_from_list_by_label(self.locator(), str(label))
        
    def unselect_all_from_list(self):
        selectElementKeywords.unselect_all_from_list(self.locator())
        
    def unselect_from_list_by_index(self, *indexes):
        selectElementKeywords.unselect_from_list_by_index(self.locator(), indexes)
        
    def unselect_from_list_by_value(self, *values):
        selectElementKeywords.unselect_from_list_by_value(self.locator(), values)
        
    def unselect_from_list_by_label(self, *labels):
        selectElementKeywords.unselect_from_list_by_label(self.locator(), labels)
        
    """
        TableElementKeywords
        
    """

    def get_table_cell(self, row, column, loglevel='TRACE', count=constants.SELENPY_DEFAULT_TIMEOUT):
        temp = 0
        while temp < count: 
            try:
                return tableElementKeywords.get_table_cell(self.locator(), row, column, loglevel)
            except StaleElementReferenceException:
                temp += 1 
        
    def does_table_contain(self, expected, loglevel='TRACE'):
        return self._return_running_method(tableElementKeywords.table_should_contain(self.locator(), expected, loglevel))
