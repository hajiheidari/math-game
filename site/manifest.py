#!/usr/bin/env python3
"""Writes files.json for the Iranian mirror (espadna.ir, espadna-site/mirror-ir/sync.php).

One manifest per mirrored source, like Tiaro's scripts/build-site.mjs:
  dist-site/files.json            the game  (adadi.espadna.com -> adadi.espadna.ir)
  dist-site/adadi-app/files.json  landing   (espadna.com/adadi-app -> espadna.ir/adadi-app)
Every file with size + sha256; the _redirects text inline (Cloudflare does not serve it).

    python3 site/manifest.py dist-site
"""
import hashlib
import json
import pathlib
import sys


def write_manifest(folder: pathlib.Path, skip_dir: str | None = None) -> int:
    files = []
    for f in sorted(p for p in folder.rglob('*') if p.is_file()):
        rel = f.relative_to(folder).as_posix()
        if rel in ('files.json', '_headers', '_redirects'):
            continue
        if skip_dir and rel.startswith(skip_dir + '/'):
            continue
        data = f.read_bytes()
        files.append({'path': rel, 'size': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
    version = hashlib.sha256(''.join(f['sha256'] for f in files).encode()).hexdigest()[:12]
    redirects = folder / '_redirects'
    manifest = {'version': version, 'files': files,
                'redirects': redirects.read_text() if redirects.exists() else ''}
    (folder / 'files.json').write_text(json.dumps(manifest))
    return len(files)


if __name__ == '__main__':
    out = pathlib.Path(sys.argv[1])
    game = write_manifest(out, 'adadi-app')
    landing = write_manifest(out / 'adadi-app')
    print(f'files.json: game {game} files, adadi-app {landing} files')
