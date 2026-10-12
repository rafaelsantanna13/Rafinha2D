/* Real keyboard/mouse browser playthrough. The game probe is read-only. */
const fs = require('node:fs');
const path = require('node:path');
let playwright;
try { playwright = require('playwright'); }
catch { playwright = require(process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES + '/playwright'); }
const { chromium } = playwright;
const base = process.env.WEB_TEST_URL || 'http://127.0.0.1:8765/';
const screenshots = process.env.WEB_SCREENSHOTS || 'build/preview/screenshots';
fs.mkdirSync(screenshots, { recursive: true });
const results = [];
const check = (value, name) => {
  if (!value) throw new Error(name);
  results.push(name); console.log('WEB PASS:', name);
};

(async () => {
  const browser = await chromium.launch({
    ...(process.env.CHROMIUM_EXECUTABLE ? {executablePath: process.env.CHROMIUM_EXECUTABLE} : {}),
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
  });
  const context = await browser.newContext({viewport: {width: 1280, height: 720}});
  const page = await context.newPage();
  const errors = [];
  page.on('console', message => {
    if (/SCRIPT ERROR|ERROR:|RuntimeError|Aborted\(/i.test(message.text())) errors.push(message.text());
  });
  page.on('pageerror', error => errors.push(error.message));
  const probe = () => page.evaluate(() => window.rafinhaAdventure);
  const until = async (predicate, name, timeout = 30000) => {
    const deadline = Date.now() + timeout;
    while (Date.now() < deadline) {
      const value = await probe();
      if (value && predicate(value)) return value;
      await page.waitForTimeout(100);
    }
    throw new Error(name + ': ' + JSON.stringify(await probe()));
  };
  const capture = async name => page.screenshot({path: path.join(screenshots, name + '.png')});
  const button = async prefix => {
    const value = await until(s => s.menu && s.buttons && s.buttons.length, 'menu layout');
    const item = value.buttons.find(b => b.text.startsWith(prefix));
    if (!item) throw new Error('Missing menu button: ' + prefix);
    await page.mouse.click(item.x + item.w / 2, item.y + item.h / 2);
  };
  const steps = [
    [390, 615, 845, 1065, 1480, 1745],
    [410, 610, 810, 1010, 1480, 1745],
    [410, 625, 840, 1055, 1480, 1745],
  ];
  const heights = [570, 515, 460, 405, 570, 570];
  const travel = async (actor, directionKey, jumpKey, target, expectedLevel) => {
    const deadline = Date.now() + 35000;
    let lastJump = 0;
    let lastX = -1;
    let stuckSince = Date.now();
    await page.keyboard.down(directionKey);
    try {
      while (Date.now() < deadline) {
        const value = await probe();
        if (value.finished || value.level !== expectedLevel) return;
        const [x, y] = value.actors[actor];
        if (x >= target) return;
        if (Math.abs(x - lastX) > 3) stuckSince = Date.now();
        const needsJump = steps[expectedLevel].some((edge, i) => x >= edge - 95 && x <= edge + 14 && y > heights[i] + 4);
        if (value.floors[actor] && (needsJump || Date.now() - stuckSince > 650) && Date.now() - lastJump > 300) {
          await page.keyboard.press(jumpKey, {delay: 45});
          lastJump = Date.now();
        }
        lastX = x;
        await page.waitForTimeout(65);
      }
      throw new Error('Could not traverse castle ' + expectedLevel + ': ' + JSON.stringify(await probe()));
    } finally { await page.keyboard.up(directionKey); }
  };
  try {
    // Optional production check applies when the server is composed under /teste/.
    if (base.endsWith('/teste/')) {
      await page.goto(base.slice(0, -6), {waitUntil: 'load'});
      await page.waitForFunction(() => !document.getElementById('status'), {timeout: 120000});
      await capture('00-oficial-preservado');
      check(true, 'Official Godot menu starts separately at root');
    }
    await page.goto(base, {waitUntil: 'load'});
    await until(s => s.menu && s.buttons?.length, 'WebAssembly menu start', 120000);
    await capture('01-menu');
    check(true, 'Experimental WebAssembly menu starts');
    await button('JOGAR');
    await until(s => s.level === 0, 'first castle');
    await page.waitForTimeout(900);
    await capture('02-castelo-fofins');
    let s = await probe();
    const rafinhaStart = s.actors.Rafinha[0];
    await page.keyboard.down('ArrowRight'); await page.waitForTimeout(200); await page.keyboard.up('ArrowRight');
    await page.waitForTimeout(300);
    s = await probe();
    check(s.actors.Rafinha[0] > rafinhaStart + 15, 'Rafinha original arrow keys move in WebAssembly');
    await page.keyboard.press('Space'); await page.waitForTimeout(250);
    check((await probe()).actors.Rafinha[1] < 610, 'Rafinha Space jumps in WebAssembly');
    await page.waitForTimeout(650);
    await page.keyboard.press('e');
    await page.keyboard.press('h'); await page.waitForTimeout(250); await page.keyboard.press('h');
    await page.waitForTimeout(250);
    await travel('Bigo', 'd', 'v', 1185, 0);
    await until(s => s.dogs.includes('fofins'), 'Fófins proximity rescue', 15000);
    check((await probe()).dogs[0] === 'fofins', 'Bigo reaches and rescues Fófins through keyboard play');
    await page.keyboard.press('c');
    await page.waitForTimeout(1100);
    await capture('03-fofins-resgatada-com-guia');
    check((await probe()).leader === 'Rafinha', 'Rafinha conducts the visible guide');
    await travel('Bigo', 'd', 'v', 2300, 0);
    await until(s => s.level === 1, 'second castle transition');
    check((await probe()).dogs.includes('fofins'), 'Fófins persists across Web scenes');
    await page.waitForTimeout(1700);
    await page.reload({waitUntil: 'load'});
    await until(s => s.menu && s.has_save && s.buttons?.length, 'persisted menu', 120000);
    await button('CONTINUAR');
    await until(s => s.level === 1, 'continue saved castle');
    check((await probe()).dogs.includes('fofins'), 'IndexedDB preserves rescue and castle after browser reload');
    await travel('Bigo', 'd', 'v', 1135, 1);
    await until(s => s.dogs.length === 2, 'second dog rescue', 15000);
    await page.keyboard.press('c'); await page.waitForTimeout(1100);
    await capture('04-dois-cachorros');
    check((await probe()).dogs.length === 2, 'Second castle accumulates two dogs');
    await travel('Bigo', 'd', 'v', 2300, 1);
    await until(s => s.level === 2, 'final castle transition');
    await capture('05-castelo-final');
    await travel('Rafinha', 'ArrowRight', 'Space', 1250, 2);
    await until(s => s.stars === 3, 'collect three final paws');
    check((await probe()).stars === 3, 'Rafinha completes final platform challenge with accumulated dogs');
    await travel('Rafinha', 'ArrowRight', 'Space', 2300, 2);
    await until(s => s.finished, 'celebration');
    await page.waitForTimeout(800);
    await capture('06-festa');
    check(true, 'Three castles are playable through to celebration');
    await page.waitForTimeout(1600);
    await page.reload({waitUntil: 'load'});
    await until(s => s.menu && s.has_save && s.buttons?.length, 'completed save menu', 120000);
    await button('VER A FESTA');
    await until(s => s.finished, 'saved completion');
    check(true, 'Completed adventure persists across browser reload');
    check(errors.length === 0, 'No critical browser or Godot script errors: ' + errors.join('\n'));
    fs.writeFileSync(path.join(screenshots, 'browser-report.json'), JSON.stringify({passed: results, errors}, null, 2));
    console.log('WEB_TEST_SUMMARY:', results.length, 'checks, 0 failures');
  } catch (error) {
    await capture('failure');
    fs.writeFileSync(path.join(screenshots, 'browser-report.json'), JSON.stringify({passed: results, errors, failure: error.message}, null, 2));
    console.error(error);
    process.exitCode = 1;
  } finally { await browser.close(); }
})();
