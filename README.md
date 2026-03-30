# Project Nixy: Cloud Desktop Proof of Concept (PoC)

## 1. Overview & Intent
This project is a proof of concept to evaluate the viability of a browser-accessible, cloud-hosted Linux desktop environment. This PoC serves as the foundational infrastructure testing ground for "Nixy" (working title), a visionary AI-powered desktop OS. 

The primary goal of this PoC is to determine if a modern, WebRTC/WebSocket-based streaming protocol can deliver a highly performant, low-latency, and visually polished desktop experience entirely within a standard web browser, without requiring the user to install dedicated client software (like native VNC or RDP clients). 

We are strictly using declarative infrastructure to ensure the environment is reproducible, ephemeral, and easily deployable to cloud providers.

## 2. Architecture & Tech Stack
* **Host Operating System:** NixOS. The entire system must be defined declaratively (ideally using Nix Flakes) for absolute reproducibility.
* **Remote Display Protocol:** KasmVNC. Chosen for its native WebSocket (WSS) transport, WebP/H.264 encoding, and hardware-accelerated browser decoding, eliminating the need for translation layers like noVNC.
* **Desktop Environment:** A lightweight but modern Linux DE (e.g., XFCE or a heavily optimized KDE Plasma) to keep overhead low while looking familiar to end-users.
* **Deployment Strategy:** * Deploy KasmVNC and the desktop environment via NixOS OCI container management (`virtualisation.oci-containers`) on the NixOS host, OR natively via Nixpkgs if a stable and clean implementation exists.
* **Networking & Security:** An Nginx or Traefik reverse proxy configured on the NixOS host to handle TLS termination, ensuring secure (HTTPS/WSS) access to the KasmVNC web interface.

## 3. Phase 1 Implementation Goals
The coding agent should generate the necessary Nix configuration files (`flake.nix`, `configuration.nix`, etc.) to achieve the following:

1.  **Base System:** Define a minimal NixOS host system capable of running in a cloud environment (e.g., Google Compute Engine) or locally via QEMU for initial testing.
2.  **KasmVNC Integration:** Implement the KasmVNC workspace. Provision the container/service, bind the necessary ports, and ensure the target Desktop Environment is properly initialized upon connection.
3.  **Reverse Proxy Setup:** Configure a reverse proxy to expose the Kasm web client securely on port 443, handling the WebSocket upgrades required by KasmVNC.
4.  **Ephemeral User State:** Ensure the session is stateless or easily resettable, simulating a cloud instance that a user can jump into anonymously.

## 4. Success Criteria
* The system can be built and deployed entirely from the provided Nix configuration.
* A user can navigate to the host's IP/domain in a standard web browser (Chrome/Firefox/Safari) and immediately access a graphical Linux desktop.
* The connection utilizes WSS (Secure WebSockets).
* The desktop experience is visually crisp, supports dynamic resizing to the browser window, and demonstrates low enough latency for comfortable typing and window management.
