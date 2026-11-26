import { test, expect } from '@playwright/test';

// The picker is the site's only interactive component, and the checks below are
// the behaviours the labels are there to communicate: which space the values are
// in, and that editing any one of them updates the others.

test.beforeEach(async ({ page }) => {
    await page.goto('/');
});

test('labels describe the HSLuv components', async ({ page }) => {
    for (const name of ['Hue', 'Saturation', 'Lightness']) {
        await expect(page.getByLabel(name)).toBeVisible();
    }
    await expect(page.getByLabel('sRGB hex')).toBeVisible();
});

test('entering a hex updates the HSLuv components', async ({ page }) => {
    await page.getByLabel('sRGB hex').fill('#3d7fb8');
    await expect(page.getByLabel('Hue')).toHaveValue('244.6');
    await expect(page.getByLabel('Saturation')).toHaveValue('80.4');
    await expect(page.getByLabel('Lightness')).toHaveValue('51.4');
});

test('editing lightness updates the hex', async ({ page }) => {
    await page.getByLabel('sRGB hex').fill('#3d7fb8');
    const lightness = page.getByLabel('Lightness');
    await lightness.fill('70');
    await expect(page.getByLabel('sRGB hex')).toHaveValue('#71b0ef');
});

test('clicking a label focuses its field', async ({ page }) => {
    await page.locator('#control-s label').click();
    await expect(page.getByLabel('Saturation')).toBeFocused();
});

test('the default color is unchanged', async ({ page }) => {
    await expect(page.getByLabel('sRGB hex')).toHaveValue('#ea0064');
});
