const {chromium} = require('playwright');
(async () => {
  const browser = await chromium.launch({headless: true, args: ['--no-sandbox', '--disable-dev-shm-usage', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
  const page = await browser.newPage({viewport: {width: 1280, height: 720}});
  const errors = [];
  let gzipRequested = false;
  page.on('pageerror', e => errors.push(e.message));
  page.on('request', r => {if (r.url().endsWith('index.wasm.gz')) gzipRequested = true;});
  page.on('console', m => {if (/SCRIPT ERROR|ERROR:|RuntimeError/i.test(m.text())) errors.push(m.text());});
  try {
    await page.goto('http://127.0.0.1:8767/', {waitUntil: 'load'});
    await page.waitForFunction(() => window.rafinhaAdventure?.menu && window.rafinhaAdventure.buttons?.length, null, {timeout: 120000});
    const button = await page.evaluate(() => window.rafinhaAdventure.buttons.find(b => b.text === 'JOGAR'));
    await page.mouse.click(button.x + button.w / 2, button.y + button.h / 2);
    await page.waitForFunction(() => window.rafinhaAdventure?.level === 0, null, {timeout: 15000});
    if (!gzipRequested || errors.length) throw new Error(JSON.stringify({gzipRequested, errors}));
    console.log('COMPRESSED_WEB_PASS: Godot WASM decompressed, menu and first castle started without errors');
  } finally {await browser.close();}
})().catch(error => {console.error(error);process.exitCode = 1;});
