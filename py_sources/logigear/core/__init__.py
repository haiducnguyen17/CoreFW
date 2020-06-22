import os
from SeleniumLibrary import SeleniumLibrary
from SeleniumLibrary.keywords import (AlertKeywords,
                                      BrowserManagementKeywords,
                                      CookieKeywords,
                                      ElementKeywords,
                                      FormElementKeywords,
                                      FrameKeywords,
                                      JavaScriptKeywords,
                                      RunOnFailureKeywords,
                                      ScreenshotKeywords,
                                      SelectElementKeywords,
                                      TableElementKeywords,
                                      WaitingKeywords,
                                      WebDriverCache,
                                      WindowKeywords)
from robot.libraries.OperatingSystem import OperatingSystem

root = os.path.dirname(os.path.abspath(__file__)) + "\\.."
SL = SeleniumLibrary()
OS = OperatingSystem()

browserManagementKeywords = BrowserManagementKeywords(SL)
cookieKeywords = CookieKeywords(SL)
frameKeywords = FrameKeywords(SL) 
javaScriptKeywords = JavaScriptKeywords(SL)
screenshotKeywords = ScreenshotKeywords(SL)
elementKeywords = ElementKeywords(SL)
formElementKeywords = FormElementKeywords(SL)
waitingKeywords = WaitingKeywords(SL)
windowKeywords = WindowKeywords(SL)
selectElementKeywords = SelectElementKeywords(SL)
tableElementKeywords = TableElementKeywords(SL)
