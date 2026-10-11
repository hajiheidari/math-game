#!/usr/bin/env python3
"""Fills Adadi's App Store page through the App Store Connect API.

    python3 tool/asc/fill_listing.py [--submit]

Reads tool/asc/listing.json and the screenshots in docs/store/appstore/.
Needs ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_P8 (an Admin key) in the
environment; run by .github/workflows/appstore-page.yml.

Each step reports OK or the API's error and the script goes on, so one
failure (e.g. a field Apple renamed) does not stop the rest. Things the API
cannot do (App Privacy answers) are left for Amir. With --submit, the
version is also sent to App Review.
"""
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
CFG = json.loads((ROOT / 'tool/asc/listing.json').read_text())
SHOTS = ROOT / 'docs/store/appstore'

results = []


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


def step(name):
    def wrap(fn):
        def run(*a, **k):
            try:
                out = fn(*a, **k)
                results.append(('OK', name, out or ''))
                print(f'OK    {name} {out or ""}', flush=True)
                return out
            except Exception as e:  # report and go on
                results.append(('FAIL', name, str(e)))
                print(f'FAIL  {name}: {e}', flush=True)
                return None
        return run
    return wrap


def rel(type_, id_):
    return {'data': {'type': type_, 'id': id_}}


# --- The app and its editable records ---------------------------------------

app = call('GET', '/v1/apps', params={'filter[bundleId]': CFG['bundleId']})['data']
if not app:
    sys.exit(f"No app with bundle id {CFG['bundleId']} in App Store Connect")
APP = app[0]['id']
print(f'app {APP}: {app[0]["attributes"]["name"]}')

infos = call('GET', f'/v1/apps/{APP}/appInfos')['data']
editable = [i for i in infos if i['attributes'].get('appStoreState', i['attributes'].get('state'))
            not in ('READY_FOR_SALE', 'READY_FOR_DISTRIBUTION')]
INFO = (editable or infos)[0]['id']

versions = call('GET', f'/v1/apps/{APP}/appStoreVersions',
                params={'filter[platform]': 'IOS', 'limit': 10})['data']
open_states = {'PREPARE_FOR_SUBMISSION', 'DEVELOPER_REJECTED', 'REJECTED', 'METADATA_REJECTED',
               'INVALID_BINARY'}
VERSION = next((v['id'] for v in versions
                if v['attributes'].get('appStoreState') in open_states), None)


@step('content rights: no third-party content')
def content_rights():
    call('PATCH', f'/v1/apps/{APP}', {'data': {'type': 'apps', 'id': APP, 'attributes': {
        'contentRightsDeclaration': 'DOES_NOT_USE_THIRD_PARTY_CONTENT'}}})


@step('name, subtitle, privacy policy URL')
def app_info_localization():
    locs = call('GET', f'/v1/appInfos/{INFO}/appInfoLocalizations')['data']
    loc = next((l for l in locs if l['attributes']['locale'] == CFG['locale']), None)
    attrs = {'name': CFG['name'], 'subtitle': CFG['subtitle'],
             'privacyPolicyUrl': CFG['privacyPolicyUrl']}
    if loc:
        call('PATCH', f'/v1/appInfoLocalizations/{loc["id"]}',
             {'data': {'type': 'appInfoLocalizations', 'id': loc['id'], 'attributes': attrs}})
    else:
        call('POST', '/v1/appInfoLocalizations', {'data': {
            'type': 'appInfoLocalizations', 'attributes': {'locale': CFG['locale'], **attrs},
            'relationships': {'appInfo': rel('appInfos', INFO)}}})


@step('category: Games > Puzzle, Educational')
def categories():
    # Subcategory ids differ from what one would guess: look them up.
    subs = call('GET', f"/v1/appCategories/{CFG['primaryCategory']}/subcategories",
                params={'limit': 200})['data']
    ids = [c['id'] for c in subs]
    want = [i for i in (CFG['primarySubcategoryOne'], CFG['primarySubcategoryTwo']) if i in ids]
    if not want:
        raise ApiError(f'subcategories available: {ids}')
    rels = {'primaryCategory': rel('appCategories', CFG['primaryCategory']),
            'primarySubcategoryOne': rel('appCategories', want[0])}
    if len(want) > 1:
        rels['primarySubcategoryTwo'] = rel('appCategories', want[1])
    call('PATCH', f'/v1/appInfos/{INFO}', {'data': {'type': 'appInfos', 'id': INFO,
                                                    'relationships': rels}})
    return ', '.join(want)


@step('age rating: nothing objectionable, shown as 13+')
def age_rating():
    decl = call('GET', f'/v1/appInfos/{INFO}/ageRatingDeclaration')['data']
    skip = ('ageRatingOverride', 'ageRatingOverrideV2', 'koreaAgeRatingOverride',
            'kidsAgeBand', 'koreaAgeRating', 'developerAgeRatingInfoUrl')
    # Every question answered "no": False for yes/no questions, NONE for
    # frequency questions. Unset fields have no type to go by, so Apple's
    # "Expected a BOOLEAN" errors tell us which are yes/no.
    attrs = {k: (False if isinstance(v, bool) else 'NONE')
             for k, v in decl['attributes'].items()
             if k not in skip and 'grac' not in k.lower() and 'korea' not in k.lower()}
    override = {'ageRatingOverrideV2': CFG['ageRatingOverride']}
    for attempt in range(4):
        try:
            call('PATCH', f'/v1/ageRatingDeclarations/{decl["id"]}', {'data': {
                'type': 'ageRatingDeclarations', 'id': decl['id'],
                'attributes': {**attrs, **override}}})
            return 'override 13+' if override else 'answers set (override left for Amir)'
        except ApiError as e:
            msg = str(e)
            bools = re.findall(r"attribute '(\w+)'\. Expected a BOOLEAN", msg)
            enums = re.findall(r"attribute '(\w+)'\. Expected a STRING", msg)
            for k in bools:
                attrs[k] = False
            for k in enums:
                attrs[k] = 'NONE'
            if not bools and not enums:
                if override and 'ageRatingOverride' in msg:
                    override = {}
                    continue
                raise
    raise ApiError('age rating: gave up after 4 tries')


@step('version number and copyright')
def version_attrs():
    if not VERSION:
        raise ApiError('no editable iOS version')
    build_version = latest_build()['attributes']['version']
    short = latest_build_short()
    call('PATCH', f'/v1/appStoreVersions/{VERSION}', {'data': {
        'type': 'appStoreVersions', 'id': VERSION,
        'attributes': {'versionString': short, 'copyright': CFG['copyright']}}})
    return f'{short} (build {build_version})'


_build = {}


def latest_build():
    if 'b' not in _build:
        builds = call('GET', '/v1/builds', params={
            'filter[app]': APP, 'sort': '-uploadedDate', 'limit': 10,
            'include': 'preReleaseVersion'})
        valid = [b for b in builds['data'] if b['attributes'].get('processingState') == 'VALID']
        if not valid:
            raise ApiError('no processed (VALID) build yet')
        _build['b'] = valid[0]
        pre = {i['id']: i['attributes']['version'] for i in builds.get('included', [])}
        rid = valid[0]['relationships']['preReleaseVersion']['data']['id']
        _build['short'] = pre.get(rid)
    return _build['b']


def latest_build_short():
    latest_build()
    return _build['short']


@step('attach the latest build')
def attach_build():
    b = latest_build()
    call('PATCH', f'/v1/appStoreVersions/{VERSION}/relationships/build', rel('builds', b['id']))
    return f"{latest_build_short()} ({b['attributes']['version']})"


def version_localization():
    locs = call('GET', f'/v1/appStoreVersions/{VERSION}/appStoreVersionLocalizations')['data']
    loc = next((l for l in locs if l['attributes']['locale'] == CFG['locale']), None)
    if loc:
        return loc['id']
    return call('POST', '/v1/appStoreVersionLocalizations', {'data': {
        'type': 'appStoreVersionLocalizations', 'attributes': {'locale': CFG['locale']},
        'relationships': {'appStoreVersion': rel('appStoreVersions', VERSION)}}})['data']['id']


@step('description, keywords, promotional text, URLs')
def version_texts():
    lid = version_localization()
    call('PATCH', f'/v1/appStoreVersionLocalizations/{lid}', {'data': {
        'type': 'appStoreVersionLocalizations', 'id': lid, 'attributes': {
            'description': CFG['description'], 'keywords': CFG['keywords'],
            'promotionalText': CFG['promotionalText'], 'supportUrl': CFG['supportUrl'],
            'marketingUrl': CFG['marketingUrl']}}})


def upload_screenshot(set_id: str, path: pathlib.Path):
    data = path.read_bytes()
    shot = call('POST', '/v1/appScreenshots', {'data': {
        'type': 'appScreenshots', 'attributes': {'fileName': path.name, 'fileSize': len(data)},
        'relationships': {'appScreenshotSet': rel('appScreenshotSets', set_id)}}})['data']
    for op in shot['attributes']['uploadOperations']:
        chunk = data[op['offset']:op['offset'] + op['length']]
        headers = {h['name']: h['value'] for h in op.get('requestHeaders', [])}
        r = requests.request(op['method'], op['url'], data=chunk, headers=headers, timeout=120)
        if r.status_code >= 400:
            raise ApiError(f'upload {path.name}: {r.status_code}')
    call('PATCH', f'/v1/appScreenshots/{shot["id"]}', {'data': {
        'type': 'appScreenshots', 'id': shot['id'],
        'attributes': {'uploaded': True, 'sourceFileChecksum': hashlib.md5(data).hexdigest()}}})
    return shot['id']


def screenshots(display: str, files: list):
    @step(f'screenshots {display} ({len(files)})')
    def run():
        lid = version_localization()
        sets = call('GET', f'/v1/appStoreVersionLocalizations/{lid}/appScreenshotSets')['data']
        s = next((x for x in sets if x['attributes']['screenshotDisplayType'] == display), None)
        if s is None:
            s = call('POST', '/v1/appScreenshotSets', {'data': {
                'type': 'appScreenshotSets', 'attributes': {'screenshotDisplayType': display},
                'relationships': {'appStoreVersionLocalization':
                                  rel('appStoreVersionLocalizations', lid)}}})['data']
        old = call('GET', f'/v1/appScreenshotSets/{s["id"]}/appScreenshots')['data']
        for o in old:  # replace, so the script can run again
            call('DELETE', f'/v1/appScreenshots/{o["id"]}')
        ids = [upload_screenshot(s['id'], SHOTS / f) for f in files]
        # Apple checks the sizes after the upload.
        for _ in range(12):
            time.sleep(5)
            states = [call('GET', f'/v1/appScreenshots/{i}')['data']['attributes']
                      .get('assetDeliveryState', {}) for i in ids]
            if all(st.get('state') in ('COMPLETE', 'FAILED') for st in states):
                break
        failed = [st for st in states if st.get('state') == 'FAILED']
        if failed:
            raise ApiError(f'{len(failed)} rejected: {failed[0].get("errors")}')
        return 'all accepted'
    return run()


@step('App Review contact and notes (phone left for Amir)')
def review_details():
    r = CFG['review']
    attrs = {'contactFirstName': r['contactFirstName'], 'contactLastName': r['contactLastName'],
             'contactEmail': r['contactEmail'], 'demoAccountRequired': False, 'notes': r['notes']}
    phone = os.environ.get('ASC_CONTACT_PHONE', '').strip()
    if phone:
        attrs['contactPhone'] = phone
    try:
        d = call('GET', f'/v1/appStoreVersions/{VERSION}/appStoreReviewDetail')['data']
    except ApiError:
        d = None
    if d:
        call('PATCH', f'/v1/appStoreReviewDetails/{d["id"]}', {'data': {
            'type': 'appStoreReviewDetails', 'id': d['id'], 'attributes': attrs}})
    else:
        call('POST', '/v1/appStoreReviewDetails', {'data': {
            'type': 'appStoreReviewDetails', 'attributes': attrs,
            'relationships': {'appStoreVersion': rel('appStoreVersions', VERSION)}}})
    return 'with phone' if phone else 'no phone yet'


@step('price: free')
def price_free():
    points = call('GET', f'/v1/apps/{APP}/appPricePoints',
                  params={'filter[territory]': 'USA', 'limit': 200})['data']
    free = next(p for p in points if float(p['attributes']['customerPrice']) == 0)
    call('POST', '/v1/appPriceSchedules', {
        'data': {'type': 'appPriceSchedules', 'relationships': {
            'app': rel('apps', APP), 'baseTerritory': rel('territories', 'USA'),
            'manualPrices': {'data': [{'type': 'appPrices', 'id': '${free}'}]}}},
        'included': [{'type': 'appPrices', 'id': '${free}', 'attributes': {'startDate': None},
                      'relationships': {'appPricePoint': rel('appPricePoints', free['id'])}}]})


@step('availability: all countries')
def availability():
    territories = []
    url, params = '/v1/territories', {'limit': 200}
    while url:
        page = call('GET', url, params=params)
        territories += [t['id'] for t in page['data']]
        nxt = page.get('links', {}).get('next')
        url, params = (nxt.replace(API, ''), None) if nxt else (None, None)
    included = [{'type': 'territoryAvailabilities', 'id': f'${{{t}}}',
                 'attributes': {'available': True},
                 'relationships': {'territory': rel('territories', t)}} for t in territories]
    try:
        existing = call('GET', f'/v1/apps/{APP}/appAvailabilityV2')['data']
    except ApiError:
        existing = None
    if existing:
        return 'already set'
    call('POST', '/v2/appAvailabilities', {
        'data': {'type': 'appAvailabilities', 'attributes': {'availableInNewTerritories': True},
                 'relationships': {'app': rel('apps', APP), 'territoryAvailabilities': {
                     'data': [{'type': 'territoryAvailabilities', 'id': i['id']} for i in included]}}},
        'included': included})
    return f'{len(territories)} countries'


@step('submit for App Review')
def submit():
    sub = call('POST', '/v1/reviewSubmissions', {'data': {
        'type': 'reviewSubmissions', 'attributes': {'platform': 'IOS'},
        'relationships': {'app': rel('apps', APP)}}})['data']
    call('POST', '/v1/reviewSubmissionItems', {'data': {
        'type': 'reviewSubmissionItems',
        'relationships': {'reviewSubmission': rel('reviewSubmissions', sub['id']),
                          'appStoreVersion': rel('appStoreVersions', VERSION)}}})
    call('PATCH', f'/v1/reviewSubmissions/{sub["id"]}', {'data': {
        'type': 'reviewSubmissions', 'id': sub['id'], 'attributes': {'submitted': True}}})


content_rights()
app_info_localization()
categories()
age_rating()
if VERSION:
    version_attrs()
    attach_build()
    version_texts()
    for display, files in CFG['screenshots'].items():
        screenshots(display, files)
    review_details()
else:
    results.append(('FAIL', 'version page', 'no editable iOS version in App Store Connect'))
price_free()
availability()
if '--submit' in sys.argv:
    submit()

print('\nSummary')
for status, name, detail in results:
    print(f'  {status:4}  {name}' + (f'  ({detail})' if status == 'FAIL' else ''))
sys.exit(1 if any(r[0] == 'FAIL' for r in results) else 0)
