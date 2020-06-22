from logigear.core.api import http
import os
from logigear.data import Constants as info
from logigear.core.api.utilities import base64_encode
from logigear.core.config import constants

class SimulatorApi():

    def __init__(self):     
        self.target = http.target("http://" + os.environ['middlewaresystem'] + "/api")
    
    def _make_header(self, headers: dict = {}):
        defaultHeader = { 'Authorization': 'Basic %s' % self._encoded_credentials_in_base64()}
        if headers:
            return {**defaultHeader, **headers}
        return defaultHeader
    
    def _encoded_credentials_in_base64(self, username=info.webuser, password=info.password):
        usrPass = "%s:%s" % (username, password)
        encoded = base64_encode(usrPass)
        return str(encoded)
    
    def delete_simulator(self, startAtIp):
        basedPath = "/config/devices/{0}".format(startAtIp)
        self.target.delete(basedPath, headers=self._make_header(), timeout=constants.SELENPY_API_TIMEOUT)