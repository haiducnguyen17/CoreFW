from logigear.core.elements.element import Element
from logigear.core.assertion import Assert, SeleniumAssert
from logigear.core.config import constants


class TableElement(Element):

    def _get_header_index(self, headerTable, headerName):
        dynamicListPreviousTh = headerTable + "//th[*[normalize-space(text())='" + headerName + "']]//preceding-sibling::th"
        countColumn = Element(dynamicListPreviousTh).get_element_count()
        
        return countColumn + 1
    
    def _get_row_index(self, rowXpath):
        dynamicListPreviousTr = rowXpath + "/preceding-sibling::tr"
        countRow = Element(dynamicListPreviousTr).get_element_count()
        
        return countRow + 1
        
    def _get_table_row_map_with_header(self, headers, values, delimiter=","):
        return self._work_on_table_row_map_with_header(headers, values, False, None, delimiter)
    
    def _click_table_cell(self, row, column, mode="single"):
        dynamicCellXpath = self.locator() + "//tr[" + str(row) + "]//td[" + str(column) + "]"
        Element(dynamicCellXpath).set_focus_to_element()
        if mode=="double":
            Element(dynamicCellXpath).double_click_element()
        else:
            Element(dynamicCellXpath).click_visible_element()
    
    def _build_row_xpath(self, headers, values, row=None, delimiter=","):
        dynamicHeaderTable = self.locator() + "/preceding::table[1]"
        listHeader = headers.split(delimiter)
        listValue = values.split(delimiter)
        rowXpath = ""
        
        for i in range(0, len(listHeader)):
            indexColumn = self._get_header_index(dynamicHeaderTable, listHeader[i])
            tdValue = listValue[i]
            if tdValue == "":
                tdValue = u'\xa0'
            dynamicRowXpath = " and normalize-space(td[" + str(indexColumn) + "])='" + tdValue + "'"
            rowXpath = rowXpath + dynamicRowXpath
        
        rowXpath = rowXpath[4:]
        if row is not None:
            dynamicFinalRowXpath = self.locator() + "//tr[" + str(row) + "][" + rowXpath + "]"
        else:
            dynamicFinalRowXpath = self.locator() + "//tr[" + rowXpath + "]"
            
        return dynamicFinalRowXpath
    
    def _work_on_table_row_map_with_header(self, headers, values, check=False, row=None, delimiter=","):
        dynamicFinalRowXpath = self._build_row_xpath(headers, values, row, delimiter)
        isRowExisted = Element(dynamicFinalRowXpath).return_wait_for_element_visible_status(constants.SELENPY_DEFAULT_TIMEOUT)
        if check is not False:
            Assert.should_be_true(isRowExisted, dynamicFinalRowXpath + " is not existed")
        else:
            if isRowExisted:
                rowIndex = self._get_row_index(dynamicFinalRowXpath)
            else:
                rowIndex = 0
            return rowIndex  
    
    def check_row_table_with_data(self, headers, values, row, delimiter=","):
        self._work_on_table_row_map_with_header(headers, values, True, row, delimiter)
        
    def _check_table_row_map_with_header_checkbox_selected(self, headers, values, delimiter=","):
        row = self._work_on_table_row_map_with_header(headers, values, False, None, delimiter)
        dynamicChkBxRowXpath = self.locator() + "//tr[" + str(row) + "]//input"
        eleChk = Element(dynamicChkBxRowXpath)
        SeleniumAssert.checkbox_should_be_selected(eleChk)
     
    def wait_for_object_appear_on_table(self, headers, values, delimiter=","):
        rowXpath = self._build_row_xpath(headers, values, None, delimiter)
        Element(rowXpath).wait_until_element_is_visible()
    
    def wait_for_object_disappear_on_table(self, headers, values, delimiter=","):
        rowXpath = self._build_row_xpath(headers, values, None, delimiter)
        Element(rowXpath).wait_until_element_is_not_visible()
        
    def _sort_column_by_name(self, column, typeSort="asc"):
        """type: asc(small->big), desc(big->small)"""
        dynamicColumn = self.locator() + "/preceding::table[1]//th[*[normalize-space(text())='" + column + "']]"
        dynamicDisabledSortSpan = self.locator() + "/preceding::table[1]//th[*[normalize-space(text())='" + column + "']]//span[@sort='" + typeSort + "' and contains(@class,'disabled')]"
        dynamicEnabledSortSpan = self.locator() + "/preceding::table[1]//th[*[normalize-space(text())='" + column + "']]//span[@sort='" + typeSort + "' and not(contains(@class,'disabled'))]"
        while(Element(dynamicDisabledSortSpan).is_element_present() and not Element(dynamicEnabledSortSpan).is_element_existed()):
            Element(dynamicColumn).click_visible_element()
