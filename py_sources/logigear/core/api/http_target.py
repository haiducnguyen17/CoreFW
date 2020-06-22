import copy
import requests
from . import http


class HTTPTarget(object):
    def __init__(self,
                 address,
                 base_path=None,
                 use_cookies=True,
                 additional_headers=None,
                 keep_alive=True,
                 timeout=30,
                 allow_redirects=True):
        self.address = address
        # config flags
        self._base_path = base_path
        self._use_cookies = use_cookies
        self._keep_alive = keep_alive
        self._additional_headers = additional_headers or {}
        self._timeout = timeout
        self._allow_redirects = allow_redirects
        # internal vars
        self.__session = None

    def use_cookies(self, use=True):
        self._use_cookies = use
        return self

    def base_path(self, base_path):
        self._base_path = base_path
        return self

    def keep_alive(self, keep=True):
        self._keep_alive = keep
        return self

    def additional_headers(self, headers):
        self._additional_headers.update(headers)
        return self

    def timeout(self, value):
        self._timeout = value
        return self

    def allow_redirects(self, value=True):
        self._allow_redirects = value
        return self

    def _bake_address(self, path):
        address = self.address
        if self._base_path is not None:
            address += self._base_path
        address += path
        return address

    def request(self, method, path,
                params=None, headers=None, cookies=None, data=None, json=None, allow_redirects=None, timeout=None):
        """
        Prepares and sends an HTTP request. Returns the HTTPResponse object.
        :param method: str
        :param path: str
        :return: response
        :rtype: HTTPResponse
        """
        headers = headers or {}
        timeout = timeout if timeout is not None else self._timeout
        allow_redirects = allow_redirects if allow_redirects is not None else self._allow_redirects

        if self._keep_alive and self.__session is None:
            self.__session = requests.Session()

        if self.__session is not None and not self._use_cookies:
            self.__session.cookies.clear()

        address = self._bake_address(path)
        req_headers = copy.deepcopy(self._additional_headers)
        req_headers.update(headers)

        response = http.request(method, address, session=self.__session,
                                params=params, headers=headers, cookies=cookies, data=data, json=json,
                                allow_redirects=allow_redirects, timeout=timeout)
        return response

    def get(self, path, **kwargs):
        return self.request("GET", path, **kwargs)

    def post(self, path, **kwargs):
        return self.request("POST", path, **kwargs)

    def put(self, path, **kwargs):
        return self.request("PUT", path, **kwargs)

    def delete(self, path, **kwargs):
        return self.request("DELETE", path, **kwargs)

    def patch(self, path, **kwargs):
        return self.request("PATCH", path, **kwargs)

    def head(self, path, **kwargs):
        return self.request("HEAD", path, **kwargs)

    def options(self, path, **kwargs):
        return self.request("OPTIONS", path, **kwargs)

    def connect(self, path, **kwargs):
        return self.request("CONNECT", path, **kwargs)
