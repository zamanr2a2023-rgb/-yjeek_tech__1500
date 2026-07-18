// Dev-only TCP relay: PC 127.0.0.1:3000 -> backend 192.168.10.251:3000.
// Used with `adb reverse tcp:3000 tcp:3000` so the phone reaches the backend
// over the USB cable: app -> phone localhost:3000 -> PC -> backend.
// Run: node tool/dev_proxy.js
// Also re-applies the adb reverse tunnel every 10s, since it silently drops
// whenever the phone's USB connection resets.
const net = require('net');
const { execFile } = require('child_process');

function ensureAdbReverse() {
  execFile('adb', ['reverse', 'tcp:3000', 'tcp:3000'], (err) => {
    if (err) console.error('dev_proxy: adb reverse failed:', err.message);
  });
}
ensureAdbReverse();
setInterval(ensureAdbReverse, 10_000);

const BACKEND_HOST = '192.168.10.251';
const BACKEND_PORT = 3000;
const LISTEN_PORT = 3000;

net
  .createServer((client) => {
    const upstream = net.connect(BACKEND_PORT, BACKEND_HOST);
    client.pipe(upstream);
    upstream.pipe(client);
    client.on('error', () => upstream.destroy());
    upstream.on('error', () => client.destroy());
  })
  .listen(LISTEN_PORT, '127.0.0.1', () => {
    console.log(
      `dev_proxy: 127.0.0.1:${LISTEN_PORT} -> ${BACKEND_HOST}:${BACKEND_PORT}`,
    );
  });
