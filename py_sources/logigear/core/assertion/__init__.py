from logigear.core.assertion.driver_assertion import DriverAssertion
from logigear.core.assertion.element_assertion import ElementAssertion
from robot.utils import asserts
from robot.libraries.BuiltIn import BuiltIn
from logigear.core.assertion.robot_assertion import RobotAssertion


class Assertion(DriverAssertion, ElementAssertion):
    
    def __init__(self):
        """"""
    
SeleniumAssert = Assertion()
Assert = RobotAssertion()


        
