"""App Store Connect API helpers shared by fill_listing.py and game_center.py.
Needs ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_P8 in the environment."""
import base64
import hashlib
import json
import os
import pathlib
import re
import sys
import time

import jwt  # PyJWT
import requests

ROOT = pathlib.Path(__file__).resolve().parents[2]
API = 'https://api.appstoreconnect.apple.com'

def key_pem() -> str:
    raw = os.environ['ASC_KEY_P8']
    body = re.sub(r'-----(BEGIN|END)[A-Z ]*-----', '', raw)
    body = re.sub(r'[^A-Za-z0-9+/=]', '', body)
    base64.b64decode(body, validate=True)
    lines = [body[i:i + 64] for i in range(0, len(body), 64)]
    return '-----BEGIN PRIVATE KEY-----\n' + '\n'.join(lines) + '\n-----END PRIVATE KEY-----\n'


_token = {'value': None, 'at': 0}


def token() -> str:
    if time.time() - _token['at'] > 600:
        now = int(time.time())
        _token['value'] = jwt.encode(
            {'iss': os.environ['ASC_ISSUER_ID'], 'iat': now, 'exp': now + 1100,
             'aud': 'appstoreconnect-v1'},
            key_pem(), algorithm='ES256',
            headers={'kid': os.environ['ASC_KEY_ID'], 'typ': 'JWT'})
        _token['at'] = time.time()
    return _token['value']


class ApiError(Exception):
    pass


def call(method: str, path: str, body=None, params=None):
    r = requests.request(method, API + path, params=params, json=body, timeout=60,
                         headers={'Authorization': f'Bearer {token()}'})
    if r.status_code >= 400:
        try:
            errs = r.json().get('errors', [])
            msg = '; '.join(f"{e.get('title')}: {e.get('detail')}" for e in errs)
        except ValueError:
            msg = r.text[:300]
        raise ApiError(f'{method} {path} -> {r.status_code}: {msg}')
    return r.json() if r.content else {}


