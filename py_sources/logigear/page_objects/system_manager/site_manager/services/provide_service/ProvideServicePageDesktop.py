'''
Created on May 4, 2020

@author: tiep.tra
'''
from logigear.page_objects.system_manager.GeneralPage import GeneralPage
from logigear.page_objects.system_manager.site_manager.services import services
from logigear.core.drivers import driver

class ProvideServicePageDesktop(GeneralPage):
    
    def __init__(self):
        GeneralPage.__init__(self)
        
    def provide_service(self, treeNode=None, service=None, serviceDesignation=None, routeDesignation=None, poeType=None, delimiter="/", clickConnect=True):
        self._select_iframe(services.serviceIframe, services.leftTreeDiv)
        if treeNode is not None:
            services.leftTreeDiv.click_tree_node(treeNode, delimiter)
        if service is not None:
            services.expectedServiceCbb.select_from_list_by_label(service)
        if serviceDesignation is not None:
            services.expectedServiceDesignationCbb.select_from_list_by_label(serviceDesignation)
        if routeDesignation is not None:
            services.expectedRouteDesignationCbb.select_from_list_by_label(routeDesignation)
        if poeType is not None:
            services.expectedPoETypeCbb.select_from_list_by_label(poeType)
        if clickConnect:
            services.connectBtn.click_visible_element()
        driver.unselect_frame()
