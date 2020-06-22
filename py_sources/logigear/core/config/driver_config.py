import json
from logigear.core.utilities import utils
from logigear.core.config import constants

class DriverConfig(object):

    @staticmethod
    def get_driver_config(configKey=None, configFile=None):
        
        if configKey is None or configFile is None:
            configKey, configFile = utils.get_config_info()

        config = None
        try:
            with open(configFile) as f:
                data = json.load(f)
                item = data[configKey]
                config = DriverConfig(
                                      item[constants.REMOTE_HOST_KEY],
                                      item[constants.PLATFORM_KEY],
                                      item[constants.BROWSER_KEY],
                                      item[constants.EXECUTABLE_KEY],
                                      item[constants.CAPABILITIES_KEY],
                                      item[constants.OPTIONS_KEY],
                                      item[constants.ARGUMENTS_KEY])
        except FileNotFoundError as fnfe:
            print (fnfe)
        return config

    def __init__(self, host, platform, browser, executable, capabilities={}, options={}, arguments=[]):
        self._remote_host = host
        self._platform = platform
        self._browser = browser
        self._executable = executable
        self._capabilities = capabilities
        self._options = options
        self._arguments = arguments
        self._mode = "local" if "".__eq__(host.strip()) else "remote"


    @property
    def mode(self):
        return self._mode
        
    @property
    def remote_host(self):
        return self._remote_host

    @property
    def platform(self):
        return self._platform

    @property
    def browser(self):
        return self._browser

    @property
    def capabilities(self):
        return self._capabilities

    @capabilities.setter
    def capabilities(self, value):
        self._capabilities = value
    
    @property
    def options(self):
        return self._options

    @options.setter
    def options(self, value):
        self._options = value
        
    @property
    def arguments(self):
        return self._arguments

    @arguments.setter
    def arguments(self, value):
        self._arguments = value

    @property
    def executable(self):
        return self._executable