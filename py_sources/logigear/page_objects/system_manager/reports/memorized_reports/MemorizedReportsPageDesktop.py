from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.reports import report


class MemorizedReportsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)

    def view_memorized_report(self, reportName):
        self._select_iframe(self.uniqueIframe, report.viewReportTbl)
        returnRow = report.viewReportTbl._get_table_row_map_with_header("Name", reportName)
        report.viewReportTbl._click_table_cell(returnRow, 1)
        report.viewBtn.click_visible_element()
        driver.unselect_frame()
            
