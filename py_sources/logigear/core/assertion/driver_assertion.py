from logigear.core import browserManagementKeywords

class DriverAssertion():
    
    def location_should_be(self, url, message=None):
        browserManagementKeywords.location_should_be(url, message)
        
    def location_should_contain(self, expected, message=None):
        browserManagementKeywords.location_should_contain(expected, message)
        
    def title_should_be(self, title, message=None):
        browserManagementKeywords.title_should_be(title, message)
    
    