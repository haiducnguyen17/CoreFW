from logigear.core import elementKeywords, formElementKeywords,\
    selectElementKeywords, tableElementKeywords
from logigear.core.assertion.robot_assertion import RobotAssertion

class ElementAssertion():

    def element_attribute_value_should_be(self, element, attribute, expected, message=None):
        elementKeywords.element_attribute_value_should_be(element.locator(), attribute, expected, message)
        
    def element_attribute_value_should_contain(self, element, attribute, expected, message=None):
        attributeValue = elementKeywords.get_element_attribute(element.locator(), attribute)
        RobotAssertion().should_contain(attributeValue, expected, message)
        
    def element_attribute_value_should_not_contain(self, element, attribute, expected, message=None):
        attributeValue = elementKeywords.get_element_attribute(element.locator(), attribute)
        RobotAssertion().should_not_contain(attributeValue, expected, message)

    def element_should_be_disabled(self, element):
        elementKeywords.element_should_be_disabled(element.locator())
    
    def element_should_be_enabled(self, element):
        elementKeywords.element_should_be_enabled(element.locator())     
    
    def element_should_be_focused(self, element):
        elementKeywords.element_should_be_focused(element.locator())
    
    def element_should_be_visible(self, element, message=None):
        elementKeywords.element_should_be_visible(element.locator(), message)
    
    def element_should_not_be_visible(self, element, message=None):
        elementKeywords.element_should_not_be_visible(element.locator(), message)
    
    def element_should_contain(self, element, expected, message=None, ignore_case=False):
        elementKeywords.element_should_contain(element.locator(), expected, message, ignore_case)
        
    def element_should_not_contain(self, element, expected, message=None, ignore_case=False):
        elementKeywords.element_should_not_contain(element.locator(), expected, message, ignore_case)
        
    def element_text_should_be(self, element, expected, message=None, ignore_case=False):
        elementKeywords.element_text_should_be(element.locator(), expected, message, ignore_case)
    
    def element_text_should_not_be(self, element, expected, message=None, ignore_case=False):
        elementKeywords.element_text_should_not_be(element.locator(), expected, message, ignore_case)
    
    def page_should_contain_element(self, element, message=None,
                                    loglevel='TRACE', limit=None):
        elementKeywords.page_should_contain_element(element.locator(), message, loglevel, limit)
   
    def page_should_not_contain_element(self, element, message=None,
                                    loglevel='TRACE'):
        elementKeywords.page_should_not_contain_element(element.locator(), message, loglevel)
   
    def checkbox_should_be_selected(self, element):
        formElementKeywords.checkbox_should_be_selected(element.locator())    
        
    def checkbox_should_not_be_selected(self, element):
        formElementKeywords.checkbox_should_not_be_selected(element.locator())
        
    def page_should_contain_checkbox(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_contain_checkbox(element.locator(), message, loglevel)
    
    def page_should_not_contain_checkbox(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_not_contain_checkbox(element.locator(), message, loglevel)
        
    def page_should_contain_radio_button(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_contain_radio_button(element.locator(), message, loglevel)
    
    def page_should_not_contain_radio_button(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_not_contain_radio_button(element.locator(), message, loglevel)
    
    def page_should_contain_textfield(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_contain_textfield(element.locator(), message, loglevel)
        
    def page_should_not_contain_textfield(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_not_contain_textfield(element.locator(), message, loglevel)
        
    def textfield_should_contain(self, element, expected, message=None):
        formElementKeywords.textfield_should_contain(element.locator(), expected, message)
        
    def textfield_value_should_be(self, element, expected, message=None):
        formElementKeywords.textfield_value_should_be(element.locator(), expected, message)
    
    def textarea_should_contain(self, element, expected, message=None):
        formElementKeywords.textarea_should_contain(element.locator(), expected, message)
    
    def textarea_value_should_be(self, element, expected, message=None):
        formElementKeywords.textarea_value_should_be(element.locator(), expected, message) 
    
    def page_should_contain_button(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_contain_button(element.locator(), message, loglevel)
    
    def page_should_not_contain_button(self, element, message=None, loglevel='TRACE'):
        formElementKeywords.page_should_not_contain_button(element.locator(), message, loglevel)
        
    def list_selection_should_be(self, element, *expected):
        selectElementKeywords.list_selection_should_be(element.locator(), expected)
        
    def list_should_have_no_selections(self, element):
        selectElementKeywords.list_should_have_no_selections(element.locator())
        
    def page_should_contain_list(self, element, message=None, loglevel='TRACE'):
        selectElementKeywords.page_should_contain_list(element.locator(), message, loglevel)
        
    def page_should_not_contain_list(self, element, message=None, loglevel='TRACE'):
        selectElementKeywords.page_should_not_contain_list(element.locator(), message, loglevel)
        
    def table_cell_should_contain(self, element, row, column, expected, loglevel='TRACE'):
        tableElementKeywords.table_cell_should_contain(element.locator(), row, column, expected, loglevel)
        
    def table_column_should_contain(self, element, column, expected, loglevel='TRACE'):
        tableElementKeywords.table_column_should_contain(element.locator(), column, expected, loglevel)
        
    def table_footer_should_contain(self, element, expected, loglevel='TRACE'):
        tableElementKeywords.table_footer_should_contain(element.locator(), expected, loglevel)
        
    def table_header_should_contain(self, element, expected, loglevel='TRACE'):
        tableElementKeywords.table_header_should_contain(element.locator(), expected, loglevel)
        
    def table_row_should_contain(self, element, row, expected, loglevel='TRACE'):
        tableElementKeywords.table_row_should_contain(element.locator(), row, expected, loglevel)
    
    def table_should_contain(self, element, expected, loglevel='TRACE'):
        tableElementKeywords.table_should_contain(element.locator(), expected, loglevel)
    