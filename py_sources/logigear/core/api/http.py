import logging
import requests
from .http_response import HTTPResponse
from .http_target import HTTPTarget

log = logging.getLogger("api")


def target(*args, **kwargs):
    return HTTPTarget(*args, **kwargs)


def request(method, address, session=None,
            params=None, headers=None, cookies=None, data=None, json=None, allow_redirects=True, timeout=30):
    """

    :param method: str
    :param address: str
    :return: response
    :rtype: HTTPResponse
    """
    log.info("Request: %s %s", method, address)
    msg = "Request: params=%r, headers=%r, cookies=%r, data=%r, json=%r, allow_redirects=%r, timeout=%r"
    log.debug(msg, params, headers, cookies, data, json, allow_redirects, timeout)

    if headers is None:
        headers = {}

    if session is None:
        session = requests.Session()
    req = requests.Request(method, address,
                           params=params, headers=headers, cookies=cookies, json=json, data=data)
    prepared = req.prepare()
    try:
        response = session.send(prepared, allow_redirects=allow_redirects, timeout=timeout)
    except requests.exceptions.Timeout:
        raise TimeoutError("Connection to %s timed out" % address)
    except requests.exceptions.ConnectionError:
        raise ConnectionError("Connection to %s failed" % address)
    except BaseException:
        raise
    log.info("Response: %s %s", response.status_code, response.reason)
    log.debug("Response headers: %r", response.headers)
    log.debug("Response cookies: %r", dict(response.cookies))
    log.debug('Response content: \n%s', response.content)
    return HTTPResponse(response)
