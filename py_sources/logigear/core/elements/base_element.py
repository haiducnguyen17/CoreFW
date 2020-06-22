from abc import ABC

class BaseElement(ABC):

    def __init__(self, locator, parent=None):
        self._locator = locator
        self._args = []
        self.parent = parent
        super().__init__()
    
    @property
    def arguments(self):
        return self._args
    
    @arguments.setter
    def arguments(self, args):
        self._args = args
    
    def locator(self):
        if self.parent:
            return self.parent.locator() + self._locator.format(*self._args)
        return self._locator.format(*self._args)

