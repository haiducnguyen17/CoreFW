from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.administration import administration

class AdmPortFieldsPageDesktop(GeneralPage):
    def __init__(self):
        GeneralPage.__init__(self)
        self.dynamicChk = self.element("dynamicChk")
        self.dynamicFieldLabelTxt = self.element("dynamicFieldLabelTxt")
        self.saveBtn = self.element("saveBtn")
    
    def _set_port_fields_checkbox(self, portField, status):
        if status is not None:
            self.dynamicChk.arguments = [portField]
            self.dynamicChk.select_checkbox(status)
    
    def _enter_field_label(self, portField, fieldLabel):
        self.dynamicFieldLabelTxt.arguments = [portField]        
        self.dynamicFieldLabelTxt.wait_until_element_is_enabled()
        self.dynamicFieldLabelTxt.input_text(fieldLabel)     
    
    def create_port_fields_data(self, connectionId=None, serviceTicketId=None, cordLength=None, cordType=None, cordColor=None, portField1=None, portField2=None, portField3=None, portField4=None, portField5=None, fieldLabel1=None, fieldLabel2=None, fieldLabel3=None, fieldLabel4=None, fieldLabel5=None):
        driver.select_frame(self.uniqueIframe)
        administration._wait_for_sub_page_display("Port Fields")                          
        self._set_port_fields_checkbox("Connection ID", connectionId)
        self._set_port_fields_checkbox("Service Ticket ID", serviceTicketId)
        self._set_port_fields_checkbox("Cord Length", cordLength)
        self._set_port_fields_checkbox("Cord Type", cordType)
        self._set_port_fields_checkbox("Cord Color", cordColor)
        portFieldList = ["Field 1", "Field 2", "Field 3", "Field 4", "Field 5"]       
        portFieldStatusList = [portField1, portField2, portField3, portField4, portField5]
        portFieldLabelList = [fieldLabel1, fieldLabel2, fieldLabel3, fieldLabel4, fieldLabel5]
        for i in range(len(portFieldList)):
            self._set_port_fields_checkbox(portFieldList[i], portFieldStatusList[i])
            self._enter_field_label(portFieldList[i], portFieldLabelList[i])
             
        self.saveBtn.click_visible_element()
        driver.unselect_frame()
        self.dialogOkBtn.click_visible_element()
        self.dialogOkBtn.wait_until_element_is_not_visible()
        
        
    