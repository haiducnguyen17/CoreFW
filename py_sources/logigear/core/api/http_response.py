import re


class HTTPResponse:
    def __init__(self, rq_response):
        """
        :type rq_response: requests.Response
        """
        self.url = rq_response.url
        self.method = rq_response.request.method
        self.status_code = int(rq_response.status_code)
        self.reason = rq_response.reason

        self.headers = dict(rq_response.headers)
        self.cookies = dict(rq_response.cookies)

        self.text = rq_response.text
        self.content = rq_response.content

        self.elapsed = rq_response.elapsed

        self._response = rq_response
        self._request = rq_response.request

    def json(self):
        return self._response.json()

    def is_ok(self):
        return self.status_code < 400

    def status_code(self):
        return self.status_code

    def is_2xx(self):
        return 200 <= self.status_code < 300

    def is_3xx(self):
        return 300 <= self.status_code < 400

    def is_4xx(self):
        return 400 <= self.status_code < 500

    def is_5xx(self):
        return 500 <= self.status_code < 600

    def text_in_body(self, text):
        return text in self.text

    def regex_in_body(self, regex):
        return re.match(regex, self.text) is not None

    def headers_as_text(self, delimiter="\n"):
        return delimiter.join("%s: %s" % (key, value) for key, value in self.headers.items())

    def has_header(self, header):
        return header in self.headers

    def has_header_value(self, header, value):
        if not self.has_header(header):
            msg = "Header %s wasn't found in response headers: %r" % (header, self.headers)
            raise RuntimeError(msg)
        return value == self.headers[header]

    def regex_in_headers(self, regex):
        return re.match(regex, self.headers_as_text()) is not None
