// adadi.espadna.com: the static site (web game, privacy, landing pages) plus
// the small friend-hints API (app/lib/rewards/friend_hints.dart).
//
//   POST /api/visit  {"r": code, "d": visitor's code}  a friend opened r's link
//   POST /api/claim  {"s": secret, "max": n}            the player collects hints
//
// One Durable Object per player (named by the public code). A friend counts
// once a day per player: by their device code and by their IP address (kept
// only as a salted hash, for 2 days), so sending the link to the same person
// again, or opening it in another browser, earns nothing. Unclaimed hints are
// kept (up to BANK_MAX) for the following days; the app takes at most 3 a day.
import { DurableObject } from 'cloudflare:workers';

const BANK_MAX = 9;
const CODE = /^[a-z2-9]{10}$/;
const ALPHABET = 'abcdefghijkmnpqrstuvwxyz23456789';

async function sha256(text) {
  return new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text)));
}

/** Public code of a secret: same as FriendHints.codeFor in the app. */
export async function codeFor(secret) {
  const bytes = await sha256(secret);
  let out = '';
  for (let i = 0; i < 10; i++) out += ALPHABET[bytes[i] % 32];
  return out;
}

/** The visitor's IP address, salted with the player's code and hashed: never stored as is. */
async function ipHash(request, code) {
  const ip = request.headers.get('CF-Connecting-IP') ?? '';
  return [...(await sha256(`adadi:${code}:${ip}`)).slice(0, 12)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

const today = () => new Date().toISOString().slice(0, 10);

export class Referrals extends DurableObject {
  constructor(ctx, env) {
    super(ctx, env);
    this.sql = ctx.storage.sql;
    this.sql.exec(`CREATE TABLE IF NOT EXISTS seen (day TEXT NOT NULL, who TEXT NOT NULL, PRIMARY KEY (day, who));
                   CREATE TABLE IF NOT EXISTS bank (id INTEGER PRIMARY KEY, pending INTEGER NOT NULL)`);
  }

  pending() {
    const row = this.sql.exec('SELECT pending FROM bank WHERE id = 1').toArray()[0];
    return row ? row.pending : 0;
  }

  setPending(n) {
    this.sql.exec('INSERT INTO bank (id, pending) VALUES (1, ?) ON CONFLICT(id) DO UPDATE SET pending = excluded.pending', n);
  }

  /** A friend opened the link. True if it counted. */
  visit(day, device, ipHash) {
    this.sql.exec('DELETE FROM seen WHERE day < ?', new Date(Date.parse(day) - 86400000).toISOString().slice(0, 10));
    const seen = this.sql
      .exec('SELECT COUNT(*) AS n FROM seen WHERE day = ? AND who IN (?, ?)', day, 'd:' + device, 'i:' + ipHash)
      .toArray()[0].n;
    if (seen > 0) return false;
    this.sql.exec('INSERT OR IGNORE INTO seen (day, who) VALUES (?, ?), (?, ?)', day, 'd:' + device, day, 'i:' + ipHash);
    this.setPending(Math.min(BANK_MAX, this.pending() + 1));
    return true;
  }

  /** The player collects up to max hints. Their own address is marked as
   *  seen for the day, so opening their own link from it earns nothing. */
  claim(max, day, ipHash) {
    this.sql.exec('INSERT OR IGNORE INTO seen (day, who) VALUES (?, ?)', day, 'i:' + ipHash);
    const n = Math.min(this.pending(), max);
    if (n > 0) this.setPending(this.pending() - n);
    return n;
  }
}

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const json = (body, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'no-store', ...CORS },
  });

async function api(request, env, path) {
  if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS });
  if (request.method !== 'POST') return json({ error: 'method' }, 405);
  let body;
  try {
    body = JSON.parse(await request.text());
  } catch {
    return json({ error: 'json' }, 400);
  }
  const player = (code) => env.REFERRALS.get(env.REFERRALS.idFromName(code));

  if (path === '/api/visit') {
    const { r, d } = body;
    if (!CODE.test(r ?? '') || !CODE.test(d ?? '') || r === d) return json({ error: 'code' }, 400);
    const counted = await player(r).visit(today(), d, await ipHash(request, r));
    return json({ counted });
  }

  if (path === '/api/claim') {
    const { s, max } = body;
    if (typeof s !== 'string' || s.length < 16 || s.length > 64) return json({ error: 'secret' }, 400);
    const n = Math.max(0, Math.min(3, Number(max) | 0));
    const code = await codeFor(s);
    const granted = n === 0 ? 0 : await player(code).claim(n, today(), await ipHash(request, code));
    return json({ granted });
  }

  return json({ error: 'not found' }, 404);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.startsWith('/api/')) return api(request, env, url.pathname);
    return env.ASSETS.fetch(request);
  },
};
