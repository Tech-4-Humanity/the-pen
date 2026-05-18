// Real browser DOM verification of the LIVE production Signal Theatre page.
// Loads the SSO-bypassed production URL in Chromium, exercises the UI exactly
// as a user would, and asserts the rendered DOM — no inference.
const PW = '/home/claude/.npm-global/lib/node_modules/playwright';
const { chromium } = require(PW);

const URL = process.argv[2];
let pass = 0, fail = 0;
const ok = (c, m) => { if (c) { pass++; console.log('  PASS', m); } else { fail++; console.log('  FAIL', m); } };

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(String(e)));
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });

  const resp = await page.goto(URL, { waitUntil: 'networkidle' });
  ok(resp.status() === 200, `page loaded HTTP ${resp.status()}`);
  ok((await page.title()) === 'Doolittles — Signal Theatre', `title rendered: "${await page.title()}"`);

  // Pristine state
  ok((await page.locator('#packs .empty').count()) === 1, 'packs area shows empty-state before run');
  ok((await page.locator('#proof .empty').count()) === 1, 'proof area shows empty-state before run');
  ok((await page.locator('.chip').count()) === 3, `3 example chips rendered (${await page.locator('.chip').count()})`);

  // Interaction 1: click the reading-pilot chip
  await page.locator('.chip', { hasText: 'reading pilot' }).click();
  await page.waitForSelector('#packs .pack', { timeout: 5000 });
  const packs1 = await page.locator('#packs .pack').count();
  ok(packs1 >= 1, `reading-pilot click rendered ${packs1} pack card(s)`);
  const firstName = (await page.locator('#packs .pack .nm').first().innerText()).trim();
  ok(firstName.length > 0, `top pack card has a name: "${firstName}"`);
  const proofRows1 = await page.locator('#proof table tr').count();
  ok(proofRows1 === 7, `proof table painted header + 6 steps (${proofRows1} rows)`);
  const realCells = await page.locator('#proof .s-REAL').count();
  ok(realCells >= 1, `proof table shows typed REAL state cells (${realCells})`);
  ok((await page.locator('.step.on').count()) === 6, 'all 6 flow steps activated');

  // Interaction 2: free-typed intent, click Run
  await page.fill('#q', 'audit my tradie business for automation');
  await page.click('#go');
  await page.waitForFunction(() => {
    const f = document.querySelector('#packs .pack .nm');
    return f && /trad/i.test(document.querySelector('#packs').innerText);
  }, { timeout: 5000 });
  const tradieText = await page.locator('#packs').innerText();
  ok(/Tradie/i.test(tradieText), 'typed tradie intent rendered the Tradie pack');

  // Interaction 3: source honesty visible in rendered DOM
  const proofText = await page.locator('#proof table').innerText();
  ok(/fixture/.test(proofText), 'rendered proof table shows source=fixture (honest in-browser)');
  ok(!/v_master_product_catalog/.test(proofText), 'fixture run does NOT show live catalogue as source in DOM');

  ok(errors.length === 0, `zero page/console errors (${errors.length}${errors.length ? ': ' + errors.join(' | ') : ''})`);

  await browser.close();
  console.log(`\n${pass} passed, ${fail} failed`);
  process.exit(fail === 0 ? 0 : 1);
})().catch(e => { console.log('FATAL', e.message); process.exit(1); });
