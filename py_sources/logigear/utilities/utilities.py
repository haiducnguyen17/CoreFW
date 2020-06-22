'''
Created on Mar 11, 2020

@author: tiep.tra
'''
import win32serviceutil
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert, Assert
from PIL import Image, ImageChops 
import time
import os
import _csv
from logigear.core.helpers import logger
from logigear.core import OS

class Utilities():
    
    def replace_substring_in_text_file(self, locationFile, substring, newValue):
        file = open(locationFile, "r")
        data = file.read()
        file.close()
        data = data.replace(substring, newValue)
        file = open(locationFile, "w")
        file.write(data)
        file.close()
    
    def get_windows_service(self, serviceName):
        return win32serviceutil.QueryServiceStatus(serviceName)[1]
    
    def start_service(self, serviceName):
        status = self.get_windows_service(serviceName)
        if status != 4 and status != 2:
            win32serviceutil.StartService(serviceName)
            status = self.get_windows_service(serviceName)
            while(status != 4):
                time.sleep(0.5)  # wait for started service
                status = self.get_windows_service(serviceName)
    
    def stop_service(self, serviceName):
        status = self.get_windows_service(serviceName)
        if status != 1 and status != 7:
            win32serviceutil.StopService(serviceName)
            status = self.get_windows_service(serviceName)
            while(status != 1):
                time.sleep(0.5)  # wait for stopped service
                status = self.get_windows_service(serviceName)
        
    def restart_service(self, serviceName):
        self.stop_service(serviceName)
        self.start_service(serviceName)

    def check_current_window_title(self, title):
        SeleniumAssert.title_should_be(title, "Current window title is not " + title)
        
    def check_current_window_title_contain(self, titleContains):
        title = driver.get_title()
        Assert.should_contain(title, titleContains)
        
    def switch_window(self, locator='MAIN', timeout=None, browser='CURRENT'):
        return driver.switch_window(locator, timeout, browser)

    def get_windows_user(self):
        return os.getlogin()
    
    def check_download_file_exist(self, fileName):
        currentWindowsUser = self.get_windows_user()
        downloadFolderPath = "C:\\Users\\" + currentWindowsUser + "\\Downloads\\"
        os.path.exists(downloadFolderPath + fileName)
           
    def open_new_tab(self, url):
        driver.execute_javascript("window.open('')")
        driver.switch_window("title=undefined")
        driver.go_to(url)
        
    def get_current_tab_alias(self):
        return  driver.get_browser_aliases()
        
    def close_current_tab (self):
        driver.execute_javascript("window.close()")
        
    def check_data_row_in_excel_file(self, filePath, line, expectedValue, delimiter=","):
        with open(filePath, 'r') as file:
            csvFile = list(_csv.reader(file))
            observedLine = csvFile[int(line) - 1]
            listExpectedValue = expectedValue.split(delimiter)
            lenexpectedValue = len(listExpectedValue)
            for i in range(lenexpectedValue):
                if observedLine[i] == " ":
                    observedResult = ""
                else:
                    observedResult = observedLine[i]
                Assert.should_be_equal(observedResult, listExpectedValue[i])
                print(observedLine[i] + " = " + listExpectedValue[i])

    def compare_images(self, refImagePath, testImagePath):
            imgRef = Image.open(refImagePath) 
            imgTest = Image.open(testImagePath) 
  
            diff = ImageChops.difference(imgRef, imgTest) 
  
            if diff.getbbox() is None:
                boolCheck = True
            else:
                boolCheck = False
            Assert.should_be_true(boolCheck, "Images are different")
    
    '''
    Created on Apr 29, 2020

    @author: tiep.tra
    '''        
    def report_bug(self, bugId):
        if bugId[2] == "Open":
            logger.warn("This test case is failed by defect: '%s'-'%s'" % (bugId[0], bugId[1]))
            
    def remove_file(self, path):
        if os.path.exists(path):
            os.remove(path)
        
    def copy_file(self, source, destination):
        OS.copy_file(source, destination)
        
    def reverse_list(self, inputList):
        return list(reversed(inputList))
    
    def reload_page(self):
        driver.reload_page()