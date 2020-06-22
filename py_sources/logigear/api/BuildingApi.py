from logigear.api.ImVisionApi import ImVisionApiBase
from logigear.core.helpers import logger
from logigear.core.config import constants
import json

class BuildingApi(ImVisionApiBase):

    def __init__(self, username = "", password = ""):
        ImVisionApiBase.__init__(self, username, password)
        self.basedPath = "/api/buildings"

    def get_buildings(self):
        resp = self.client.get(self.basedPath, headers=self._make_header(), timeout=constants.SELENPY_API_TIMEOUT)
        return resp.json();
        
    def add_new_building(self, name, parentid=1, description=""):
        requestData = { "name": name, "description": description,
                   "concreteAssetTypeId": 3, "parentid": parentid }
        requestData = json.dumps(requestData)
        
        headers = self._make_header({'Content-Type': 'application/json' })
        logger.info("Request data: " + requestData)
        resp = self.client.post(self.basedPath, headers=headers, data=requestData, timeout=constants.SELENPY_API_TIMEOUT)
        idValue = resp.json()['id']
        return idValue
    
    def find_building_by_name(self, name):
        # return -1 if not found
        idValue = -1
        items = self.get_buildings()
        for item in items:
            if item['name'] == name:
                idValue = item['id']
                break;
        return idValue
    
    def delete_building(self, name=None, idValue=None):
        # Delete a Building by its name or id
        if name:
            idValue = self.find_building_by_name(name)
            
        if idValue is not None and idValue > -1:
            self.client.delete("{0}/{1}".format(self.basedPath, idValue), headers=self._make_header(), timeout=constants.SELENPY_API_TIMEOUT)

