from robot.libraries.BuiltIn import BuiltIn

class RobotAssertion():

    def __init__(self):
        self.robot = BuiltIn()

    def fail(self, msg=None, *tags):
        self.robot.fail(msg, tags)
    
    def fatal_error(self, msg=None):
        self.robot.fatal_error(msg)
    
    def should_not_be_true(self, condition, msg=None):
        self.robot.should_not_be_true(condition, msg)
        
    def should_be_true(self, condition, msg=None):
        self.robot.should_be_true(condition, msg)
        
    def should_be_equal(self, first, second, msg=None, values=True,
                        ignore_case=False, formatter='str'):
        self.robot.should_be_equal(first, second, msg, values, ignore_case, formatter)
        
    def should_not_be_equal(self, first, second, msg=None, values=True,
                            ignore_case=False):
        self.robot.should_not_be_equal(first, second, msg, values, ignore_case)

    def should_not_be_equal_as_integers(self, first, second, msg=None,
                                        values=True, base=None):
        self.robot.should_not_be_equal_as_integers(first, second, msg, values, base)
    
    def should_be_equal_as_integers(self, first, second, msg=None, values=True,
                                    base=None):
        self.robot.should_be_equal_as_integers(first, second, msg, values, base)
        
    def should_not_be_equal_as_numbers(self, first, second, msg=None,
                                       values=True, precision=6):
        self.robot.should_not_be_equal_as_numbers(first, second, msg, values, precision)
        
    def should_be_equal_as_numbers(self, first, second, msg=None, values=True,
                                   precision=6):
        self.robot.should_be_equal_as_numbers(first, second, msg, values, precision)

    def should_not_be_equal_as_strings(self, first, second, msg=None,
                                       values=True, ignore_case=False):
        self.robot.should_not_be_equal_as_strings(first, second, msg, values, ignore_case)
    
    def should_be_equal_as_strings(self, first, second, msg=None, values=True,
                                   ignore_case=False, formatter='str'):
        self.robot.should_be_equal_as_strings(first, second, msg, values, ignore_case, formatter)
    
    def should_not_start_with(self, str1, str2, msg=None, values=True,
                              ignore_case=False):
        self.robot.should_not_start_with(str1, str2, msg, values, ignore_case)
    
    def should_start_with(self, str1, str2, msg=None, values=True,
                          ignore_case=False):
        self.robot.should_start_with(str1, str2, msg, values, ignore_case)
        
    def should_not_end_with(self, str1, str2, msg=None, values=True,
                            ignore_case=False):
        self.robot.should_not_end_with(str1, str2, msg, values, ignore_case)
        
    def should_end_with(self, str1, str2, msg=None, values=True,
                        ignore_case=False):
        self.robot.should_end_with(str1, str2, msg, values, ignore_case)
    
    def should_not_contain(self, container, item, msg=None, values=True,
                           ignore_case=False):
        self.robot.should_not_contain(container, item, msg, values, ignore_case)
    
    def should_contain(self, container, item, msg=None, values=True,
                       ignore_case=False):
        self.robot.should_contain(container, item, msg, values, ignore_case)
    
    def should_contain_any(self, container, *items, **configuration):
        self.robot.should_contain_any(container, items, configuration)
    
    def should_not_contain_any(self, container, *items, **configuration):
        self.robot.should_not_contain_any(container, items, configuration)
    
    def should_contain_x_times(self, item1, item2, count, msg=None,
                               ignore_case=False):
        self.robot.should_contain_x_times(item1, item2, count, msg, ignore_case)
    
    def should_not_match(self, string, pattern, msg=None, values=True,
                         ignore_case=False):
        self.robot.should_not_match(string, pattern, msg, values, ignore_case)
    
    def should_match(self, string, pattern, msg=None, values=True,
                     ignore_case=False):
        self.robot.should_match(string, pattern, msg, values, ignore_case)
    
    def should_match_regexp(self, string, pattern, msg=None, values=True):
        self.robot.should_match_regexp(string, pattern, msg, values)
    
    def should_not_match_regexp(self, string, pattern, msg=None, values=True):
        self.robot.should_not_match_regexp(string, pattern, msg, values)
    
    def length_should_be(self, item, length, msg=None):
        self.robot.length_should_be(item, length, msg)
    
    def should_be_empty(self, item, msg=None):
        self.robot.should_be_empty(item, msg)
    
    def should_not_be_empty(self, item, msg=None):
        self.robot.should_not_be_empty(item, msg)
    
