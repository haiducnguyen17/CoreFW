from logigear.core.utilities import utils
from logigear.page_objects.sgmail.MailGeneralPage import MailGeneralPage


class LoginSgMailPageDesktop(MailGeneralPage):
    
    def __init__(self):
        MailGeneralPage.__init__(self)
        self.mailUserNameTxt = self.element("mailUserNameTxt")
        self.mailPasswordTxt = self.element("mailPasswordTxt")
        self.privateComputerChk = self.element("privateComputerChk")
        self.mailSignInBtn = self.element("mailSignInBtn")

    def login_mail(self, username, password):
        self.mailUserNameTxt.wait_until_element_is_visible()
        self.mailUserNameTxt.input_text(username)
        self.mailPasswordTxt.input_password(password)
        self.privateComputerChk.click_element()
        self.mailSignInBtn.click_element()
        
    def login_to_sgmail(self, username, password):
        self.login_mail(username, password)
        self.mailUserNameTxt.wait_until_element_is_not_visible(timeout=60)
        # Importing SgMailPage for wait.
        utils.get_page("SgMailPage").inboxFolderLbl.wait_until_element_is_visible()
        
