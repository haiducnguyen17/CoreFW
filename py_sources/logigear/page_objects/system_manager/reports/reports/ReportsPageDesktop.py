from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.elements.element import Element
from logigear.core.assertion import SeleniumAssert, Assert
from logigear.core.elements.table_element import TableElement
from logigear.page_objects.system_manager.reports import report
from logigear.core.utilities import utils
from logigear.core.config import constants
import time
from logigear.core.helpers import logger
from logigear.core.elements.tree_element import TreeElement


class ReportsPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.reportsTitle = self.element("reportsTitle")
        self.categoryTbl = self.element("categoryTbl")
        self.categoryTbl.__class__ = TableElement
        self.nextBtn = self.element("nextBtn")
        self.nameTxt = self.element("nameTxt")
        self.descriptionTxt = self.element("descriptionTxt")
        self.okBtn = self.element("okBtn")
        self.cancelBtn = self.element("cancelBtn")
        self.selectReportTbl = self.element("selectReportTbl")
        self.selectReportTbl.__class__ = TableElement
        self.ReportDialog = self.element("ReportDialog")
        self.yesConfirmLnk = self.element("yesConfirmLnk")
        self.noConfirmLnk = self.element("noConfirmLnk")
        self.confirmDialog = self.element("confirmDialog")
        self.yesGenerateLnk = self.element("yesGenerateLnk")
        self.noGenerateLnk = self.element("noGenerateLnk")
        self.dynamicCategoryReportType = self.element("dynamicCategoryReportType")
        self.dynamicTextFilter = self.element("dynamicTextFilter")
        self.dynamicSelectFilter = self.element("dynamicSelectFilter")
        self.locationTreeDiv = self.element("locationTreeDiv", TreeElement)
        self.dateFilterCbb = self.element("dateFilterCbb")
        self.earliestDateTxt = self.element("earliestDateTxt")
        self.latestDateTxt = self.element("latestDateTxt")
        self.editLayoutContentTbl = self.element("editLayoutContentTbl")
        self.editLayoutContentTbl.__class__ = TableElement
        self.okViewReportBtn = self.element("okViewReportBtn")
        self.printBtn = self.element("printBtn")
        self.emailReportBtn = self.element("emailReportBtn")
        self.memorizeReportBtn = self.element("memorizeReportBtn")
        self.reportHeaderTbl = self.element("reportHeaderTbl")
        self.reportContentTbl = self.element("reportContentTbl")
        self.reportSaveBtn = self.element("reportSaveBtn")
        self.reportCancelBtn = self.element("reportCancelBtn")
        self.reportNameTxt = self.element("reportNameTxt")
        self.reportDescriptionTxt = self.element("reportDescriptionTxt")
        self.accessCbb = self.element("accessCbb")
        self.scheduleReportChk = self.element("scheduleReportChk")
        self.emailReportsChk = self.element("emailReportsChk")
        self.hoursTxt = self.element("hoursTxt")
        self.minutesTxt = self.element("minutesTxt")
        self.emailServerCbb = self.element("emailServerCbb")
        self.recipientsTxt = self.element("recipientsTxt")
        self.subjectTxt = self.element("subjectTxt")
        self.messageTxt = self.element("messageTxt")
        self.locationSaveReportPath = self.element("locationSaveReportPath")
        self.memorizeDurationTxt = self.element("memorizeDurationTxt")
        self.headEventReportRow = self.element("headEventReportRow")
        self.dynamicEventReportInfo = self.element("dynamicEventReportInfo")
        self.dynamicEventReportDetails = self.element("dynamicEventReportDetails")
        self.editLayoutHeaderFooterLeftDiv = self.element("editLayoutHeaderFooterLeftDiv")
        self.editLayoutContentLeftDiv = self.element("editLayoutContentLeftDiv")
        self.dynamicItemSource = self.element("dynamicItemSource")
        self.editLayoutHeaderTbl = self.element("editLayoutHeaderTbl")
        self.editLayoutHeaderTbl.__class__ = TableElement
        self.editLayoutFooterTbl = self.element("editLayoutFooterTbl")
        self.editLayoutFooterTbl.__class__ = TableElement
        self.dynamicItemDestination = self.element("dynamicItemDestination")
        self.dynamicExpandedItemSource = self.element("dynamicExpandedItemSource")
        self.reportTbl = self.element("reportTbl")
        self.reportTbl.__class__ = TableElement
        self.dynamicLabelSelectFilter = self.element("dynamicLabelSelectFilter")
        self.dynamicMultiSelectAddBtn = self.element("dynamicMultiSelectAddBtn")
        self.dynamicMultiSelectRemoveBtn = self.element("dynamicMultiSelectRemoveBtn")
        self.dynamicMultiSelectRemoveAllBtn = self.element("dynamicMultiSelectRemoveAllBtn")
        self.dynamicMultiSelectAddAllBtn = self.element("dynamicMultiSelectAddAllBtn")
        self.dynamicObjectMultiSelect = self.element("dynamicObjectMultiSelect")
        self.dynamicMultiSelectFilter = self.element("dynamicMultiSelectFilter")
        self.dynamicComboboxFilter = self.element("dynamicComboboxFilter")

    def view_report(self, reportName):
        self._select_iframe(self.uniqueIframe, self.reportTbl)
        returnRow = self.reportTbl._get_table_row_map_with_header("Name", reportName)
        self.reportTbl._click_table_cell(returnRow, 1)
        report.viewBtn.click_visible_element()
        self._wait_for_processing()
        driver.unselect_frame()
    
    def add_report(self, reportCategory, reportType, name, description=None, sourcePane=None, destinationPane=None, items=None, destinationItem=None, editLayout=False, delimiter=",", confirm=True):
        self.select_category_report_to_add (reportCategory, reportType)
        if editLayout:
            self.edit_layout_reports(sourcePane, destinationPane, items, destinationItem, delimiter)
        self._select_iframe(self.uniqueIframe, self.nextBtn)
        self.nextBtn.click_visible_element()
        self.nameTxt.wait_until_element_is_visible()
        self.nameTxt.input_text(name)
        self.descriptionTxt.input_text(description)
        self.okBtn.click_visible_element()
        self.yesGenerateLnk.wait_until_element_is_visible()
        if confirm:
            self.yesGenerateLnk.click_visible_element()
        else:
            self.noGenerateLnk.click_visible_element()
        self._wait_for_processing()
        driver.unselect_frame() 

    def delete_report (self, reportName):
        self._select_iframe(self.uniqueIframe, self.reportTbl)
        returnRow = self.reportTbl._get_table_row_map_with_header("Name", reportName)
        if (returnRow != 0):
            self.reportTbl._click_table_cell(returnRow, 1)
            report.deleteBtn.click_visible_element()
            self.dialogYesBtn.click_visible_element()
        driver.unselect_frame()
    
    def _set_arguments_for_dynamic_label(self, value):
        typeAndValue = value.split(":")
        self.dynamicLabelSelectFilter.arguments = [typeAndValue[0]]
        self.dynamicLabelSelectFilter.wait_until_element_is_visible()
            
        return [self.dynamicLabelSelectFilter, typeAndValue[1]]
    
    def _toggle_add_state_of_multiple_options_on_select_box(self, multiSelect, delimiter=";", state="add"):
        """state: add, remove"""
        listMultiSelect = multiSelect.split(delimiter)
        for multiSelect in listMultiSelect:
            elementAndValues = self._set_arguments_for_dynamic_label(multiSelect)
            if elementAndValues[1] == "all":
                if state == "add":
                    self.dynamicMultiSelectAddAllBtn.arguments = [elementAndValues[0].locator()]
                    self.dynamicMultiSelectAddAllBtn.click_visible_element()
                else:
                    self.dynamicMultiSelectRemoveAllBtn.arguments = [elementAndValues[0].locator()]
                    self.dynamicMultiSelectRemoveAllBtn.click_visible_element()
            else:
                listValue = elementAndValues[1].split(",")
                for value in listValue:
                    self.dynamicMultiSelectFilter.arguments = [elementAndValues[0].locator(), value]
                    self.dynamicMultiSelectFilter.click_visible_element()
                if state == "add":
                    self.dynamicMultiSelectAddBtn.arguments = [elementAndValues[0].locator()]
                    self.dynamicMultiSelectAddBtn.click_visible_element()
                else:    
                    self.dynamicMultiSelectRemoveBtn.arguments = [elementAndValues[0].locator()]
                    self.dynamicMultiSelectRemoveBtn.click_visible_element()
    
    def check_object_state_on_multiple_select_filter(self, label, objects, containPosition="Available", delimiter=",", state="exist"):
        """state: exist, non-exist"""
        self._select_iframe(self.uniqueIframe, self.locationTreeDiv)
        self.dynamicLabelSelectFilter.arguments = [label]
        listObject = objects.split(delimiter)
        for i in listObject:
            self.dynamicObjectMultiSelect.arguments = [self.dynamicLabelSelectFilter.locator(), containPosition, i]
            if state == "exist":
                SeleniumAssert.element_should_be_visible(self.dynamicObjectMultiSelect)
            else:
                SeleniumAssert.element_should_not_be_visible(self.dynamicObjectMultiSelect)
        driver.unselect_frame() 
    
    def check_object_not_exist_on_multiple_select_filter(self, label, objects, containPosition="Available", delimiter=","):
        self.check_object_state_on_multiple_select_filter(label, objects, containPosition, delimiter, "non-exist")
       
    def check_object_exist_on_multiple_select_filter(self, label, objects, containPosition="Available", delimiter=","):
        self.check_object_state_on_multiple_select_filter(label, objects, containPosition, delimiter, "exist")
   
    def check_object_exist_on_combo_box_filter(self, label, objects, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.locationTreeDiv)
        listObject = objects.split(delimiter)
        for i in listObject:
            self.dynamicComboboxFilter.arguments = [label, i]
            SeleniumAssert.element_should_be_visible(self.dynamicComboboxFilter)
        driver.unselect_frame()
        
    def select_filter_for_report (self, dateFilter=None, earliestDate=None, latestDate=None, textFilter=None, selectFilter=None, removeMultiSelectFilter=None, addMultiSelectFilter=None, selectLocationType=None, treeNode=None, delimiter=";", delimiterTree="/", clickViewBtn=False):
        """
        - Format for 'earliestDate' and 'latestDate' is yyyy-mm-dd.
        - textFilter is used for input to multiple textbox on select filter
        - selectFilter is used to select value for multiple combobox on select filter
        - removeMultiSelectFilter, addMultiSelectFilter is used to select multiple options for multiple multi selectbox on select filter
        """
        self._select_iframe(self.uniqueIframe, self.locationTreeDiv)
            
        if dateFilter is not None:
            self.dateFilterCbb.select_from_list_by_label(dateFilter)   
        if earliestDate is not None:
            self.earliestDateTxt.set_customize_attribute_for_element_by_js("value", earliestDate)    
        if latestDate is not None:
            self.latestDateTxt.set_customize_attribute_for_element_by_js("value", latestDate)
            
        if textFilter is not None:
            listText = textFilter.split(delimiter)
            for text in listText:
                elementAndValue = self._set_arguments_for_dynamic_label(text)
                self.dynamicTextFilter.arguments = [elementAndValue[0].locator()]
                self.dynamicTextFilter.mouse_over()
                self.dynamicTextFilter.input_text(elementAndValue[1])
                
        if selectFilter is not None:
            listSelect = selectFilter.split(delimiter)
            for select in listSelect:
                elementAndValue = self._set_arguments_for_dynamic_label(select)
                self.dynamicSelectFilter.arguments = [elementAndValue[0].locator()]
                self.dynamicSelectFilter.mouse_over()
                self.dynamicSelectFilter.select_from_list_by_label(elementAndValue[1])
        
        if removeMultiSelectFilter is not None:
            self._toggle_add_state_of_multiple_options_on_select_box(removeMultiSelectFilter, delimiter, "remove")
                
        if addMultiSelectFilter is not None:
            self._toggle_add_state_of_multiple_options_on_select_box(addMultiSelectFilter, delimiter, "add")
         
        if selectLocationType == "Check":
            treeNodesList = treeNode.split(delimiter)
            for treeNodes in treeNodesList:
                self.locationTreeDiv.mouse_over()
                self.locationTreeDiv.click_tree_node_check_box(treeNodes, delimiterTree)   
        elif selectLocationType == "Click":
            self.locationTreeDiv.mouse_over()
            self.locationTreeDiv.click_tree_node(treeNode, delimiterTree)
        
        if clickViewBtn:
            report.viewBtn.click_visible_element()
            self._wait_for_processing()
        driver.unselect_frame()
        
    def select_category_report_to_add (self, reportCategory, reportType=None):
        self._select_iframe(self.uniqueIframe, self.reportTbl)
        report.addBtn.click_visible_element()
        self.dynamicCategoryReportType.arguments = [reportCategory]
        self.dynamicCategoryReportType.click_visible_element()
        self.selectReportTbl.wait_until_element_is_visible()
        if reportType is not None:
            self.dynamicCategoryReportType.arguments = [reportType]
            self.dynamicCategoryReportType.click_visible_element()
        self._wait_for_processing()
        driver.unselect_frame()
        
    def click_add_report_button(self):
        self._select_iframe(self.uniqueIframe, self.reportTbl)
        self.addBtn.click_visible_element()
        driver.unselect_frame()
        
    def check_report_category_exist(self, checkedPage, reportCategory, reportDescription):
        """Use to check the Category and Description of the report.
    ...    We have 3 arguments:
    ...    - 'checkedPage': Page contain category report.
    ...    - 'reportCategory': Report Category
    ...    - 'reportDescription': Report Description"""
        
        self._select_iframe(self.uniqueIframe, self.selectReportTbl)
        columnName = checkedPage + "--Description"
        reportCat = reportCategory + "--" + reportDescription
        returnRow = self.selectReportTbl._get_table_row_map_with_header(columnName, reportCat, "--")
        Assert.should_be_true(returnRow > 0, "Category Report do not displays correctly.")
        driver.unselect_frame()
    
    def check_report_data_line(self, row, headers, values, delimiter=","):        
        self._select_iframe(self.uniqueIframe, report.viewReportTbl)
        report.viewReportTbl.check_row_table_with_data(headers, values, int(row) + 1, delimiter)
        driver.unselect_frame()
        
    def check_event_report_exist (self, eventInformation, eventDetails, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.reportContentTbl)
        self._wait_for_processing(3)
        textInformationList = eventInformation.split(delimiter)
        textDetailsList = eventDetails.split(delimiter)
        eventRowDiv = self.headEventReportRow.locator()
        infoXpath = ""
        detailsXpath = ""
        
        for textInfo in textInformationList:
            self.dynamicEventReportInfo.arguments = [textInfo]
            infoXpath += self.dynamicEventReportInfo.locator()
        fullInfoXpath = eventRowDiv + infoXpath
        
        for textDetails in textDetailsList:
            self.dynamicEventReportDetails.arguments = [textDetails]
            detailsXpath += self.dynamicEventReportDetails.locator()
        fullEventReportXpath = fullInfoXpath + detailsXpath
        SeleniumAssert.element_should_be_visible(Element(fullEventReportXpath))
        driver.unselect_frame()
        
    def create_memorize_report (self, reportName, reportDescription, reportAccess=None, scheduleReport=False, scheduleHours=None, scheduleMinutes=None, durationArchiveReport=None, emailServer=None, emailRecipients=None, emailsubject=None, emailMessage=None):
        self._select_iframe(self.uniqueIframe, self.memorizeReportBtn)
        self.memorizeReportBtn.click_element()
        self.reportNameTxt.wait_until_element_is_visible()
        self.reportNameTxt.input_text(reportName)
        self.reportDescriptionTxt.input_text(reportDescription)
        if reportAccess is not None:
            self.accessCbb.select_from_list_by_label(reportAccess)
        if scheduleReport:
            self.scheduleReportChk.select_checkbox(scheduleReport)  
            self.hoursTxt.wait_until_element_is_enabled()
            self.hoursTxt.input_text(scheduleHours)  
            self.minutesTxt.input_text(scheduleMinutes)
        self.memorizeDurationTxt.input_text(durationArchiveReport)
        if emailServer is not None:
            self.emailReportsChk.select_checkbox()
            self.emailServerCbb.wait_until_element_is_enabled()
            self.emailServerCbb.select_from_list_by_label(emailServer)
            self.recipientsTxt.input_text(emailRecipients)
            self.subjectTxt.input_text(emailsubject)
            self.messageTxt.input_text(emailMessage)
        self.reportSaveBtn.click_element()
        self.reportNameTxt.wait_until_element_is_not_visible()
        driver.unselect_frame()
        
    def send_email_report (self, emailServer, recipients, subject, message):
        self._select_iframe(self.uniqueIframe, self.emailReportBtn)
        self.emailReportBtn.click_visible_element()
        self.emailServerCbb.wait_until_element_is_visible()
        self.recipientsTxt.set_focus_to_element()
        self.emailServerCbb.select_from_list_by_label(emailServer)
        self.recipientsTxt.input_text(recipients)
        self.subjectTxt.input_text(subject)
        self.messageTxt.input_text(message)
        self.reportSaveBtn.click_element()
        self._wait_for_processing()
        driver.unselect_frame()
    
    def get_print_report_file(self):
        return  self._get_latest_download_file_name()

    def edit_layout_reports(self, sourcePane, destinationPane, items, destinationItem, delimiter=","):
        """'sourcePane': HeaderFooterLeft, ContentLeft, Header, Content, Footer
    ...    'destinationPane': Header, Content, Footer, HeaderFooterLeft, ContentLeft
    ...    'items': one or many items. Each item can be unique item or expanded items (ex: items=Rack,Configuration->Port Configuration,Configuration->Service 01) 
    ...    'destinationItem': the position you want to drop"""
        
        self._select_iframe(self.uniqueIframe, self.editLayoutHeaderFooterLeftDiv)
        
        sourcePaneXpath = self.define_layout_pane_xpath(sourcePane)
        
        destinationPaneXpath = self.define_layout_pane_xpath(destinationPane)
        destinationElement = self.build_layout_item_element(destinationPaneXpath, "Destination", destinationItem)

        listItem = items.split(delimiter)
        for item in listItem:
            isEpandedItemExisted = "->" in item
            if isEpandedItemExisted:
                sourceElement = self.return_expand_layout_item(sourcePaneXpath, item)
                sourceElement.wait_until_element_is_visible()
                sourceElement.mouse_over()
                sourceElement.drag_and_drop(destinationElement.locator())
            else:
                sourceElement = self.build_layout_item_element(sourcePaneXpath, "Source", item)
                sourceElement.drag_and_drop(destinationElement.locator())
        driver.unselect_frame()
        
    def remove_layout_items(self, pane, items, delimiter=","):
        """pane: Header, Content, Footer"""
        self._select_iframe(self.uniqueIframe, self.editLayoutHeaderFooterLeftDiv)
        paneXpath = self.define_layout_pane_xpath(pane)
        listItem = items.split(delimiter)
        for item in listItem:
            itemElement = self.build_layout_item_element(paneXpath, "Source", item)
            removeBtnXpath = itemElement.locator() + "/following::input[1]"
            Element(removeBtnXpath).click_visible_element()
        driver.unselect_frame()
        
    def check_report_link_recieved_via_email(self, userName, passWord):
        timeOut = constants.SELENPY_SYNCSWITCH_TIMEOUT
        utils.get_page("LoginPage").login(userName, passWord)
        for i in range(0, timeOut):
            report.viewReportTbl.is_element_visible()
            if i == timeOut:
                utils.fatal_error("does not exist")
        i += 1
        
    def print_report(self):
        self._select_iframe(self.uniqueIframe, self.printBtn)
        self.printBtn.click_visible_element()
        driver.unselect_frame()
    
    def define_layout_pane_xpath(self, pane):
        """'pane: 5 options: HeaderFooterLeft, ContentLeft, Header, Content, Footer"""
        if pane == "HeaderFooterLeft":
            paneXpath = self.editLayoutHeaderFooterLeftDiv.locator()
        elif pane == "ContentLeft":
            paneXpath = self.editLayoutContentLeftDiv.locator()
        elif pane == "Header":
            paneXpath = self.editLayoutHeaderTbl.locator()
        elif pane == "Content":
            paneXpath = self.editLayoutContentTbl.locator()
        else:
            paneXpath = self.editLayoutFooterTbl.locator()
        
        return paneXpath

    def build_layout_item_element(self, paneXpath, typePane, item):
        """'pane: 5 options: HeaderFooterLeft, ContentLeft, Header, Content, Footer
            typePane: Source, Destination"""
       
        if typePane == "Source":
            self.dynamicItemSource.arguments = [paneXpath, item]
            itemElement = self.dynamicItemSource
        else:
            if paneXpath.find("xpath=") != -1:
                self.dynamicItemDestination.arguments = [paneXpath[6:], item, paneXpath[6:], item]
            else:
                self.dynamicItemDestination.arguments = [paneXpath, item, paneXpath, item]
            itemElement = self.dynamicItemDestination
        
        return itemElement

    def _check_layout_item_existing_state(self, pane, items, state, delimiter=","):
        """state: exist, not exist"""
        self._select_iframe(self.uniqueIframe, self.editLayoutHeaderFooterLeftDiv)
        paneXpath = self.define_layout_pane_xpath(pane)
        listItem = items.split(delimiter)
        for item in listItem:
            isEpandedItemExisted = "->" in item
            
            if isEpandedItemExisted:
                itemElement = self.return_expand_layout_item(paneXpath, item)
            else:
                itemElement = self.build_layout_item_element(paneXpath, "Source", item)
            
            if state == "exist":
                observedState = itemElement.is_element_present()
                Assert.should_be_true(observedState == True, item + " does not exist")
            else:
                observedState = itemElement.is_element_existed()
                Assert.should_be_true(observedState == False, item + " exists")
        driver.unselect_frame()

    def check_layout_items_exist(self, pane, items, delimiter=","):
        self._check_layout_item_existing_state(pane, items, "exist", delimiter)
        
    def check_layout_items_not_exist(self, pane, items, delimiter=","):
        self._check_layout_item_existing_state(pane, items, "not exist", delimiter)

    def toggle_layout_item_expand_state(self, paneXpath, item, state):
        """state: expand, collapse"""
        itemElement = self.build_layout_item_element(paneXpath, "Source", item)
        collapsedItem = itemElement.locator() + "/ancestor::div[1 and @isshow = '0']"
        expandedItem = itemElement.locator() + "/ancestor::div[1 and @isshow = '1']"
        if (Element(collapsedItem).is_element_existed() and state == "expand") or (Element(expandedItem).is_element_existed() and state == "collapse"):
            itemElement.click_visible_element()
        
    def collapse_layout_items_on_content_left(self, items, delimiter=","):
        self._select_iframe(self.uniqueIframe, self.editLayoutHeaderFooterLeftDiv)
        paneXpath = self.define_layout_pane_xpath("ContentLeft")
        listItem = items.split(delimiter)
        for item in listItem:
            self.toggle_layout_item_expand_state(paneXpath, item, "collapse")
        driver.unselect_frame()

    def return_expand_layout_item(self, paneXpath, item):
        listExpandedItem = item.split("->")
        self.toggle_layout_item_expand_state(paneXpath, listExpandedItem[0], "expand")
        self.dynamicExpandedItemSource.arguments = [paneXpath, listExpandedItem[0], listExpandedItem[1]]
        return self.dynamicExpandedItemSource
    
    def get_performance_view_report(self):
        self._select_iframe(self.uniqueIframe, report.viewBtn)
        startCountTime = time.time()
        report.viewBtn.click_visible_element()
        self._wait_for_processing()
        Element("//table[@id='resultGrid']//tr[2]").wait_until_element_is_visible()
        stopCountTime = time.time()
        duration = stopCountTime - startCountTime
        driver.unselect_frame()
        if duration > 3:
            logger.warn("This report displays slowly. Please double-check.")
        
        return duration
    
    def sort_view_report_table_by_column_name(self, column, typeSort="asc"):
        """type: asc(small->big), desc(big->small)"""
        self._select_iframe(self.uniqueIframe, report.viewReportTbl)
        report.viewReportTbl._sort_column_by_name(column, typeSort)
        driver.unselect_frame()
        
    def check_tree_node_check_box_exist_on_select_filter(self, path, delimiter="/"):
        self._select_iframe(self.uniqueIframe, self.locationTreeDiv)
        self.locationTreeDiv.mouse_over()
        isExisted = self.locationTreeDiv.does_tree_node_checkbox_exist(path, delimiter)
        Assert.should_be_equal(isExisted, True, "This tree node checkbox does not exists")
        driver.unselect_frame()
        
    def check_tree_node_check_box_not_exist_on_select_filter(self, path, delimiter="/"):
        self._select_iframe(self.uniqueIframe, self.locationTreeDiv)
        self.locationTreeDiv.mouse_over()
        isExisted = self.locationTreeDiv.does_tree_node_checkbox_exist(path, delimiter)
        Assert.should_be_equal(isExisted, False, "This tree node checkbox exists")
        driver.unselect_frame()
        