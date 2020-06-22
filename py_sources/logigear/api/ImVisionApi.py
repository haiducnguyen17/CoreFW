import os
from logigear import api
from logigear.core.api import http
from logigear.core.config import constants

class ImVisionApiBase:


    def __init__(self, username = "", password = ""):
        if username:
            api.USERNAME = username
        if password:
            api.PASSWORD = password
    
    @property
    def _access_token(self):
#         if api.ACCESS_TOKEN:
#             return (api.TOKEN_TYPE, api.ACCESS_TOKEN)
        
        payload = 'grant_type=password&username=%s&password=%s' % (api.USERNAME, api.PASSWORD)
        headers = { 'Content-Type': 'application/json', 'Accept': 'application/json' }
        resp = self.client.get("/token", data=payload, headers=headers, timeout=constants.SELENPY_API_TIMEOUT)
        api.ACCESS_TOKEN = resp.json()['access_token']
        api.TOKEN_TYPE = resp.json()['token_type']
        return (api.TOKEN_TYPE, api.ACCESS_TOKEN)
    
    @property
    def client(self):
        if api.CLIENT is None:
            api.CLIENT = http.target("http://" + os.environ['system'] + "/imvisionapi")
        return api.CLIENT
    
    def _make_header(self, headers: dict = {}):
        defaultHeader = { 'Authorization': '%s %s' % self._access_token}
        if headers:
            return {**defaultHeader, **headers}
        return defaultHeader
    
    