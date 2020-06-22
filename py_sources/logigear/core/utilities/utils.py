from robot.libraries.BuiltIn import BuiltIn
import re
from importlib import import_module
from robot.libraries import DateTime
import os
from logigear.core import root
import winreg

def get_environment():
    robotBuiltin = BuiltIn()
    platform = "_"
    browser = "_"
    try:
        platform = robotBuiltin.get_variable_value("${PLATFORM}", "_")
        browser = robotBuiltin.get_variable_value("${BROWSER}", "_")
    except Exception as e:
        print (e)
    return (platform, browser)


def get_config_info():
    robotBuiltin = BuiltIn()
    configKey = ""
    configFile = ""
    try:
        configKey = robotBuiltin.get_variable_value("${CONFIGKEY}")
        configFile = robotBuiltin.get_variable_value("${CONFIGFILE}")
    except Exception as e:
        print (e)
    return (configKey, configFile)


def remove_mode_surfix_from_page(pageName):
    """
    Page name should be "PageName<Mode>"
    Example
        LoginPageMobile, HomePageDesktop
    """
    newPageName = re.split(r'(?=Mobile)|(?=mobile)|(?=Desktop)|(?=desktop)', pageName)[0]
    return newPageName


def get_page(pageName):
    platform = BuiltIn().get_variable_value("${PLATFORM}")
    className = pageName + platform
    packageName = _find_page_object_package(root + "\\page_objects", className + ".py")
    packageName = "logigear." + packageName
    if packageName is None:
        raise Exception("%s not found" % className)
    
    modulePath = packageName.replace("\\", ".") + "." + className
    module = import_module(modulePath)
    pageClass = getattr(module, className)
    return pageClass()
    
def _find_page_object_package(currentModule, filePyName):
    children = os.listdir(currentModule)
    lastPackage = os.path.basename(currentModule)
    found = None
    for child in children:
        if child.lower() == filePyName.lower():
            return lastPackage
        elif '.py' not in child:
            found = _find_page_object_package(os.path.join(currentModule, child), filePyName)
            if found is not None:
                found = lastPackage + "." + found
                break;
    
    return found;

def get_current_date_time(timeZone='local', increment=0, resultFormat='timestamp', excludeMillis=False):
    return DateTime.get_current_date(timeZone, increment, resultFormat, excludeMillis)

def add_time_to_date_time(date, time, result_format='timestamp', exclude_millis=False, date_format=None):
    return DateTime.add_time_to_date(date, time, result_format, exclude_millis, date_format)

def fatal_error(message=None):
    BuiltIn().fatal_error(message)
    
def get_registry_value(regChannel, registryPath, variableName):
    proc_arch = os.environ['PROCESSOR_ARCHITECTURE'].lower()
    proc_arch64 = os.environ['PROCESSOR_ARCHITEW6432'].lower()
    if proc_arch == 'x86' and not proc_arch64:
        arch_keys = {0}
    elif proc_arch == 'x86' or proc_arch == 'amd64':
        arch_keys = {winreg.KEY_WOW64_32KEY, winreg.KEY_WOW64_64KEY}
    else:
        raise Exception("Unhandled arch: %s" % proc_arch)
    for arch_key in arch_keys:
        try:
            listRegistry = registryPath.split("\\")
            hkname = listRegistry[-1]
            remainPath = registryPath[:len(registryPath) - len(hkname) - 1]
            if regChannel == "HKEY_LOCAL_MACHINE":
                regChannel = winreg.HKEY_LOCAL_MACHINE
            elif regChannel == "HKEY_CLASSES_ROOT":
                regChannel = winreg.HKEY_CLASSES_ROOT
            elif regChannel == "HKEY_CURRENT_CONFIG":
                regChannel = winreg.HKEY_CURRENT_CONFIG
            elif regChannel == "HKEY_CURRENT_USER":
                regChannel = winreg.HKEY_CURRENT_USER
            elif regChannel == "HKEY_USERS":
                regChannel = winreg.HKEY_USERS
            key = winreg.OpenKey(regChannel, remainPath, 0, winreg.KEY_READ | arch_key)
            for i in range(0, winreg.QueryInfoKey(key)[0]):
                try:
                    keyName = winreg.EnumKey(key, i)
                    if keyName == hkname:
                        subKey = winreg.OpenKey(key, keyName)
                        value = winreg.QueryValueEx(subKey, variableName)
                        value = value[0]
                        value = value.replace('"',"")
                        return value
                except WindowsError:
                    return False
        except:
            return False