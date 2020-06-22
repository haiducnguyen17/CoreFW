from importlib import import_module
from logigear.core.config.driver_config import DriverConfig

class DriverFactory:
    driver_factory = None
    module_path = "logigear.core.drivers.browser"
    
    @classmethod
    def get_instance(cls):
        if cls.driver_factory is None:
            cls.driver_factory = DriverFactory()
        return cls.driver_factory
    
    def __init__(self):
        self._driverConfig = DriverConfig.get_driver_config()        
        
    def start_driver(self, alias=None):
        modulePath = ""
        className = ""
        
        if self._driverConfig.mode == "local":
            modulePath = "%s.%s_driver" % (self.module_path, self._driverConfig.browser.lower())
            className = "%sDriver" % self._driverConfig.browser.capitalize()
        elif self._driverConfig.platform == "mobile":
            modulePath = "%s.mobile_driver" % self.module_path
            className = "MobileDriver"
        else:
            modulePath = "%s.remote_driver" % self.module_path
            className = "RemoteDriver"
            
        module = import_module(modulePath)
        driverClass = getattr(module, className)
        driverClass().create_driver(self._driverConfig, alias)
