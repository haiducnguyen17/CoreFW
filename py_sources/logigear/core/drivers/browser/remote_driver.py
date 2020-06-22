from logigear.core.drivers.browser.base_driver import BaseDriver
from logigear.core import browserManagementKeywords

class RemoteDriver(BaseDriver):

    def create_driver(self, config, alias=None):
        
        browserManagementKeywords.create_webdriver(
            "Remote", alias, command_executor=config.remote_host,
            desired_capabilities=config.capabilities)
