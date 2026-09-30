// Generates the game's sound effects as small 16-bit mono WAV files.
// Pure synthesis: no third-party audio, no licensing questions.
//   node tool/make_sounds.js
const fs = require('fs');
const path = require('path');
const RATE = 22050;

function tone(freq, ms, { vol = 0.3, shape = 'sine', attack = 5, decay = 1 } = {}) {
  const n = Math.round((RATE * ms) / 1000);
  const out = new Float32Array(n);
  for (let i = 0; i < n; i++) {
    const t = i / RATE;
    const phase = 2 * Math.PI * freq * t;
    let s = shape === 'square' ? Math.sign(Math.sin(phase)) * 0.5 : Math.sin(phase);
    const a = Math.min(1, i / ((RATE * attack) / 1000));
    const d = Math.pow(1 - i / n, decay);
    out[i] = s * vol * a * d;
  }
  return out;
}

function concat(...parts) {
  const len = parts.reduce((a, p) => a + p.length, 0);
  const out = new Float32Array(len);
  let o = 0;
  for (const p of parts) { out.set(p, o); o += p.length; }
  return out;
}

function wav(samples) {
  const data = Buffer.alloc(samples.length * 2);
  samples.forEach((s, i) => data.writeInt16LE(Math.max(-1, Math.min(1, s)) * 32767, i * 2));
  const h = Buffer.alloc(44);
  h.write('RIFF', 0); h.writeUInt32LE(36 + data.length, 4); h.write('WAVE', 8);
  h.write('fmt ', 12); h.writeUInt32LE(16, 16); h.writeUInt16LE(1, 20); h.writeUInt16LE(1, 22);
  h.writeUInt32LE(RATE, 24); h.writeUInt32LE(RATE * 2, 28); h.writeUInt16LE(2, 32); h.writeUInt16LE(16, 34);
  h.write('data', 36); h.writeUInt32LE(data.length, 40);
  return Buffer.concat([h, data]);
}

const sounds = {
  tap: tone(1400, 35, { vol: 0.18, decay: 3 }),
  correct: concat(tone(660, 70, { decay: 0.6 }), tone(990, 110, { decay: 1.5 })),
  wrong: tone(160, 170, { vol: 0.22, shape: 'square', decay: 1.2 }),
  win: concat(...[523.25, 659.25, 783.99, 1046.5].map((f, i) =>
    tone(f, i === 3 ? 260 : 95, { vol: 0.25, decay: i === 3 ? 2 : 0.5 }))),
};

const dir = path.join(__dirname, '..', 'assets', 'sounds');
fs.mkdirSync(dir, { recursive: true });
for (const [name, samples] of Object.entries(sounds)) {
  fs.writeFileSync(path.join(dir, `${name}.wav`), wav(samples));
}
console.log('wrote', Object.keys(sounds).join(', '));
