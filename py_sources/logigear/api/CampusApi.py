from logigear.api.ImVisionApi import ImVisionApiBase
from logigear.core.helpers import logger
from logigear.core.config import constants
import json

class CampusApi(ImVisionApiBase):

    def __init__(self, username = "", password = ""):
        ImVisionApiBase.__init__(self, username, password)
        self.basedPath = "/api/campuses"

    def get_campuses(self):
        resp = self.client.get(self.basedPath, headers=self._make_header(), timeout=constants.SELENPY_API_TIMEOUT)
        return resp.json();
    
    def find_campus_by_name(self, name):
        # return -1 if not found
        idValue = -1
        items = self.get_campuses()
        for item in items:
            if item['name'] == name:
                idValue = item['id']
                break;
        return idValue
    
    def add_new_campus(self, name, parentid=1, description=""):
        requestData = { "name": name, "description": description,
                   "concreteAssetTypeId": 2, "parentid": parentid }
        requestData = json.dumps(requestData)
        
        headers = self._make_header({'Content-Type': 'application/json' })
        logger.info("Request data: " + requestData)
        resp = self.client.post(self.basedPath, headers=headers, data=requestData, timeout=constants.SELENPY_API_TIMEOUT)
        idValue = resp.json()['id']
        return idValue
    
    def delete_campus(self, name=None, idValue=None):
        # Delete a Campus by its name or id
        if name:
            idValue = self.find_campus_by_name(name)
            
        if idValue is not None and idValue > -1:
            self.client.delete("{0}/{1}".format(self.basedPath, idValue), headers=self._make_header(), timeout=constants.SELENPY_API_TIMEOUT)

