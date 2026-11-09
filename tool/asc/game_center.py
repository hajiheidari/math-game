#!/usr/bin/env python3
"""Sets up Adadi's Game Center in App Store Connect (idempotent):
the Game Center record and three leaderboards, ids as in
app/lib/services/game_center.dart. Same key as fill_listing.py (asc_api.py);
run by .github/workflows/appstore-page.yml (input "game_center").
"""
import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from asc_api import ApiError, call, rel  # noqa: E402

BOARDS = [
    ('adadi.best_streak', 'Best daily streak', 'Best Daily Streak'),
    ('adadi.levels', 'Levels completed', 'Levels Completed'),
    ('adadi.stars', 'Stars', 'Total Stars'),
]

app = call('GET', '/v1/apps', params={'filter[bundleId]': 'com.espadna.adadi'})['data'][0]
APP = app['id']
print('app', APP)

try:
    detail = call('GET', f'/v1/apps/{APP}/gameCenterDetail').get('data')
except ApiError as e:
    print('no Game Center record yet:', e)
    detail = None
if not detail:
    detail = call('POST', '/v1/gameCenterDetails', {'data': {
        'type': 'gameCenterDetails',
        'relationships': {'app': rel('apps', APP)}}})['data']
    print('created Game Center record', detail['id'])
DETAIL = detail['id']
print('Game Center record', DETAIL)

existing = {b['attributes']['vendorIdentifier']: b for b in call(
    'GET', f'/v1/gameCenterDetails/{DETAIL}/gameCenterLeaderboards',
    params={'limit': 50})['data']}
print('existing leaderboards:', sorted(existing))

failed = False
for vendor, ref, name in BOARDS:
    try:
        board = existing.get(vendor)
        if board is None:
            board = call('POST', '/v1/gameCenterLeaderboards', {'data': {
                'type': 'gameCenterLeaderboards',
                'attributes': {
                    'referenceName': ref, 'vendorIdentifier': vendor,
                    'defaultFormatter': 'INTEGER', 'submissionType': 'BEST_SCORE',
                    'scoreSortType': 'DESC'},
                'relationships': {'gameCenterDetail': rel('gameCenterDetails', DETAIL)}}})['data']
            print('created', vendor)
        locs = call('GET', f'/v1/gameCenterLeaderboards/{board["id"]}/localizations')['data']
        if not any(l['attributes']['locale'] == 'en-US' for l in locs):
            call('POST', '/v1/gameCenterLeaderboardLocalizations', {'data': {
                'type': 'gameCenterLeaderboardLocalizations',
                'attributes': {'locale': 'en-US', 'name': name},
                'relationships': {'gameCenterLeaderboard':
                                  rel('gameCenterLeaderboards', board['id'])}}})
            print('  named', name)
        print('OK   ', vendor, json.dumps(board['attributes'].get('archived')))
    except Exception as e:  # report, go on
        failed = True
        print('FAIL ', vendor, e)

sys.exit(1 if failed else 0)
