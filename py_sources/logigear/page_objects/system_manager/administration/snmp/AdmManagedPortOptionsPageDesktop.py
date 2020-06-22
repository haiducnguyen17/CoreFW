from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.assertion import SeleniumAssert

class AdmManagedPortOptionsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.dynamicManagedPortsLabel = self.element("dynamicManagedPortsLabel")
        
    def check_label_not_exist_on_managed_port_options (self,labelName):
        self.dynamicManagedPortsLabel.arguments = [labelName]
        SeleniumAssert.element_should_not_be_visible(self.dynamicManagedPortsLabel)