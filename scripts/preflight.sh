#!/usr/bin/env bash
set -u
# Read-only checks. No system settings are changed.
printf '\n=== Tunnel Pack preflight (read-only) ===\n'
printf 'Time: '; date -Is 2>/dev/null || date
printf '\n-- OS --\n'
if [ -r /etc/os-release ]; then
  . /etc/os-release
  printf 'Name: %s\nVersion: %s\nID: %s\n' "${PRETTY_NAME:-unknown}" "${VERSION_ID:-unknown}" "${ID:-unknown}"
else
  echo 'OS release information unavailable'
fi
printf '\n-- Kernel / architecture --\n'
uname -srmo 2>/dev/null || true
printf '\n-- Uptime / load --\n'
uptime 2>/dev/null || true
printf '\n-- Memory --\n'
if command -v free >/dev/null 2>&1; then free -h; else echo 'free command unavailable'; fi
printf '\n-- Disk --\n'
df -h / 2>/dev/null || true
printf '\n-- Network tools --\n'
for bin in ip ping curl ss ethtool; do
  if command -v "$bin" >/dev/null 2>&1; then printf '%-10s %s\n' "$bin" "$(command -v "$bin")"; else printf '%-10s not found\n' "$bin"; fi
done
printf '\n-- TCP congestion control (read-only) --\n'
if [ -r /proc/sys/net/ipv4/tcp_congestion_control ]; then
  printf 'Current: '; cat /proc/sys/net/ipv4/tcp_congestion_control
  printf 'Available: '; cat /proc/sys/net/ipv4/tcp_available_congestion_control 2>/dev/null || true
else
  echo 'Not available on this system'
fi
printf '\n-- Default route --\n'
if command -v ip >/dev/null 2>&1; then ip route show default 2>/dev/null || true; else echo 'ip command unavailable'; fi
printf '\nCompleted. No system settings were changed.\n'
