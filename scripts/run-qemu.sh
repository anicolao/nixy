#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<HELP
Usage:
  $(basename "$0") /path/to/image.raw.tar.gz

Environment:
  QEMU_MEMORY    Guest memory in MB. Default: 2048
  QEMU_SSH_PORT  Host TCP port forwarded to guest port 22. Default: 2222
  QEMU_HTTP_PORT Host TCP port forwarded to guest port 80. Default: 8080
  QEMU_KASM_PORT Host TCP port forwarded to guest port 6901. Default: 6901
  QEMU_ARCH      Guest architecture. Default: $(uname -m)

This script:
  1. Extracts disk.raw from the GCE tarball into a temporary directory
  2. Launches the image with qemu-system-<arch>
HELP
}

if [[ $# -ne 1 || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 1
fi

tarball="$1"
memory="${QEMU_MEMORY:-2048}"
ssh_port="${QEMU_SSH_PORT:-2222}"
http_port="${QEMU_HTTP_PORT:-8080}"
kasm_port="${QEMU_KASM_PORT:-6901}"
arch="${QEMU_ARCH:-$(uname -m)}"

if [[ ! -f "$tarball" ]]; then
  echo "Tarball does not exist: $tarball" >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap "rm -rf $workdir" EXIT

echo "Extracting $tarball into $workdir..."
tar -xzf "$tarball" -C "$workdir"

disk_image="$workdir/disk.raw"

if [[ ! -f "$disk_image" ]]; then
  # Check if it was renamed to something else or nested
  disk_image=$(find "$workdir" -name "*.raw" | head -n 1)
  if [[ -z "$disk_image" ]]; then
    echo "Expected disk.raw (or any .raw) was not found in the tarball." >&2
    ls -R "$workdir"
    exit 1
  fi
fi

echo "Starting QEMU ($arch)..."
echo "SSH: localhost:$ssh_port -> Guest:22"
echo "HTTP: localhost:$http_port -> Guest:80"
echo "KasmVNC: localhost:$kasm_port -> Guest:6901"

# Basic QEMU invocation
exec qemu-system-$arch \
  -m $memory \
  -drive file="$disk_image",format=raw,if=virtio \
  -netdev user,id=net0,hostfwd=tcp::$ssh_port-:22,hostfwd=tcp::$http_port-:80,hostfwd=tcp::$kasm_port-:6901 \
  -device virtio-net-pci,netdev=net0 \
  -nographic \
  -serial mon:stdio
