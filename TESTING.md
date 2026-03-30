# Testing Project Nixy Locally

This guide explains how to build, run, and test the Nixy VM image on your local machine.

## 1. Build the VM Image
Ensure you have Nix installed with Flakes enabled.

```bash
nix build .#nixosConfigurations.nixy-gce.config.system.build.googleComputeImage -o gce
```

## 2. Run Locally with QEMU
Use the provided helper script to launch the image.

```bash
# Provide the path to the built tarball
./scripts/run-qemu.sh ./gce/nixos-image-*.raw.tar.gz
```

### Port Mappings
*   **SSH:** `localhost:2222`
*   **HTTP (Nginx Proxy):** `localhost:8080`
*   **KasmVNC Direct:** `localhost:6901`

### Default Credentials
*   **NixOS User:** `nixy` / `nixy`
*   **KasmVNC:** `nixy` / `nixypoc`

## 3. Automated E2E Testing with Playwright
The project includes a Playwright test suite to verify that the desktop environment loads correctly in a browser.

### Setup
```bash
npm install
npx playwright install chromium
```

### Run Tests
While the VM is running in another terminal:

```bash
npx playwright test
```

The test will:
1.  Navigate to `http://localhost:8080` (the Nginx proxy).
2.  Wait for the Kasm login screen.
3.  Log in using the default credentials.
4.  Verify that the VNC canvas is visible.
5.  Save a screenshot to `desktop-loaded.png`.

## 4. Manual Testing
Once the VM is running, you can manually access the desktop by navigating to `http://localhost:8080` in your web browser. 
Accept any certificate warnings (it uses a self-signed cert internally) and log in with the Kasm credentials above.
