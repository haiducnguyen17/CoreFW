from logigear.core.config import constants
from logigear.core.utilities import utils 
from logigear.page_objects.sgmail.MailGeneralPage import MailGeneralPage
from logigear.core.assertion import SeleniumAssert
from logigear.core.elements.element import Element
import time
from logigear.data import Constants


class SgMailPageDesktop(MailGeneralPage):

    def __init__(self):
        MailGeneralPage.__init__(self)
        self.inboxFolderLbl = self.element("inboxFolderLbl")
        self.dynamicNewEmailTitle = self.element("dynamicNewEmailTitle")
        self.checkMessageBtn = self.element("checkMessageBtn")
        self.dynamicEmailDetails = self.element("dynamicEmailDetails")
        self.emailDetailsDiv = self.element("emailDetailsDiv")
        self.reportLinkEmailDiv = self.element("reportLinkEmailDiv")
        self.deleteBtn = self.element("deleteBtn")
            
    def wait_until_email_received(self, emailSubject, timeout=constants.SELENPY_EMAIL_RECEIVED_TIMEOUT):
        self.dynamicNewEmailTitle.arguments = [emailSubject]
        timeoutMil = time.time() + timeout
        while time.time() != timeoutMil:
            emailExist = self.dynamicNewEmailTitle.return_wait_for_element_visible_status(5)
            if emailExist:
                break
            elif time.time() >= timeoutMil:
                utils.fatal_error(emailSubject + " does not exist")
            self.checkMessageBtn.click_element_by_js()
        self.select_email(emailSubject)
                    
    def check_email_exist(self, emailSubject, details=None, timeout=constants.SELENPY_EMAIL_RECEIVED_TIMEOUT, delimiter=","):
        self.wait_until_email_received(emailSubject, timeout)
        if details is not None:
            detailsXpath = ""
            emailDetailslist = details.split(delimiter)
            for textDetails in emailDetailslist:
                self.dynamicEmailDetails.arguments = [textDetails]
                detailsXpath += self.dynamicEmailDetails.locator()
                fullEmailDetailsXpath = self.emailDetailsDiv.locator() + detailsXpath
            SeleniumAssert.element_should_be_visible(Element(fullEmailDetailsXpath))
    
    def get_report_link_in_email(self):
        self.reportLinkEmailDiv.return_wait_for_element_visible_status(Constants.OBJECT_WAIT_PROBE)
        return self.reportLinkEmailDiv.get_text()
    
    def select_email(self, emailSubject):
        self.dynamicNewEmailTitle.arguments = [emailSubject]
        self.dynamicNewEmailTitle.click_element_by_js()
        
    def delete_email(self, emailSubject):
        self.select_email(emailSubject)
        self.deleteBtn.click_element_by_js()