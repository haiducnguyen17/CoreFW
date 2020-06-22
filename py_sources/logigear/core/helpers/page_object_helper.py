from os import path
import json
from logigear.core import root
from logigear.core.helpers import logger

mPageLocators = {}
locatorFolder = root + "/locators"

def load_locators_for_pages(pages):
    for page in pages:
        load_locator_for_page(page)
    
def load_locator_for_page(sPage):
    
    if sPage in mPageLocators:
        return True
    
    locatorFile = "%s/%s.json" % (locatorFolder, sPage)
    if not path.exists(locatorFile):
        logger.warn("%s file doesn't exist" % locatorFile)
        return False
    
    try:
        lstLocators = None
        with open(locatorFile) as f:
            lstLocators = json.load(f)
            
        isLocatorLoaded = lstLocators is not None
        if isLocatorLoaded:
            mPageLocators[sPage] = lstLocators
        else:
            raise Exception("%s file is invalid syntax or empty" % locatorFile)
        return True
    except Exception as e:
        if hasattr(e, 'message'):
            logger.warn(e.message)
        else:
            logger.warn(e)

        return False


def get_page_locators(sPage):
    if mPageLocators is None: return None
    
    return mPageLocators[sPage] if sPage in mPageLocators else None


