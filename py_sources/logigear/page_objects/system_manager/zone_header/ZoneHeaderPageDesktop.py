from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.config import constants


class ZoneHeaderPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        self.logOutLnk = self.element("logOutLnk")
        self.dynamicMenuItem = self.element("dynamicMenuItem")
        self.dynamicSubItem = self.element("dynamicSubItem")
    
    def logout_sm(self):
        self.logOutLnk.click_visible_element()
        self.logOutLnk.wait_until_element_is_not_visible()
        
    def select_main_menu(self, listMenu=None, subItem=None, forceExit=True, delimiter="/"):
        """Enter Menu path E.g. Administration/Users"""  
        if listMenu is not None:
            listMenu = listMenu.split(delimiter)
            lengthMenu = len(listMenu)
            temp = 1
            for menu in listMenu:
                self.dynamicMenuItem.arguments = [menu]  
                if temp == lengthMenu:
                    self.dynamicMenuItem.click_visible_element()
                    self.dynamicMenuItem.wait_until_element_attribute_contains("class", "active", constants.SELENPY_DEFAULT_TIMEOUT)
                elif lengthMenu == 1:
                    count = 0
                    self.dynamicMenuItem.click_visible_element()
                    while not self.dynamicMenuItem.wait_until_element_attribute_contains("class", "active", constants.SELENPY_DEFAULT_TIMEOUT) and count < constants.SELENPY_DEFAULT_TIMEOUT:
                        self.dynamicMenuItem.click_visible_element()
                        self.dynamicMenuItem.wait_until_element_attribute_contains("class", "active", constants.SELENPY_DEFAULT_TIMEOUT)
                        count += 1
                else:
                    self.dynamicMenuItem.wait_until_element_is_visible()
                    self.dynamicMenuItem.mouse_over()
                    count = 0
                    while not self.dynamicMenuItem.wait_until_element_attribute_contains("class", "hover", constants.SELENPY_DEFAULT_TIMEOUT) and count < constants.SELENPY_DEFAULT_TIMEOUT:
                        self.dynamicMenuItem.mouse_over()
                        self.dynamicMenuItem.wait_until_element_attribute_contains("class", "hover", constants.SELENPY_DEFAULT_TIMEOUT)
                        count += 1
                doesDialogExist = self.dialogOkBtn.is_element_existed()
                if(doesDialogExist and forceExit):
                    self.dialogOkBtn.click_element()
                elif(doesDialogExist and forceExit == False):
                    self.dialogCancelBtn.click_element()
                temp += 1
        if subItem is not None:
            self.dynamicSubItem.arguments = [subItem]
            count = 0
            while not "select" in self.dynamicSubItem.get_element_attribute("class") and count < constants.SELENPY_DEFAULT_TIMEOUT:
                self.dynamicSubItem.click_visible_element()
                count += 1
        self._wait_for_processing()
    