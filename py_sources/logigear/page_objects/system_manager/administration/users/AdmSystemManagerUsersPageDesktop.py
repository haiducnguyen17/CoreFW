from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.table_element import TableElement
from logigear.page_objects.system_manager.administration import administration
from logigear.core.drivers import driver


class AdmSystemManagerUsersPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.userTbl = self.element("userTbl", TableElement)
        self.technicianChk = self.element("technicianChk")

    def get_table_row_map_with_header_on_user_table(self, headers, values, delimiter=","):
        return self.userTbl._get_table_row_map_with_header(headers, values, delimiter)
            
    def edit_user_information(self, username, technician):
        self._select_iframe(self.uniqueIframe, self.userTbl)
        returnRow = self.get_table_row_map_with_header_on_user_table("Username", username)
        self.userTbl._click_table_cell(returnRow,1)
        administration.editBtn.click_visible_element()
        self.technicianChk.select_checkbox(technician)
        self.confirmDialogBtn.click_visible_element()
        driver.unselect_frame()