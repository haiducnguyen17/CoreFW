from logigear.core import SL, browserManagementKeywords, cookieKeywords,\
    windowKeywords, screenshotKeywords, waitingKeywords, frameKeywords,\
    javaScriptKeywords
from logigear.core.drivers.driver_factory import DriverFactory
from logigear.core.config import constants

"""
    ==================== DRIVER'S FUNCTIONS
"""
def start_webdriver(alias=None):
    DriverFactory.get_instance().start_driver(alias)
    
def create_webdriver(driver_name, alias=None, kwargs={},
                         **init_kwargs):
    return browserManagementKeywords.create_webdriver(driver_name, alias, kwargs, **init_kwargs)

def open_browser(url=None, browser='chrome', alias=None,
                     remote_url=False, desired_capabilities=None,
                     ff_profile_dir=None, options=None, service_log_path=None):
    return browserManagementKeywords.open_browser(url, browser, alias, remote_url, desired_capabilities, ff_profile_dir, options, service_log_path)

def close_all_browsers():
    browserManagementKeywords.close_all_browsers()

def close_browser():
    browserManagementKeywords.close_browser()

def switch_browser(index_or_alias):
    browserManagementKeywords.switch_browser(index_or_alias)

def go_to(url):
    browserManagementKeywords.go_to(url)
    
def maximize():
    SL.driver.maximize_window()

def minimize():
    SL.driver.maximize_window() 

def get_browser_ids():
    return browserManagementKeywords.get_browser_ids()

def get_browser_aliases():
    return browserManagementKeywords.get_browser_aliases()

def get_session_id():
    return browserManagementKeywords.get_session_id()

def get_source():
    return browserManagementKeywords.get_source()

def get_title():
    return browserManagementKeywords.get_title()

def get_location():
    return browserManagementKeywords.get_location()

def log_location():
    return browserManagementKeywords.log_location()

def log_source(loglevel='INFO'):
    return browserManagementKeywords.log_source(loglevel)

def log_title():
    return browserManagementKeywords.log_title()

def go_back():
    browserManagementKeywords.go_back()

def reload_page():
    browserManagementKeywords.reload_page()

def get_selenium_speed():
    return browserManagementKeywords.get_selenium_speed()

def get_selenium_timeout():
    return browserManagementKeywords.get_selenium_timeout()

def get_selenium_implicit_wait():
    return browserManagementKeywords.get_selenium_implicit_wait()

def set_selenium_speed(value):
    return browserManagementKeywords.set_selenium_speed(value)

def set_selenium_timeout(value):
    return browserManagementKeywords.set_selenium_timeout(value)

def set_selenium_implicit_wait(value):
    return browserManagementKeywords.set_selenium_implicit_wait(value)

def set_browser_implicit_wait(value):
    browserManagementKeywords.set_browser_implicit_wait(value)

"""
    COOKIE FUNCTIONS
"""
def delete_all_cookies():
    cookieKeywords.delete_all_cookies()

def delete_cookie(name):
    cookieKeywords.delete_cookie(name)

def get_cookies(as_dict=False):
    return cookieKeywords.get_cookies(as_dict)

def get_cookie(name):
    return cookieKeywords.get_cookie(name)

def add_cookie(name, value, path=None, domain=None, secure=None,
               expiry=None):
    cookieKeywords.add_cookie(name, value, path, domain, secure, expiry)

"""
    FRAMEWORK's FUNCTIONS
"""
def select_frame(element):
    frameKeywords.select_frame(element.locator())

def unselect_frame():
    frameKeywords.unselect_frame()

"""
    WINDOW's FUNCTIONS
"""
def select_window(locator='MAIN', timeout=None):
    return windowKeywords.select_window(locator, timeout)

def switch_window(locator='MAIN', timeout=None, browser='CURRENT'):
    return windowKeywords.switch_window(locator, timeout, browser)

def close_window():
    return windowKeywords.close_window()

def get_window_handles(browser='CURRENT'):
    return windowKeywords.get_window_handles(browser)

def get_window_identifiers(browser='CURRENT'):
    return windowKeywords.get_window_identifiers(browser)

def get_window_names(browser='CURRENT'):
    return windowKeywords.get_window_names(browser)

def get_window_titles(browser='CURRENT'):
    return windowKeywords.get_window_titles(browser)

def get_locations(browser='CURRENT'):
    return windowKeywords.get_locations(browser)

def maximize_browser_window():
    windowKeywords.maximize_browser_window()

def get_window_size(inner=False):
    return windowKeywords.get_window_size(inner)

def set_window_size(width, height, inner=False):
    windowKeywords.set_window_size(width, height, inner)

def get_window_position():
    return windowKeywords.get_window_position()

def set_window_position(x, y):
    windowKeywords.set_window_position(x, y)
    
"""
    SCREENSHOT's FUNCTIONS
"""
def set_screenshot_directory(path):
    return screenshotKeywords.set_screenshot_directory(path)

def capture_page_screenshot(filename='selenium-screenshot-{index}.png'):
    return screenshotKeywords.capture_page_screenshot(filename)

def capture_element_screenshot(locator, filename='selenium-element-screenshot-{index}.png'):
    return screenshotKeywords.capture_element_screenshot(locator, filename)

"""
    WAITING FUNCTIONS
"""
def wait_for_condition(condition, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
    waitingKeywords.wait_for_condition(condition, timeout, error)

def wait_until_location_is(expected, timeout=constants.SELENPY_OBJECT_WAIT, message=None):
    waitingKeywords.wait_until_location_is(expected, timeout, message)

def wait_until_location_contains(expected, timeout=constants.SELENPY_OBJECT_WAIT, message=None):
    waitingKeywords.wait_until_location_contains(expected, timeout, message)

def wait_until_page_contains(text, timeout=constants.SELENPY_OBJECT_WAIT, error=None):
    waitingKeywords.wait_until_page_contains(text, timeout, error)

def wait_until_page_does_not_contain(text, timeout=constants.SELENPY_OBJECT_WAIT,
                                     error=None):
    waitingKeywords.wait_until_page_does_not_contain(text, timeout, error)

"""
    JAVASCRIPT's FUNCTIONS
"""
def execute_javascript(js_code, *js_args):
    javaScriptKeywords._js_logger('Executing JavaScript', js_code, js_args)
    return javaScriptKeywords.driver.execute_script(js_code, *js_args)

def execute_async_javascript(js_code, *js_args):
    javaScriptKeywords._js_logger('Executing Asynchronous JavaScript', js_code, js_args)
    return javaScriptKeywords.driver.execute_async_script(js_code, *js_args)
