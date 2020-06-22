from robot.model.visitor import SuiteVisitor


class TestCollector(SuiteVisitor):

    def __init__(self, pathFile):
        self.tests = []
        self._read_file(pathFile)
    
    def start_suite(self, suite):
        """Select tests that match the given pattern."""
        if self.tests:
            suite.tests = [t for t in suite.tests if self._is_matched(t)]
        else:
            suite.tests = []

    def end_suite(self, suite):
        """Remove suites that are empty after selecting tests."""
        suite.suites = [s for s in suite.suites if s.test_count > 0]

    def visit_test(self, test):
        """Avoid visiting tests and their keywords to save a little time."""
        pass
    
    def _read_file(self, filePath): 
        try:
            f = open(filePath, "r")
            for line in f:
                testName = line.strip()
                if testName != "":
                    self.tests.append(testName)
        except Exception as e:
            print (e)
        
    def _is_matched(self, test):
        return test.name in self.tests