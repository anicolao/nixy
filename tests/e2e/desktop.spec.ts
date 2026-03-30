import { test, expect } from '@playwright/test';

test('desktop loads and login works', async ({ page }) => {
  // Go to the Nginx proxy (which forwards to KasmVNC)
  await page.goto('/');

  // KasmVNC usually has a login form. 
  // Based on standard Kasm images, it might have fields for username/password.
  // We'll wait for a generic login indication.
  await expect(page).toHaveTitle(/Kasm/);

  // Attempt login using credentials from configuration.nix
  // Note: KasmVNC login selectors can be tricky if they are in a shadow DOM or canvas,
  // but usually it's a standard form for the web client.
  
  // These selectors are guesses based on typical Kasm web client:
  const usernameField = page.locator('input[name="username"]');
  const passwordField = page.locator('input[name="password"]');
  const loginButton = page.locator('button#login_button, button[type="submit"]');

  if (await usernameField.isVisible({ timeout: 10000 })) {
    await usernameField.fill('nixy');
    await passwordField.fill('nixypoc');
    await loginButton.click();
  }

  // After login, we expect a desktop environment canvas or similar
  // The KasmVNC interface usually has a "kasm_canvas" or similar.
  await expect(page.locator('#vnc-canvas, canvas')).toBeVisible({ timeout: 30000 });
  
  // Take a screenshot of the loaded desktop
  await page.screenshot({ path: 'desktop-loaded.png' });
});
