from logigear.page_objects.system_manager.login.LoginPageDesktop import LoginPageDesktop

class LoginPageMobile(LoginPageDesktop):

    def __init__(self):
        LoginPageDesktop.__init__(self)
    

    def login_to_sm(self, username, password):
        self.txtUsername.input_text(username)
        self.txtPassword.input_password(password)
        self.btnSignin.click_element()
        
