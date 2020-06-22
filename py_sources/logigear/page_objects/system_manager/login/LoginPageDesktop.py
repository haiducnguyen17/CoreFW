from logigear.core.utilities import utils
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from time import sleep
import time

class LoginPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        self.usernameTxt = self.element("usernameTxt")
        self.passwordTxt = self.element("passwordTxt")
        self.signinBtn = self.element("signinBtn")
        self.restoreMessageDiv = self.element("restoreMessageDiv")

    def login(self, username, password):
        self.usernameTxt.wait_until_element_is_visible()
        self.usernameTxt.input_text(username)
        self.passwordTxt.input_password(password)
        self.signinBtn.click_element()
        
    def login_to_sm(self, username, password, timeout=1200):
        self.login(username, password)
        timeoutMil = time.time() + timeout
        while time.time() <= timeoutMil:
            if self.restoreMessageDiv.return_wait_for_element_visible_status(10):
                sleep(10)
                self.signinBtn.click_visible_element()
            else:
                break
        self.usernameTxt.wait_until_element_is_not_visible(30)
        """ Importing SiteManagerPage to close the register dialog """
        utils.get_page("SiteManagerPage").close_registration_dialog()
