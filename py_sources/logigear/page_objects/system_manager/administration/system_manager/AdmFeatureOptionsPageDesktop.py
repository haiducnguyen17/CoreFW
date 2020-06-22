from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.administration import administration


class AdmFeatureOptionsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.allowCrossZonePatchingChk = self.element("allowCrossZonePatchingChk")
        
    def set_feature_options(self, allowCrossZonePatching):
        self._select_iframe(self.uniqueIframe, self.allowCrossZonePatchingChk)
        self.allowCrossZonePatchingChk.select_checkbox(allowCrossZonePatching)
        administration.saveBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        self.confirmDialogBtn.wait_until_element_is_not_visible()       
