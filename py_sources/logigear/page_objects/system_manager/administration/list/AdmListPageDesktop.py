from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.drivers import driver
from logigear.core.elements.table_element import TableElement
from logigear.page_objects.system_manager.administration import administration
from logigear.core.config import constants


class AdmListPageDesktop(GeneralPage):

    def __init__(self):
        GeneralPage.__init__(self)
        self.dynamicGroupListTitle = self.element("dynamicGroupListTitle")
        self.listTbl = self.element("listTbl", TableElement)
        self.listNameTxt = self.element("listNameTxt")
        self.equipmentImageBtn = self.element("equipmentImageBtn")
        self.deleteBtn = self.element("deleteBtn")
        self.equipmentViewImg = self.element('equipmentViewImg')
        self.listIconTypeCbb = self.element("listIconTypeCbb")
        self.confirmAddListBtn = self.element("confirmAddListBtn")
        """confirmAddListBtn: need to capture an individual control due to the general one cannot apply here (confirmed all team members) """

    def add_list_on_administration(self, listType, name, imagePath=None, iconType=None):
        self.dynamicGroupListTitle.arguments = [listType]
        self._select_iframe(self.uniqueIframe, self.dynamicGroupListTitle)
        self.dynamicGroupListTitle.click_visible_element()
        self.addBtn.wait_until_page_contains_element()
        self.addBtn.click_visible_element()
        self.listNameTxt.wait_until_element_is_visible()
        self.listNameTxt.input_text(name)
        if imagePath is not None:
            temp = 0
            while(not administration.uploadFileTxt.is_element_present() and temp < constants.SELENPY_DEFAULT_TIMEOUT):
                self.equipmentImageBtn.mouse_over()
                self.equipmentImageBtn.wait_until_element_attribute_contains("class", "hover")
                temp +=1
            administration.uploadFileTxt.choose_file(imagePath)
            self.equipmentViewImg.wait_until_element_is_visible()
        if iconType is not None:
            self.listIconTypeCbb.select_from_list_by_label(iconType)
        self.confirmAddListBtn.click_visible_element()
        driver.unselect_frame()
        
    def delete_list_on_administration(self, listType, name):
        self.dynamicGroupListTitle.arguments = [listType]
        self._select_iframe(self.uniqueIframe, self.dynamicGroupListTitle)
        self.dynamicGroupListTitle.click_visible_element()
        self.listTbl.wait_until_element_is_visible()
        eventRow = self.listTbl._get_table_row_map_with_header("Name" , name, ",")
        if eventRow != 0:
            self.listTbl._click_table_cell(eventRow, 2)
            self.deleteBtn.click_visible_element()
            driver.unselect_frame()
            self.confirmAddListBtn.click_visible_element() 
            self._select_iframe(self.uniqueIframe, self.listTbl)
            self.listTbl.wait_for_object_disappear_on_table("Name" , name, ",")
        driver.unselect_frame()
