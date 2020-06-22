from logigear.core.elements.element import Element
from logigear.core.helpers.base_page import BasePage
from logigear.core.utilities import utils
from logigear.core.drivers import driver
from logigear.core.assertion import SeleniumAssert, Assert
from logigear.core.helpers import logger
from logigear.data import Constants


class GeneralPage(BasePage):
    
    def __init__(self):
        BasePage.__init__(self);
        self.processingIcon = self.element("processingIcon")
        self.treeObjectIcon = self.element("treeObjectIcon")
        self.dialogOkBtn = self.element("dialogOkBtn")
        self.dialogCancelBtn = self.element("dialogCancelBtn")
        self.uniqueIframe = self.element("uniqueIframe")
        self.secondIframe = self.element("secondIframe")
        self.addBtn = self.element("addBtn")
        self.confirmDialogBtn = self.element("confirmDialogBtn")
        self.deleteBtn = self.element("deleteBtn")
        self.loadingTree = self.element("loadingTree")
        self.downloadFileNameJs = self.element("downloadFileNameJs")
        self.dialogYesBtn = self.element("dialogYesBtn")
        self.dialogNoBtn = self.element("dialogNoBtn")
        self.traceBtn = self.element("traceBtn")
        self.masterRightDiv = self.element("masterRightDiv")
        self.attentionYesBtn = self.element("attentionYesBtn")
        self.attentionNoBtn = self.element("attentionNoBtn")
        self.treePortTypeIcon = self.element("treePortTypeIcon")
        self.dynamicFirstTraceObjectXpath = self.element("dynamicFirstTraceObjectXpath")
        self.dynamicScheduleIconXpath = self.element("dynamicScheduleIconXpath")
        self.dynamicObjectXpath = self.element("dynamicObjectXpath")   
        self.traceTabDiv = self.element("traceTabDiv")
             
    def _click_tree_node(self, divTree, treeNode, delimiter="/"):
        self._work_on_tree_node(divTree, treeNode, delimiter, click=True)
        self._wait_for_processing()
               
    def _build_tree_node_xpath(self, divTree, treeNode, delimiter="/"):
        nodeList = treeNode.split(delimiter)
        currentXpath = divTree.locator()
        
        for node in nodeList:
            dynamicBuiltNodeXpath = self.element("dynamicBuiltNodeXpath")
            dynamicBuiltNodeXpath.arguments = [node]
            currentXpath = currentXpath + dynamicBuiltNodeXpath.locator()
            
        return currentXpath + "/a"

    def _define_trace_map_xpath(self, divTraceMap):
        """Use to get xpath of trace map because we have many cases having many trace map"""
        
        divTraceMap.wait_for_element_outer_html_not_change()
        divTraceMap = divTraceMap.locator()
        
        dynamic2ClassTabsCurrentTraceDiv = self.element("dynamic2ClassTabsCurrentTraceDiv")
        dynamic2ClassTabsCurrentTraceDiv.arguments = [divTraceMap]
        dynamic2ClassTabsScheduledTraceDiv = self.element("dynamic2ClassTabsScheduledTraceDiv")
        dynamic2ClassTabsScheduledTraceDiv.arguments = [divTraceMap]
        dynamicNormalCurrentTraceDiv = self.element("dynamicNormalCurrentTraceDiv")
        dynamicNormalCurrentTraceDiv.arguments = [divTraceMap]
        dynamicNormalScheduleTraceDiv = self.element("dynamicNormalScheduleTraceDiv")
        dynamicNormalScheduleTraceDiv.arguments = [divTraceMap]
        dynamicFirstTraceDiv = self.element("dynamicFirstTraceDiv")
        dynamicFirstTraceDiv.arguments = [divTraceMap]
        dynamicManyTabsTraceDiv = self.element("dynamicManyTabsTraceDiv")
        dynamicManyTabsTraceDiv.arguments = [divTraceMap]
        dynamicTwoTabsClassCurrentTraceDiv = self.element("dynamicTwoTabsClassCurrentTraceDiv")
        dynamicTwoTabsClassCurrentTraceDiv.arguments = [divTraceMap]
        dynamicTwoTabsClassScheduledTraceDiv = self.element("dynamicTwoTabsClassScheduledTraceDiv")
        dynamicTwoTabsClassScheduledTraceDiv.arguments = [divTraceMap]
        dynamicScheduledMapXpath = self.element("dynamicScheduledMapXpath")
        dynamicScheduledMapXpath.arguments = [divTraceMap]
        dynamicTraceMapXpath = self.element("dynamicTraceMapXpath")
        dynamicTraceMapXpath.arguments = [divTraceMap]
        
        if dynamicManyTabsTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamicManyTabsTraceDiv
        elif dynamicTwoTabsClassScheduledTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamicTwoTabsClassScheduledTraceDiv
        elif dynamicTwoTabsClassCurrentTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamicTwoTabsClassCurrentTraceDiv
        elif dynamicFirstTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamicFirstTraceDiv
        elif dynamic2ClassTabsCurrentTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamic2ClassTabsCurrentTraceDiv
        elif dynamic2ClassTabsScheduledTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamic2ClassTabsScheduledTraceDiv
        elif dynamicNormalCurrentTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamicNormalCurrentTraceDiv
        elif dynamicNormalScheduleTraceDiv.is_element_existed():
            dynamicTraceMapXpath = dynamicNormalScheduleTraceDiv
        elif dynamicScheduledMapXpath.is_element_existed():
            dynamicTraceMapXpath = dynamicScheduledMapXpath
        
        return dynamicTraceMapXpath.locator()
    
    def _check_device_information_on_trace(self, objectXpath, deviceInformation, delimiter="->"):
        """'object_xpath' is xpath string of the object we want to check(ex: //div[@id='TraceMapDialog']//div[contains(@class,'MPOPairContent MpoPair') and contains(@style,'display: block')]//div[@class = 'TraceForFiberWrapper' and contains(@style,'display: block')]//div[@id='3' and contains(@class,'ObjectDetail')])
    ...    'device_information' is a list including all information of device (separate by ->)"""
        
        listInformation = deviceInformation.split(delimiter)
        temp = 1
        for information in listInformation:
            dynamicInformationXpath = self.element("dynamicInformationXpath")
            dynamicInformationXpath.arguments = [objectXpath, temp, information, information]
            SeleniumAssert.element_should_be_visible(dynamicInformationXpath)
            temp += 1
    
    def _check_trace_object(self, divTraceXpath, indexObject, mpoType=None, objectPosition=None, objectPath=None, objectType=None, portIcon=None, connectionType=None, scheduleIcon=None, informationDevice=None):
        """This keyword is used for check all information of a object on trace window: position, object path, object detail, object type, object connection type, scheduled icon.
    ...     We have  9 arguments:
    ...    - 'divTraceXpath' define the page this keyword working( ex: on patching window, 'divTraceXpath' is //div[@id='divTrace'])
    ...    - 'indexObject': Provide the index of object we want to check
    ...    - 'objectPosition': enter position(ex: 1, MPO12-1)
    ...    - 'objectPath': enter object path(ex: Site/Building 01/Floor 01/Room 01/1:1 Rack 001/Panel 01/01)
    ...    - 'objectType': enter type of object - it's defined by a png file(ex: Generic Copper Panel)
    ...    - 'scheduleIcon': this argument is used on checking trace the object related to an uncompleted work order
    ...    - 'connectionType': enter the connection type between this object and next object
    ...    - 'informationDevice': enter information device(ex:01,Panel 01,1:1 Rack 001,Room 01,Floor 01,Building 01,Site)"""
        
        ##################################Define trace map##################################
        traceMapXpath = self._define_trace_map_xpath(divTraceXpath)
        self._wait_first_object_on_trace(traceMapXpath)
        
        ##################################Variables##################################
        idObject = int(indexObject) * 2 - 1
        self.dynamicObjectXpath.arguments = [traceMapXpath, str(idObject)]
        
        ##################################Click or move object##################################
        if objectPath is not None:
            if(traceMapXpath.__contains__("//div[@id='divTrace']")):
                self.dynamicObjectXpath.mouse_over()
            else:
                self.dynamicObjectXpath.click_visible_element()
         
        ##################################Check Object Position##################################    
        #--------------------------For since--------------------------#
        if objectPosition is not None:
            dynamicObjectPositionXpath = self.element("dynamicObjectPositionXpath")
            dynamicObjectPositionXpath.arguments = [traceMapXpath, str(idObject), objectPosition]
            lengthSince = len(objectPosition)
            if(lengthSince == 5 and objectPosition[0:5] == "since"):
                currentTime = utils.get_current_date_time(resultFormat="%Y-%m-%d")
                dynamicSinceNoSpace = self.element("dynamicSinceNoSpace")
                dynamicSinceNoSpace.arguments = [traceMapXpath, str(idObject), currentTime]
                doesSinceNoSpaceExist = dynamicSinceNoSpace.is_element_existed()
                if(doesSinceNoSpaceExist == False):
                    dynamicSinceWithSpace = self.element("dynamicSinceWithSpace")
                    dynamicSinceWithSpace.arguments = [traceMapXpath, str(idObject), currentTime]
                    SeleniumAssert.element_should_be_visible(dynamicSinceWithSpace)
            else:
                SeleniumAssert.element_should_be_visible(dynamicObjectPositionXpath)
        
        ##################################Check MPO Type##################################
        if mpoType is not None:
            dynamicMpoTypeXpath = self.element("dynamicMpoTypeXpath")
            dynamicMpoTypeXpath.arguments = [traceMapXpath, str(idObject), mpoType]
            SeleniumAssert.element_should_be_visible(dynamicMpoTypeXpath)
        
        ##################################Check Object Path Banner##################################
        if objectPath is not None:
            dynamicObjectPathXpath = self.element("dynamicObjectPathXpath")
            dynamicObjectPathXpath.arguments = [traceMapXpath, objectPath]
            SeleniumAssert.element_should_be_visible(dynamicObjectPathXpath)
        
        ##################################Check Object Type##################################
        if objectType is not None:
            dynamicObjectTypeXpath = self.element("dynamicObjectTypeXpath")
            dynamicObjectTypeXpath.arguments = [traceMapXpath, str(idObject), objectType]
            SeleniumAssert.element_should_be_visible(dynamicObjectTypeXpath)
        
        ##################################Check Connection Type##################################
        if connectionType is not None:
            dynamicConnectionTypeXpath = self.element("dynamicConnectionTypeXpath")
            dynamicConnectionTypeXpath.arguments = [traceMapXpath, str(indexObject), connectionType]
            SeleniumAssert.element_should_be_visible(dynamicConnectionTypeXpath)
        
        ##################################Check Port Icon##################################
        if portIcon is not None:
            dynamicPortIconXpath = self.element("dynamicPortIconXpath")
            dynamicPortIconXpath.arguments = [traceMapXpath, str(idObject), portIcon]
            SeleniumAssert.element_should_be_visible(dynamicPortIconXpath)
        
        ##################################Check Schedule Icon##################################
        if scheduleIcon is not None:
            self.dynamicScheduleIconXpath.arguments = [traceMapXpath, str(idObject), scheduleIcon]
            SeleniumAssert.element_should_be_visible(self.dynamicScheduleIconXpath)
        
        ##################################Check Information Device##################################
        if informationDevice is not None:
            self._check_device_information_on_trace(self.dynamicObjectXpath.locator(), informationDevice)    
                
    def _select_view_trace_tab(self, divTraceXpath, viewTab):
        """If we want to select tab by path, we should input like: Up Link->B1. "->" is the delimiter."""
        listTab = viewTab.split("->")
        dynamicForwardBtnXpath = self.element("dynamicForwardBtnXpath")
        dynamicForwardBtnXpath.arguments = [divTraceXpath.locator()]
        for tab in listTab:
            dynamicCurrentTabXpath = self.element("dynamicCurrentTabXpath")
            dynamicCurrentTabXpath.arguments = [divTraceXpath.locator(), tab, tab]
            
            dynamicScheduledTabXpath = self.element("dynamicScheduledTabXpath")
            dynamicScheduledTabXpath.arguments = [divTraceXpath.locator(), tab, tab]
            
            dynamicTabXpath = self.element("dynamicTabXpath")
            dynamicTabXpath.arguments = [divTraceXpath.locator(), tab, tab]
            
            dynamicManyTabsXpath = self.element("dynamicManyTabsXpath")
            dynamicManyTabsXpath.arguments = [divTraceXpath.locator(), tab, tab]
            
            self.traceTabDiv.return_wait_for_element_visible_status(Constants.OBJECT_WAIT_PROBE)
            dynamicCurrentTabXpath.click_element_if_exist()
            if dynamicScheduledTabXpath.is_element_existed():
                dynamicScheduledTabXpath.click_visible_element()
                dynamicScheduledTabXpath.wait_until_element_attribute_contains("class", "selected")
            dynamicTabXpath.click_element_if_exist()
            dynamicManyTabsXpath.click_element_if_exist() 
            if not dynamicTabXpath.is_element_existed() and not dynamicCurrentTabXpath.is_element_existed() and not dynamicScheduledTabXpath.is_element_existed() and dynamicForwardBtnXpath.is_element_existed():
                dynamicForwardBtnXpath.click_element()
                dynamicTabXpath.click_element_if_exist()
                dynamicCurrentTabXpath.click_element_if_exist()
                dynamicScheduledTabXpath.click_element_if_exist()  
            self._wait_for_processing()       
        
    def _wait_for_processing(self, visibleTimeout=1.5, timeout=60):
        logger.info("Wait for processing", True)
        self.processingIcon.return_wait_for_element_visible_status(visibleTimeout)
        self.processingIcon.return_wait_for_element_invisible_status(timeout)
        """
        doesProcessingIconExist = self.processingIcon.return_wait_for_element_visible_status(3)
        temp = 1
        while(doesProcessingIconExist):
            doesProcessingIconNotExist = self.processingIcon.return_wait_for_element_invisible_status(3)
            if(doesProcessingIconNotExist or temp == timeOut):
                break
            doesProcessingIconExist = self.processingIcon.is_element_existed()
            temp += 1"""
                
    def _does_tree_node_exist(self, divTree, treeNode, delimiter="/"):
        """Input treenode and this keyword will return 'True' if exists OR 'False' if not exist"""
        return self._work_on_tree_node(divTree, treeNode, delimiter, click=False)
        
    def _work_on_tree_node(self, divTree, treeNode, delimiter, click=True):
        treeNodeXpath = self._build_tree_node_xpath(divTree, treeNode, delimiter)
        eleExpectedNode = Element(treeNodeXpath)
        
        if eleExpectedNode.is_element_existed():
            if click:
                eleExpectedNode.click_visible_element()
            return True
        else:
            nodeList = treeNode.split(delimiter)
            lastNode = len(nodeList)
            currentXpath = divTree.locator()
            temp = 1
        
            for node in nodeList:
                dynamicNodeXpath = self.element("dynamicNodeXpath")
                dynamicNodeXpath.arguments = [node]
                currentXpath = currentXpath + dynamicNodeXpath.locator()
                
                dynamicEleCollapse = self.element("dynamicEleCollapse")
                dynamicEleCollapse.arguments = [currentXpath]
                
                if dynamicEleCollapse.return_wait_for_element_visible_status(1) and temp != lastNode:
                    dynamicExpandNodeBtn = self.element("dynamicExpandNodeBtn")
                    dynamicExpandNodeBtn.arguments = [currentXpath]
                    self._wait_for_loading_tree()
                    dynamicExpandNodeBtn.click_visible_element()
                    self._wait_for_loading_tree()
                    
                if temp == lastNode:
                    dynamicEleCurrentNode = self.element("dynamicEleCurrentNode")
                    dynamicEleCurrentNode.arguments = [currentXpath]
                    if click:
                        eleExpectedNode.click_visible_element()
                        self._wait_for_loading_tree()
                    return dynamicEleCurrentNode.is_element_existed()

                temp += 1
                
    def _select_iframe(self, frame, waitElement):
        frame.wait_until_page_contains_element()
        driver.select_frame(frame)
        waitElement.wait_until_page_contains_element()
        
    def _click_frame_tree_node(self, frame, treePanel, fromDivTree, toDivTree, treeNode, delimiter="/"):
        self._select_iframe(frame, fromDivTree)
        if treePanel == "From":
            fromDivTree.click_tree_node(treeNode, delimiter)
        else:
            toDivTree.click_tree_node(treeNode, delimiter)
        driver.unselect_frame()

    def _build_page_tree_node_xpath(self, treePanel, fromDivTree, toDivTree, treeNode, delimiter="/"):
        if treePanel == "From":
            xpath = fromDivTree._build_xpath_from_path(treeNode, delimiter)
        else:
            xpath = toDivTree._build_xpath_from_path(treeNode, delimiter)
        return xpath
    
    def _does_frame_tree_node_exist(self, frame, treePanel, fromDivTree, toDivTree, treeNode, delimiter="/"):
        self._select_iframe(frame, fromDivTree)
        self._wait_for_processing()
        if treePanel == "From":
            isExisted = fromDivTree.does_tree_node_exist(treeNode, delimiter)
        else:
            isExisted = toDivTree.does_tree_node_exist(treeNode, delimiter)
        driver.unselect_frame()
        return isExisted
    
    def _check_total_trace(self, divTraceXpath, totalTrace):
        """Use for check number of trace
    ...    - 'div_trace_xpath' define the page this keyword working( ex: on patching window, 'div_trace_xpath' is //div[@id='CurrentTraceResult'])
    ...    - 'total_trace' is number of trace
    ...    - 'close_trace_window': choosing yes or no"""
        
        traceMapXpath = self._define_trace_map_xpath(divTraceXpath)
        self._wait_first_object_on_trace(traceMapXpath)
        idLastObject = int(totalTrace) * 2 - 1
        idNotExistObject = int(totalTrace) * 2 + 1
        dynamicLastTraceObjectXpath = self.element("dynamicTraceObjectXpath")
        dynamicLastTraceObjectXpath.arguments = [traceMapXpath, str(idLastObject)]
        dynamicNotExistTraceObjectXpath = self.element("dynamicTraceObjectXpath")
        dynamicNotExistTraceObjectXpath.arguments = [traceMapXpath, str(idNotExistObject)]
        SeleniumAssert.element_should_be_visible(dynamicLastTraceObjectXpath)
        SeleniumAssert.element_should_not_be_visible(dynamicNotExistTraceObjectXpath)
    
    def _click_tree_node_checkbox(self, divTree, treeNode, delimiter="/"):
        treeNodeXpath = self._build_tree_node_xpath(divTree, treeNode, delimiter)
        dynamicTreeNodeCheckBoxXpath = self.element("dynamicTreeNodeCheckBoxXpath")
        dynamicTreeNodeCheckBoxXpath.arguments = [treeNodeXpath]
        self._does_tree_node_exist(divTree, treeNode, delimiter)
        dynamicTreeNodeCheckBoxXpath.click_visible_element()
    
    def _get_element_js_property(self, element, selectedProperty):
        newLocator = element.locator().replace('xpath=','')
        newJsStr = "return window.document.evaluate(\""+newLocator+"\",document.body,null,9,null).singleNodeValue."+selectedProperty
        return driver.execute_javascript(newJsStr)
    
    def _check_element_js_property(self, element, selectedProperty, expectedValue):
        observedValue = self._get_element_js_property(element, selectedProperty)
        Assert.should_be_equal(observedValue, expectedValue)

    def _check_title_attribute(self, element, expected):
        SeleniumAssert.element_attribute_value_should_be(element, "title", expected)
        
    def _check_src_attribute(self, element, expected):
        SeleniumAssert.element_attribute_value_should_contain(element, "src", expected)
        
    def _wait_for_loading_tree(self):
        self.loadingTree.wait_until_element_is_not_visible()
        mainDiv = self.element("mainDiv")
        driver.wait_for_condition("return $('[class*=\"jstree-loading\"]').length == 0")
        driver.wait_for_condition("return $('#" + mainDiv.locator() + "').length == 0 || $('#" + mainDiv.locator() + "').is(':hidden')") 
        driver.wait_for_condition("return $('iframe').length == 0 || $('iframe').contents().find('[class*=\"jstree-loading\"]').length == 0")   
    
    def _get_latest_download_file_name(self):
        return driver.execute_javascript(self.downloadFileNameJs.locator())
    
    def _check_tree_node_selected(self, treeDiv, treeNode, delimiter="/"):
        buildXpath = self._build_tree_node_xpath(treeDiv, treeNode, delimiter)
        expectedNode = buildXpath + "[@class='jstree-clicked']"
        observedResult = Element(expectedNode).return_wait_for_element_visible_status(1)
        Assert.should_be_true(observedResult == True, "Tree node is not selected")
        
    def close_dialog(self):
        self.dialogCancelBtn.click_visible_element()
        self.dialogCancelBtn.return_wait_for_element_invisible_status()

    def _check_element_state(self, element, state):
        """state: True = Enabled, False = Disabled"""        
        if state:
            SeleniumAssert.element_should_be_enabled(element)
        else:
            SeleniumAssert.element_should_be_disabled(element)                 
        
    def _check_checkbox_state(self, element, state):
        """state: True = Selected, False = Unselected"""        
        if state:
            SeleniumAssert.checkbox_should_be_selected(element)
        else:
            SeleniumAssert.checkbox_should_not_be_selected(element) 
    
    def _check_multiple_states_of_checkbox(self, element, enabled, selected):
        """enabled = True/False, selected = True/False"""
        self._check_element_state(element, enabled)
        self._check_checkbox_state(element, selected)
    
    def save_dialog(self):
        self.dialogOkBtn.click_visible_element()
        self.dialogOkBtn.return_wait_for_element_invisible_status()

    def _wait_first_object_on_trace(self, traceMapXpath):
        self.dynamicFirstTraceObjectXpath.arguments = [traceMapXpath]
        self.dynamicFirstTraceObjectXpath.wait_until_element_is_visible(Constants.OBJECT_WAIT)