from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.table_element import TableElement
from logigear.core.drivers import driver
from logigear.page_objects.system_manager.administration import administration

class AdmLayerImageFilesPageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.layerImageTbl = self.element("layerImageTbl", TableElement)
        self.layerNameTxt = self.element("layerNameTxt")
        self.colorPickerBtn = self.element("colorPickerBtn")
        self.saveBtn = self.element("saveBtn")

    def delete_layer_image_files(self, layerName):
        driver.select_frame(self.uniqueIframe)
        self.layerImageTbl.wait_until_page_contains_element()
        tableRow = self.layerImageTbl._get_table_row_map_with_header("Name", layerName, delimiter=",")
        if tableRow > 0:
            self.layerImageTbl._click_table_cell(tableRow, column=1)
            self.deleteBtn.click_visible_element()
            driver.unselect_frame()
            self.confirmDialogBtn.click_visible_element()   
        else:
            driver.unselect_frame()
        
    def add_layer_image_files(self, name, imagePath):
        driver.select_frame(self.uniqueIframe)
        self.addBtn.wait_until_page_contains_element()
        self.addBtn.click_visible_element()
        self.layerNameTxt.wait_until_element_is_visible()
        self.layerNameTxt.input_text(name)
        administration.uploadFileTxt.choose_file(imagePath)
#         if backgroundColor is not None:
#             select background color (waiting for aTiep)
        self.saveBtn.click_visible_element()
        driver.unselect_frame()
        if self.confirmDialogBtn.is_element_existed():
            self.confirmDialogBtn.click_visible_element()
    