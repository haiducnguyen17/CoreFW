from logigear.core.elements.element import Element
from logigear.core.drivers import driver
from logigear.core import waitingKeywords
from selenium.common.exceptions import NoSuchElementException
from logigear.core.helpers import logger
from logigear.core.config import constants

class TreeNodeElement(Element):
    
    def __init__(self, locator):
        super().__init__(locator)
        self.treeIcon = Element("/ins[@class='jstree-icon']", self)
        self.nodeName = Element("/a", self)
        self.children = Element("/ul/li", self)
        self.jstSelected = Element("/div[@class='jstreeSelect']", self)
    
    def _wait_for_selected(self, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        
        def __is_selected(nodeName, jstSelected):
            attr = nodeName.get_element_attribute("class")
            return "jstree-clicked" in attr and jstSelected.is_element_existed()
            
        waitingKeywords._wait_until(
            lambda: __is_selected(self.nodeName, self.jstSelected), 
            "Tree node '%s' still not selected" % self.locator()), timeout
    
    def _wait_for_children(self, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        waitingKeywords._wait_until(
            lambda: self.children.get_element_count() > 0,
            "Tree node '%s' doesn't have any children" % self.locator()), timeout
    
    def _wait_for_toggle_status(self, status, timeout=constants.SELENPY_OBJECT_WAIT_PROBE):
        curStatus = ""
        def __get_current_status():
            curStatus = self.get_tree_icon_status()
            return curStatus == status
        
        waitingKeywords._wait_until(
            lambda: __get_current_status(),
            "Element '%s' status to be '%s'. Current status: '%s'" % (self.locator(), status, curStatus)), timeout
    
    def get_tree_icon_status(self):
        self.treeIcon.wait_until_element_is_visible()
        status = driver.execute_javascript("return window.getComputedStyle(arguments[0]).backgroundPositionX", self.treeIcon.get_webelement())
        
        if status == "-54px": return "collapsed"
        elif status == "-72px": return "expanded"
        else: return "empty"
    
    def click_element(self, modifier=False, action_chain=False):
        self.nodeName.wait_until_element_is_visible()
        self.nodeName.mouse_over()
        temp = 0
        while(not "jstree-hovered" in self.nodeName.get_element_attribute("class") and temp < constants.SELENPY_DEFAULT_TIMEOUT):
            self.nodeName.mouse_over()
            self.nodeName.wait_until_element_attribute_contains("class", "hover")
            temp += 1
        self.nodeName.click_element(modifier,action_chain)
        count = 0
        while not "jstree-clicked" in self.nodeName.get_element_attribute("class") and count < constants.SELENPY_DEFAULT_TIMEOUT:
            self.nodeName.click_element(modifier,action_chain)
            count += 1
        self._wait_for_selected()
        
    def is_leaf(self):
        attr = self.get_element_attribute("class")
        return "jstree-leaf" in attr
    
    def toggle(self, expand):
        curStatus = self.get_tree_icon_status()
        if expand:
            if curStatus == "expanded": return
            else: self._wait_for_toggle_status("collapsed")
        else:
            if curStatus == "collapsed": return
            else: self._wait_for_toggle_status("expanded")
        
        self.treeIcon.click_visible_element()
        
        if not self.is_leaf():
            self._wait_for_toggle_status("expanded" if expand else "collapsed")
            self._wait_for_children()
        
        self.wait_for_element_outer_html_not_change()
    
class TreeElement(Element):
    
    def __init__(self, locator):
        super().__init__(locator)
        self.xpathNodeFormat = "/ul/li[a[normalize-space(text())='%s']]";
        self.rootNode = TreeNodeElement(locator + "/ul/li")
        self.rootNodeChk = TreeNodeElement(locator + "/ul/li//ins[@class='jstree-checkbox']")
        self.mainDiv = "preLoadDiv"
        self.loadingTree = "jstree-loading"
        
    def _build_xpath_from_path(self, path, delimiter="/"):
        xpath = self.locator()
        pathItems = path.split(delimiter)
        for item in pathItems:
            xpath += self.xpathNodeFormat % item
        return xpath
    
    def _expand(self, path, delimiter="/"):
        node = TreeNodeElement(self._build_xpath_from_path(path, delimiter))
        self.wait_for_tree_load()
        if node.return_wait_for_element_visible_status(1): 
            return node
        xpath = self.locator()
        pathItems = path.split(delimiter)
        try:
            for i in range(len(pathItems)):
                xpath += self.xpathNodeFormat % pathItems[i]
                node = TreeNodeElement(xpath)
                if i == len(pathItems) - 1: break
                self.wait_for_element_outer_html_not_change()
                self.wait_for_tree_load()
                node.toggle(True)
        except Exception as e:
            logger.debug("_expand {} - Exception: {}".format(self.locator(), e))
            return None
        return node
    
    def click_tree_node(self, path, delimiter="/"):
        if path == "": self.rootNode.click_visible_element()
        else:
            node = self._expand(path, delimiter)
            self.wait_for_tree_load()
            if node is not None: node.click_element()
            else: raise NoSuchElementException(path)
    
    def click_tree_node_check_box(self, path, delimiter="/"):
        if path == "": self.rootNodeChk.click_visible_element()
        else:
            node = self._expand(path, delimiter)
            self.wait_for_tree_load()
            nodeChk = Element(node.locator() + "//ins[@class='jstree-checkbox']")
            if nodeChk is not None: nodeChk.click_element()
            else: raise NoSuchElementException(path)
    
    def open_context_menu(self, path):
        if path == "": self.rootNode.open_context_menu()
        else:
            node = self._expand(path)
            if node is not None: node.open_context_menu()
            else: raise NoSuchElementException(path)
    
    def does_tree_node_checkbox_exist(self, path, delimiter="/"):
        node = self._expand(path, delimiter)
        nodeChk = Element(node.locator() + "//ins[@class='jstree-checkbox']")
        return False if nodeChk is None else nodeChk.is_element_existed()
    
    def does_tree_node_exist(self, path, delimiter="/"):
        node = self._expand(path, delimiter)
        return False if node is None else node.is_element_existed()
        
    def wait_for_tree_node_not_exist(self, path, timeout):
        node = self._expand(path)
        node.wait_until_element_is_not_visible(timeout)
    
    def wait_for_tree_node_exist(self, path, timeout=1):
        node = self._expand(path)
        node.wait_until_element_is_visible(timeout)
        
    def wait_for_tree_load(self):
        driver.wait_for_condition("return $('[class*=\"%s\"]').length == 0" % self.loadingTree, constants.SELENPY_OBJECT_WAIT)
        driver.wait_for_condition("return $('#%s').length == 0 || $('#%s').is(':hidden')" % (self.mainDiv, self.mainDiv), constants.SELENPY_OBJECT_WAIT) 
        driver.wait_for_condition("return $('iframe').length == 0 || $('iframe').contents().find('[class*=\"%s\"]').length == 0" % self.loadingTree, constants.SELENPY_OBJECT_WAIT)
