from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert

class AdmGeomapOptionsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.optionsFrame = self.element("optionsFrame")
        self.optionsLnk = self.element("optionsLnk")
        self.serverMapViewUrlTemplateTxt = self.element("serverMapViewUrlTemplateTxt")
        self.serverMapViewMaxZoomLevelTxt = self.element("serverMapViewMaxZoomLevelTxt")
        self.serverMapViewAttributionLinkText1Txt = self.element("serverMapViewAttributionLinkText1Txt")
        self.serverMapViewAttributionLinkText2Txt = self.element("serverMapViewAttributionLinkText2Txt")
        self.serverMapViewAttributionLinkText3Txt = self.element("serverMapViewAttributionLinkText3Txt")
        self.serverMapViewAttributionLinkUrllink1Txt = self.element("serverMapViewAttributionLinkUrllink1Txt")
        self.serverMapViewAttributionLinkUrllink2Txt = self.element("serverMapViewAttributionLinkUrllink2Txt")
        self.serverMapViewAttributionLinkUrllink3Txt = self.element("serverMapViewAttributionLinkUrllink3Txt")
        self.serverSatelliteViewUrlTemplateTxt = self.element("serverSatelliteViewUrlTemplateTxt")
        self.serverSatelliteViewMaxZoomLevelTxt = self.element("serverSatelliteViewMaxZoomLevelTxt")
        self.serverSatelliteViewAttributionLinkText1Txt = self.element("serverSatelliteViewAttributionLinkText1Txt")
        self.serverSatelliteViewAttributionLinkText2Txt = self.element("serverSatelliteViewAttributionLinkText2Txt")
        self.serverSatelliteViewAttributionLinkText3Txt = self.element("serverSatelliteViewAttributionLinkText3Txt")
        self.serverSatelliteViewAttributionLinkUrllink1Txt = self.element("serverSatelliteViewAttributionLinkUrllink1Txt")
        self.serverSatelliteViewAttributionLinkUrllink2Txt = self.element("serverSatelliteViewAttributionLinkUrllink2Txt")
        self.serverSatelliteViewAttributionLinkUrllink3Txt = self.element("serverSatelliteViewAttributionLinkUrllink3Txt")
        self.saveGeomapOptionsBtn = self.element("saveGeomapOptionsBtn")
        self.dynamicUseCustomGeomapServerChk = self.element("dynamicUseCustomGeomapServerChk")
    
    def fill_custom_geomap_map_view(self, urlTemplate=None, maxZoomLevel=None, attributeText1=None, attributeUrl1=None, attributeText2=None, attributeUrl2=None, attributeText3=None, attributeUrl3=None, save=False, confirm=False):
        self.dynamicUseCustomGeomapServerChk.arguments = ["Map"]
        self._select_iframe(self.uniqueIframe, self.dynamicUseCustomGeomapServerChk)
        self.dynamicUseCustomGeomapServerChk.select_checkbox()
        self.serverMapViewUrlTemplateTxt.input_text(urlTemplate)
        self.serverMapViewMaxZoomLevelTxt.input_text(maxZoomLevel)
        self.serverMapViewAttributionLinkText1Txt.input_text(attributeText1)
        self.serverMapViewAttributionLinkUrllink1Txt.input_text(attributeUrl1)
        self.serverMapViewAttributionLinkText2Txt.input_text(attributeText2)
        self.serverMapViewAttributionLinkUrllink2Txt.input_text(attributeUrl2)
        self.serverMapViewAttributionLinkText3Txt.input_text(attributeText3)
        self.serverMapViewAttributionLinkUrllink3Txt.input_text(attributeUrl3)
        if save:
            self.saveGeomapOptionsBtn.click_visible_element()
            driver.unselect_frame()            
            if confirm:
                self.confirmDialogBtn.click_visible_element()
        else:
            driver.unselect_frame()
      
    def fill_custom_geomap_satellite_view(self, urlTemplate=None, maxZoomLevel=None, attributeText1=None, attributeUrl1=None, attributeText2=None, attributeUrl2=None, attributeText3=None, attributeUrl3=None, save=False, confirm=False):
        self.dynamicUseCustomGeomapServerChk.arguments = ["Satellite"]
        self._select_iframe(self.uniqueIframe, self.dynamicUseCustomGeomapServerChk)
        self.dynamicUseCustomGeomapServerChk.select_checkbox()
        self.serverSatelliteViewUrlTemplateTxt.input_text(urlTemplate)
        self.serverSatelliteViewMaxZoomLevelTxt.input_text(maxZoomLevel)
        self.serverSatelliteViewAttributionLinkText1Txt.input_text(attributeText1)
        self.serverSatelliteViewAttributionLinkUrllink1Txt.input_text(attributeUrl1)
        self.serverSatelliteViewAttributionLinkText2Txt.input_text(attributeText2)
        self.serverSatelliteViewAttributionLinkUrllink2Txt.input_text(attributeUrl2)
        self.serverSatelliteViewAttributionLinkText3Txt.input_text(attributeText3)
        self.serverSatelliteViewAttributionLinkUrllink3Txt.input_text(attributeUrl3)
        if save:
            self.saveGeomapOptionsBtn.click_visible_element()
            driver.unselect_frame()            
            if confirm:
                self.confirmDialogBtn.click_visible_element()
        else:
            driver.unselect_frame()         
     
    def set_custom_geomap_server_map_view(self, status, save=False, confirm=False):
        self._set_custom_geomap_server(status, "Map", save, confirm)

    def set_custom_geomap_server_satellite_view(self, status, save=False, confirm=False):
        self._set_custom_geomap_server(status, "Satellite", save, confirm)

    def _set_custom_geomap_server(self, status, mapType="Map", save=False, confirm=False):
        self.dynamicUseCustomGeomapServerChk.arguments = [mapType]
        self._select_iframe(self.uniqueIframe, self.dynamicUseCustomGeomapServerChk)
        self.dynamicUseCustomGeomapServerChk.select_checkbox(status)
        if save:
            self.saveGeomapOptionsBtn.click_visible_element()            
        driver.unselect_frame()
        if confirm:
            self.confirmDialogBtn.click_visible_element()

    def check_custom_geomap_server_map_view_state(self, enabled=True):
        self.dynamicUseCustomGeomapServerChk.arguments = ["Map"]
        self._select_iframe(self.uniqueIframe, self.dynamicUseCustomGeomapServerChk)
        SeleniumAssert.element_should_be_enabled(self.dynamicUseCustomGeomapServerChk)
        if enabled:
            SeleniumAssert.element_should_be_enabled(self.serverMapViewUrlTemplateTxt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewMaxZoomLevelTxt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkText1Txt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkUrllink1Txt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkText2Txt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkUrllink2Txt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkText3Txt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkUrllink3Txt)                       
        else:
            SeleniumAssert.element_should_be_disabled(self.serverMapViewUrlTemplateTxt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewMaxZoomLevelTxt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkText1Txt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkUrllink1Txt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkText2Txt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkUrllink2Txt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkText3Txt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkUrllink3Txt)
        driver.unselect_frame()

    def check_custom_geomap_satellite_view_state(self, enabled=True):
        self.dynamicUseCustomGeomapServerChk.arguments = ["Satellite"]      
        self._select_iframe(self.uniqueIframe, self.dynamicUseCustomGeomapServerChk)
        SeleniumAssert.element_should_be_enabled(self.dynamicUseCustomGeomapServerChk)      
        if enabled:
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewUrlTemplateTxt)
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewMaxZoomLevelTxt)
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewAttributionLinkUrllink1Txt)
            SeleniumAssert.element_should_be_enabled(self.serverMapViewAttributionLinkUrllink1Txt)
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewAttributionLinkText2Txt)
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewAttributionLinkUrllink2Txt)
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewAttributionLinkText3Txt)
            SeleniumAssert.element_should_be_enabled(self.serverSatelliteViewAttributionLinkUrllink3Txt)                        
        else:
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewUrlTemplateTxt)
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewMaxZoomLevelTxt)
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewAttributionLinkUrllink1Txt)
            SeleniumAssert.element_should_be_disabled(self.serverMapViewAttributionLinkUrllink1Txt)
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewAttributionLinkText2Txt)
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewAttributionLinkUrllink2Txt)
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewAttributionLinkText3Txt)
            SeleniumAssert.element_should_be_disabled(self.serverSatelliteViewAttributionLinkUrllink3Txt)
        driver.unselect_frame()  
        
    def check_geomap_options_link_displays(self):
        SeleniumAssert.element_should_be_visible(self.optionsLnk) 
        
    def go_to_geomap_options(self):
        self.optionsLnk.click_visible_element()
        self._wait_for_processing()
        