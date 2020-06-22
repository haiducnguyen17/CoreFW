import base64
from uuid import uuid4
from urllib.parse import quote_plus


def base64_decode(encoded):
    decoded = base64.b64decode(encoded)
    return decoded.decode()


def base64_encode(plaintext):
    if not isinstance(plaintext, bytes):
        plaintext = plaintext.encode()
    encoded = base64.b64encode(plaintext)
    return encoded.decode()


def encode_url(chars):
    return quote_plus(chars)


def uuid():
    return str(uuid4())
