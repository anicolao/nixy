# Design Document: Project Nixy MVP

## 1. Goal
Create a NixOS-based virtual machine image that provides a browser-accessible desktop environment using KasmVNC. The image should be bootable locally (QEMU) and deployable to Google Compute Engine (GCE).

## 2. Architecture
*   **Host OS:** NixOS (managed via Flakes).
*   **Remote Desktop:** KasmVNC running in a Docker/Podman container via `virtualisation.oci-containers`.
*   **Desktop Environment:** XFCE (provided by the KasmVNC core image).
*   **Networking:**
    *   KasmVNC listens on port 6901 (HTTPS/WSS).
    *   Nginx as a reverse proxy on the host, exposing 443 (HTTPS) and forwarding to 6901.
    *   (MVP simplification) For initial testing, we may just expose 6901 directly if TLS termination is handled by KasmVNC, but the goal is to have Nginx on 443.
*   **Build System:** Nix Flakes to define the system and the GCE image build.

## 3. Component Details

### 3.1. Base NixOS Configuration
*   Standard GCE image modules.
*   SSH enabled with a default user.
*   Docker/Podman enabled.

### 3.2. KasmVNC Container
*   Image: `kasmweb/core-xfce-desktop:1.15.0` (or latest).
*   Environment variables for initial password and user.
*   Port mapping: `6901:6901`.

### 3.3. Reverse Proxy (Nginx)
*   Self-signed certificate for the PoC (or Let's Encrypt in a real deployment).
*   WebSocket support for KasmVNC.

## 4. Build & Test Path
*   **Local Build:** `nix build .#nixosConfigurations.nixy-gce.config.system.build.googleComputeImage`
*   **Local Test:** Extract `disk.raw` from the result and run via QEMU using `run-gce-image-qemu.sh`.
*   **Cloud Deployment:** Upload the `*.raw.tar.gz` to GCS and create a GCE image.

## 5. Security Considerations
*   Initial password set via environment variable (to be replaced with a better secret management in later phases).
*   TLS for all browser-to-instance traffic.
