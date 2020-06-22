from logigear.core.elements.element import Element
from logigear.core.utilities import utils
from logigear.core.helpers import page_object_helper, logger


def get_defined_element(pageNames, locatorName, targetClass=None):
    locator = None
    for pageName in pageNames:
        locator = get_defined_locator(pageName, locatorName)
        if locator is not None:
            break;
    
    if locator is None:
        msg = "Cannot find locator for '%s' in '%s'." % (locatorName, pageName)
        raise Exception(msg)
    
    if targetClass:
        return targetClass(get_locator(locator["locators"]))
    return Element(get_locator(locator["locators"]))


def get_defined_locator(pageName, locatorName):
    pageLocators = page_object_helper.get_page_locators(pageName)
    
    if pageLocators is None:
        logger.warn("Cannot find %s page" % pageName)
        return None
    
    locator = next((l for l in pageLocators if l["name"] == locatorName), None)
    return locator

def get_locator(locators):
    platform, browser = utils.get_environment()
    platform, browser = (platform.lower(), browser.lower())
    
    sKey1 = "%s.%s" % (browser, platform);
    sKey2 = "%s._" % browser;
    sKey3 = "_.%s" % platform;
    sKey4 = "_._";
    
    sValue = [e for e in locators if e.startswith(sKey1)]
    if len(sValue) == 0:
        sValue = [e for e in locators if e.startswith(sKey2)]
    if len(sValue) == 0:
        sValue = [e for e in locators if e.startswith(sKey3)]
    if len(sValue) == 0:
        sValue = [e for e in locators if e.startswith(sKey4)]
        
    if len(sValue) == 0: 
        msg = "Cannot find locator in " + locators
        print (msg)
        raise Exception(msg)
    
    return sValue[0].split(':', 1)[1]
