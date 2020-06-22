from logigear.core import browserManagementKeywords
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from logigear.core.drivers.browser.base_driver import BaseDriver
from webdriver_manager.chrome import ChromeDriverManager

class ChromeDriver(BaseDriver):

    def create_driver(self, config, alias=None):
        chrome_options = webdriver.ChromeOptions()
        capabilities = DesiredCapabilities.CHROME.copy()
        
        for argument in config.arguments:
            chrome_options.add_argument(argument)
        
        capabilities.update(config.capabilities)
        driver_path = ChromeDriverManager().install()

        browserManagementKeywords.create_webdriver(
            "Chrome", alias, executable_path=driver_path,
            options=chrome_options, desired_capabilities=capabilities)
