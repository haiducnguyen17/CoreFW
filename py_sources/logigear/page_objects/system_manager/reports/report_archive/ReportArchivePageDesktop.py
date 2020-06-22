from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.config import constants
from logigear.core.elements.table_element import TableElement


class ReportArchivePageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.archiveReportTbl = self.element ("archiveReportTbl")
        self.archiveReportTbl.__class__ = TableElement
        self.archiveReportListTbl = self.element("archiveReportListTbl")
        self.archiveReportListTbl.__class__ = TableElement
        self.dynamicArchiveReportChk = self.element("dynamicArchiveReportChk")
        self.archiveReportTitle = self.element("archiveReportTitle")

    def view_report_archive(self, reportName, reportArchive=None, timeOut=constants.SELENPY_SYNCSWITCH_TIMEOUT):
        self._select_iframe(self.uniqueIframe, self.archiveReportListTbl)
        returnRow = self.archiveReportListTbl._get_table_row_map_with_header("Name", reportName)
        self.archiveReportListTbl._click_table_cell(returnRow, 1)
        self.archiveReportTbl.wait_until_element_is_visible()
        self.dynamicArchiveReportChk.arguments = [reportArchive]
        self.dynamicArchiveReportChk.wait_until_element_is_visible(timeOut)
        self.dynamicArchiveReportChk.select_checkbox()
        self.viewBtn.click_visible_element()
        driver.unselect_frame()
        
