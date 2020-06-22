from selenium import webdriver
from logigear.core.drivers.browser.base_driver import BaseDriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from webdriver_manager.firefox import GeckoDriverManager
from logigear.core import browserManagementKeywords

class FirefoxDriver(BaseDriver):

    def create_driver(self, config, alias=None):
        firefox_options = webdriver.FirefoxOptions()
        capabilities = DesiredCapabilities.FIREFOX.copy()
        
        for argument in config.arguments:
            firefox_options.add_argument(argument)
        
        capabilities.update(config.capabilities)
        driver_path = GeckoDriverManager().install()
        
        browserManagementKeywords.create_webdriver(
            "Firefox", alias, executable_path=driver_path,
            options=firefox_options, desired_capabilities=capabilities)
