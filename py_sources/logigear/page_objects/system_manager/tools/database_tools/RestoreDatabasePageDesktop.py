from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from shutil import copyfile
from logigear.core.drivers import driver
from logigear.data.Constants import OBJECT_WAIT, DIR_BACKUPFILE_COMMSCOPE
from logigear.core.utilities import utils

class RestoreDatabasePageDesktop(GeneralPage):
 
    def __init__(self):
        GeneralPage.__init__(self)
        self.confirmDialogBtn = self.element("confirmDialogBtn")
        self.restoreBtn = self.element("restoreBtn")
        self.dynamicFileObjectXpath = self.element("dynamicFileObjectXpath")
        
    def restore_database(self, fileName, dirBackupData):
        """Input fileName(example: test.bak ) and dir of backupdata(example: C:\Pre_Condition\...)"""
        copyfile(dirBackupData + "/" + fileName, DIR_BACKUPFILE_COMMSCOPE + "/" + fileName)
        utils.get_page("ZoneHeaderPage").select_main_menu("Tools/Restore Database")
        self.dynamicFileObjectXpath.arguments = [fileName]
        self._select_iframe(self.uniqueIframe, self.dynamicFileObjectXpath)
        self.dynamicFileObjectXpath.click_visible_element()
        self.restoreBtn.click_visible_element()
        driver.unselect_frame()
        self.confirmDialogBtn.click_visible_element()
        self.dialogCancelBtn.wait_until_element_is_not_visible(timeout=OBJECT_WAIT * 10)
        if self.confirmDialogBtn.is_element_existed():
            self.confirmDialogBtn.click_visible_element()
