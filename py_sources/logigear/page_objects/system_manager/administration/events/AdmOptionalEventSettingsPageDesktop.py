from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.administration import administration

class AdmOptionalEventSettingsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.trackPatchPlugInsertionsRemovalsCbb = self.element("trackPatchPlugInsertionsRemovalsCbb")
        self.trackButtonPressesChk = self.element("trackButtonPressesChk")
    
    def set_optional_event_setting(self, trackPatchPlugInsertionsRemovals, trackButtonPresses=True):
        self._select_iframe(self.uniqueIframe, self.trackPatchPlugInsertionsRemovalsCbb)
        if trackButtonPresses is not None:
            self.trackButtonPressesChk.wait_until_element_is_enabled()
            self.trackButtonPressesChk.select_checkbox(trackButtonPresses)

        self.trackPatchPlugInsertionsRemovalsCbb.select_from_list_by_label(trackPatchPlugInsertionsRemovals)     
        administration.saveBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        self.confirmDialogBtn.wait_until_element_is_not_visible()
        