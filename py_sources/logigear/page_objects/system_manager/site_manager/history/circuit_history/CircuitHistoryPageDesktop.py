from logigear.page_objects.system_manager.GeneralPage import GeneralPage


class CircuitHistoryPageDesktop(GeneralPage):
 
    def __init__(self):
        GeneralPage.__init__(self)
        self.circuitTraceMapDiv = self.element("circuitTraceMapDiv")
    
    def check_trace_object_on_circuit_history(self, indexObject, mpoType=None, objectPosition=None, objectPath=None, objectType=None, portIcon=None, connectionType=None, scheduleIcon=None, informationDevice=None):
        self._check_trace_object(self.circuitTraceMapDiv, indexObject, mpoType, objectPosition, objectPath, objectType, portIcon, connectionType, scheduleIcon, informationDevice)

    def close_circuit_history_window(self):
        self.close_dialog()