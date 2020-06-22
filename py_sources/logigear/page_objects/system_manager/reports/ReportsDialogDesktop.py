from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.table_element import TableElement


class ReportsDialogDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.reportsTab = self.element("reportsTab")
        self.memorizeReportsTab = self.element("memorizeReportsTab")
        self.reportArchiveTab = self.element("reportArchiveTab")
        self.dashboardsTab = self.element("dashboardsTab")
        self.addBtn = self.element("addBtn")
        self.editBtn = self.element("editBtn")
        self.viewBtn = self.element("viewBtn")
        self.deleteBtn = self.element("deleteBtn")
        self.viewReportTbl = self.element("viewReportTbl")
        self.viewReportTbl.__class__ = TableElement
        
