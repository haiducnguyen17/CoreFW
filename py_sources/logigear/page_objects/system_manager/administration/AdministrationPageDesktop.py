from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver

class AdministrationPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        self.addBtn = self.element("addBtn")
        self.deleteBtn = self.element("deleteBtn")
        self.saveBtn = self.element("saveBtn")
        self.dynamicPageLabel = self.element("dynamicPageLabel")
        self.editBtn = self.element("editBtn")
        self.uploadFileTxt = self.element("uploadFileTxt")
        self.dynamicClearingMethodExpandBtn = self.element("dynamicClearingMethodExpandBtn")
        self.dynamicSelectedClearingMethod = self.element("dynamicSelectedClearingMethod")
        self.dynamicClearEntriesCbb = self.element("dynamicClearEntriesCbb")
        self.dynamicDaysReminderTxt = self.element("dynamicDaysReminderTxt")
        self.dynamicSelectedDateTxt = self.element("dynamicSelectedDateTxt")
        self.dynamicDeleteLoggingBtn = self.element("dynamicDeleteLoggingBtn")
        self.dynamicTrackLoggingChk = self.element("dynamicTrackLoggingChk")
        self.dynamicSelectedClearEntriesLi = self.element("dynamicSelectedClearEntriesLi")
        self.dynamicClearSelectedDateBtn = self.element("dynamicClearSelectedDateBtn")
        
    def _wait_for_sub_page_display(self, pageName):
        self.dynamicPageLabel.arguments = [pageName]
        self.dynamicPageLabel.wait_until_element_is_visible()
        
    def _clear_sub_logging_options(self, subFeature, checkboxes=None, selectedCheckboxes=None, clearingMethod=None, clearEntries=None, daysReminder=None, selectedDate=None, delimiter=","):
        driver.select_frame(self.uniqueIframe)
        if checkboxes is not None:
            listCheckbox = checkboxes.split(delimiter)
            listSelectedCheckbox = selectedCheckboxes.split(delimiter)
            for i in range(0, len(listCheckbox)):
                self.dynamicTrackLoggingChk.arguments = [listCheckbox[i]]
                self.dynamicTrackLoggingChk.select_checkbox(listSelectedCheckbox[i])
        if clearingMethod is not None:
            self.dynamicClearingMethodExpandBtn.arguments = [subFeature]
            self.dynamicClearingMethodExpandBtn.click_visible_element()
            self.dynamicSelectedClearingMethod.arguments = [subFeature, clearingMethod]
            self.dynamicSelectedClearingMethod.click_visible_element()
        if clearEntries is not None:
            self.dynamicClearEntriesCbb.arguments = [subFeature]
            self.dynamicSelectedClearEntriesLi.arguments = [subFeature, clearEntries]
            self.dynamicClearEntriesCbb.wait_until_element_is_visible()
            self.dynamicClearEntriesCbb.click_visible_element()
            self.dynamicSelectedClearEntriesLi.click_visible_element()
        if daysReminder is not None:
            self.dynamicDaysReminderTxt.arguments = [subFeature]
            self.dynamicDaysReminderTxt.wait_until_element_is_visible()
            self.dynamicDaysReminderTxt.set_customize_attribute_for_element_by_js("value", daysReminder)
        if selectedDate is not None:
            self.dynamicSelectedDateTxt.arguments = [subFeature]
            self.dynamicClearSelectedDateBtn.arguments = [subFeature]
            self.dynamicSelectedDateTxt.wait_until_element_is_visible()
            self.dynamicClearSelectedDateBtn.click_visible_element()
            self.dynamicSelectedDateTxt.input_text(selectedDate)
        self.dynamicDeleteLoggingBtn.arguments = [subFeature]
        self.dynamicDeleteLoggingBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        self.confirmDialogBtn.click_visible_element()
        
