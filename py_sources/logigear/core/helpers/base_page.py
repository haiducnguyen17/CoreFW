from logigear.core.utilities import utils
from logigear.core.elements import element_factory
from logigear.core.helpers import page_object_helper

class BasePage():
        
    @classmethod
    def get_classname(cls):
        return cls.__name__

    @classmethod
    def get_parent_classname(cls):
        """
        Return the classname of the first parent class
        """
        return cls.__bases__[0].get_classname()
    
    def __init__(self):
        self._pageNames = [ self.get_classname(), self.get_parent_classname() ]
        for i in range(len(self._pageNames)):
            self._pageNames[i] = utils.remove_mode_surfix_from_page(self._pageNames[i]);
        page_object_helper.load_locators_for_pages(self._pageNames);
    
    def element(self, locatorName, targetClass=None):
        return element_factory.get_defined_element(self._pageNames, locatorName, targetClass)
    
