from logigear.core.helpers.base_page import BasePage
from logigear.core.config import constants

class QSGeneralPage(BasePage):
    
    def __init__(self):
        BasePage.__init__(self)
        self.dynamicNavigation = self.element("dynamicNavigation")
        
    def _go_to_sub_page(self, name):
        self.dynamicNavigation.arguments = [name]
        isActived = self.dynamicNavigation.get_element_attribute("class")
        temp = 0
        while(not "active" in isActived and temp < constants.SELENPY_DEFAULT_TIMEOUT):
            self.dynamicNavigation.click_visible_element()
            self.dynamicNavigation.wait_until_element_attribute_contains("class", "active")
            temp += 1