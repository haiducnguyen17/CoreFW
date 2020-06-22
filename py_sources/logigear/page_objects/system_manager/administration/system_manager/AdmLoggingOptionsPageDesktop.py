from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.administration import administration

class AdmLoggingOptionsPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        
    def clear_sm_logging_options(self, subFeature, checkboxes=None, selectedCheckboxes=None, clearingMethod=None, clearEntries=None, daysReminder=None, selectedDate=None, delimiter=","):
        administration._clear_sub_logging_options(subFeature, checkboxes, selectedCheckboxes, clearingMethod, clearEntries, daysReminder, selectedDate, delimiter)
