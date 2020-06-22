from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.elements.table_element import TableElement


class AdmEmailServerPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.nameTxt = self.element("nameTxt")
        self.descriptionTxt = self.element("descriptionTxt")
        self.systemManagerEmailServerTbl = self.element("systemManagerEmailServerTbl")
        self.systemManagerEmailServerTbl.__class__ = TableElement
        self.emailFromTxt = self.element("emailFromTxt")
        self.emailServerTxt = self.element("emailServerTxt")
        self.smtpPortNumberTxt = self.element("smtpPortNumberTxt")
        self.AuthenticationChk = self.element("AuthenticationChk")
        self.saveBtn = self.element("saveBtn")
        self.dynamicEmailNameLbl = self.element("dynamicEmailNameLbl")
        self.deleteBtn = self.element("deleteBtn")
        
    def delete_email_server (self, emailServerName):
        self._select_iframe(self.uniqueIframe, self.systemManagerEmailServerTbl)
        emailRow = self.systemManagerEmailServerTbl._get_table_row_map_with_header("Name", emailServerName)
        if emailRow != 0:
            self.systemManagerEmailServerTbl._click_table_cell(emailRow, 1)
            self.deleteBtn.click_visible_element()
            self.dialogYesBtn.click_visible_element()
            if self.dialogYesBtn.return_wait_for_element_visible_status(3):
                self.dialogYesBtn.click_element()
            self.dynamicEmailNameLbl.arguments = [emailServerName]
            self.dynamicEmailNameLbl.wait_until_element_is_not_visible()            
        driver.unselect_frame() 
        
    def add_email_server (self, emailServerName, emailFrom, emailServer, emailServerDescription=None, smtpPortNumber=None, outGoingServerRequiresAuthentication=None):
        self._select_iframe(self.uniqueIframe, self.addBtn)
        self.addBtn.click_visible_element()
        self.nameTxt.wait_until_element_is_enabled()
        self.nameTxt.input_text(emailServerName)
        self.descriptionTxt.input_text(emailServerDescription)
        self.emailFromTxt.input_text(emailFrom)
        self.emailServerTxt.input_text(emailServer)
        self.smtpPortNumberTxt.input_text(smtpPortNumber)
        if outGoingServerRequiresAuthentication is not None:
            self.AuthenticationChk.select_checkbox(outGoingServerRequiresAuthentication)
        self.saveBtn.click_element()
        self.dynamicEmailNameLbl.arguments = [emailServerName]
        self.dynamicEmailNameLbl.wait_until_element_is_visible()  
        driver.unselect_frame()
        
