from logigear.core.config.driver_config import DriverConfig
from logigear.core.drivers import driver
from logigear.data import Constants
from logigear.core.helpers.custom_listener import CustomListener
from logigear.utilities.utilities import Utilities
from logigear.core.utilities import utils

__version__ = '4.1.0'
ROBOT_LIBRARY_SCOPE = 'GLOBAL'
ROBOT_LIBRARY_VERSION = __version__

class setup(Utilities):
    
    def __init__(self):
        driverConfig = DriverConfig.get_driver_config()
        self.ROBOT_LIBRARY_LISTENER = CustomListener()

        if driverConfig is not None:
            self.update_enviroment_variable(driverConfig.platform, driverConfig.browser)

        
    def update_enviroment_variable(self, platform, browser):
        try:
            from robot.libraries.BuiltIn import BuiltIn
            BuiltIn().set_global_variable("${PLATFORM}", platform.lower().capitalize())
            BuiltIn().set_global_variable("${BROWSER}", browser.lower().capitalize())
        except Exception as e:
            print ("Getting error when updating environment variables. Error details: \n %s" % e)
            
    def open_page(self, url):
        driver.start_webdriver()
        driver.maximize()
        driver.go_to(url)
    
    def close_browser(self):
        driver.close_all_browsers()
        
    def open_sm_login_page(self):
        self.open_page(Constants.URL)

    def open_simulator_quareo_page(self):
        self.open_page(Constants.QUAREO_DEVICES_URL)
        
    def get_current_date_time(self, timeZone='local', increment=0, resultFormat='timestamp', excludeMillis=False):
        return utils.get_current_date_time(timeZone, increment, resultFormat, excludeMillis)
    
    def add_time_to_date_time(self, date, time, result_format='timestamp', exclude_millis=False, date_format=None):
        return utils.add_time_to_date_time(date, time, result_format, exclude_millis, date_format)  