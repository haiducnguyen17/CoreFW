from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.table_element import TableElement
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert, Assert

class WorkOrderHistoryPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.woHistoryIframe = self.element("woHistoryIframe")
        self.woHistoryTbl = self.element("woHistoryTbl", TableElement)
        self.woHistoryDetailsTbl = self.element("woHistoryDetailsTbl", TableElement)

    def close_wo_history_window(self):
        self.close_dialog()
    
    def _get_table_row_map_with_header_on_wo_history_table(self, headers, values, delimiter=","):
        return self.woHistoryTbl._get_table_row_map_with_header(headers, values, delimiter)
    
    def expand_wo_in_wo_history(self, woName, currentStatus):
        self._select_iframe(self.woHistoryIframe, self.woHistoryTbl)
        inputValues = woName+","+currentStatus
        returnRow = self._get_table_row_map_with_header_on_wo_history_table("Work Order,Current Status", inputValues)
        self.woHistoryTbl._click_table_cell(returnRow,1,"double")
        driver.unselect_frame()
            
    def check_wo_history_data_line(self, row, headers, values, delimiter=","):        
        self._select_iframe(self.woHistoryIframe, self.woHistoryTbl)
        self.woHistoryDetailsTbl.check_row_table_with_data(headers, values, int(row) + 1, delimiter)
        driver.unselect_frame()

    def check_wo_history_information(self, woName, currentStatus):
        self._select_iframe(self.woHistoryIframe, self.woHistoryTbl)
        inputValues = woName+","+currentStatus
        returnRow = self._get_table_row_map_with_header_on_wo_history_table("Work Order,Current Status", inputValues)
        Assert.should_be_true(returnRow > 0)
        driver.unselect_frame()        