from logigear.page_objects.quareo_simulator.QSGeneralPage import QSGeneralPage
from logigear.core.elements.element import Element


class CableTemplatesPageDesktop(QSGeneralPage):
    
    def __init__(self):
        QSGeneralPage.__init__(self);
        self.cableTemplateCbb = self.element("cableTemplateCbb")
        self.cableSerialNumberTxt = self.element("cableSerialNumberTxt")
        self.generateBtn = self.element("generateBtn")
        self.headsTextarea = self.element("headsTextarea")
        self.tailsTextarea = self.element("tailsTextarea")
        
    def generate_cable_template(self, typeTemplate, serialNumber):
        """- typeTemplate: H1LCDuplex-T1LCDuplex-AtoB, H1LCDuplex-T1LCDuplex-AtoA, H1MPO12-T6LCDuplex-STRAIGHT, H2MPO12-T2MPO12-STRAIGHT
        , H1MPO12-T1MPO12-STRAIGHT, H1MPO12-T1MPO12-FLIPPED, H1MPO24-T1MPO24-STRAIGHT, H1MPO24-T1MPO24-FLIPPED, H2MPO24-T2MPO24-STRAIGHT
        , H1LCSimplex-T1LCSimplex, H4MPO12-T4MPO12-STRAIGHT, H1RJ45-T1RJ45
        - serialNumber: number not string"""
        
        self._go_to_sub_page("Cable Templates")
        self.cableTemplateCbb.select_from_list_by_label(typeTemplate)
        self.cableSerialNumberTxt.input_text(serialNumber)
        self.generateBtn.click_visible_element()
        self.headsTextarea.wait_until_element_is_visible()
        totalHeads = self.headsTextarea.get_element_count()
        totalTails = self.tailsTextarea.get_element_count()
        listHeads = []
        listTails = []
        for i in range(totalHeads):
            headsXpath = self.headsTextarea.locator() + "[%s]" % str(i+1)
            headsValue = Element(headsXpath).get_element_attribute("value")
            listHeads.append(headsValue) 
        for i in range(totalTails):
            tailsXpath = self.tailsTextarea.locator() + "[%s]" % str(i+1)
            tailsValue = Element(tailsXpath).get_element_attribute("value")
            listTails.append(tailsValue)    
        
        return [listHeads, listTails]