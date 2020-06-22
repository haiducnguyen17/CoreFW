'''
Created on May 4, 2020

@author: tiep.tra
'''
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.core.elements.tree_element import TreeElement

class ServiceDialogDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        self.leftTreeDiv = self.element("leftTreeDiv", TreeElement)
        self.rightTreeDiv = self.element("rightTreeDiv", TreeElement)
        self.expectedServiceCbb = self.element("expectedServiceCbb")
        self.expectedServiceDesignationCbb = self.element("expectedServiceDesignationCbb")
        self.expectedRouteDesignationCbb = self.element("expectedRouteDesignationCbb")
        self.expectedPoETypeCbb = self.element("expectedPoETypeCbb")
        self.serviceIframe = self.element("serviceIframe")
        self.connectBtn = self.element("connectBtn")
        
    
