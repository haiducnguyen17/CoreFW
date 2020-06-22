from robot.api import logger
from SeleniumLibrary.utils import is_noney

def info(msg, html=False):
    logger.info(msg, html)

def debug(msg, html=False):
    logger.debug(msg, html)

def log(msg, level='INFO', html=False):
    if not is_noney(level):
        logger.write(msg, level.upper(), html)

def warn(msg, html=False):
    logger.warn(msg, html)
