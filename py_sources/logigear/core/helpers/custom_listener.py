from logigear.core import drivers
from datetime import datetime
import socket 


class CustomListener(object):
    ROBOT_LISTENER_API_VERSION = 2
   
    FAILED = False
   
    def end_keyword(self, name, attrs):
        if not self.FAILED and attrs['status'] != 'PASS':
            try:
                self.FAILED = True
                filename = "{0}-{1}.png".format(socket.gethostname(), datetime.now().strftime("%m%d%Y-%H%M%S%f"))
                drivers.driver.capture_page_screenshot(filename)
            except Exception as e:
                raise Exception("Could not capture page screenshot due to exception:\n" + e.message);
            raise
