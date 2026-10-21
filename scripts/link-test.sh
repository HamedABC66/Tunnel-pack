#!/usr/bin/env bash
set -u

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  echo "Usage: bash scripts/link-test.sh <server-ip-or-hostname> [tcp-port]"
  echo "Example: bash scripts/link-test.sh 203.0.113.10 443"
  exit 2
fi

host="$1"
port="${2:-443}"

if ! [[ "$host" =~ ^[a-zA-Z0-9.-]+$ ]]; then
  echo "Error: host must be an IP address or hostname."
  exit 2
fi
if ! [[ "$port" =~ ^[0-9]{1,5}$ ]] || (( 10#$port < 1 || 10#$port > 65535 )); then
  echo "Error: TCP port must be between 1 and 65535."
  exit 2
fi

printf "=== Tunnel Pack link test ===\nTarget: %s\nTCP port: %s\n\n" "$host" "$port"

if command -v ping >/dev/null 2>&1; then
  echo "-- ICMP ping (4 packets) --"
  ping -c 4 -W 2 "$host" || echo "Ping failed or ICMP may be filtered."
else
  echo "ping command unavailable; skipping ICMP test."
fi

printf "\n-- TCP connection test --\n"
if command -v timeout >/dev/null 2>&1; then
  if timeout 4 bash -c ": >/dev/tcp/\"\$1\"/\"\$2\"" _ "$host" "$port" 2>/dev/null; then
    echo "TCP connection succeeded to $host:$port"
  else
    echo "TCP connection failed to $host:$port (service/firewall/routing may block it)."
  fi
else
  echo "timeout command unavailable; skipping TCP test safely."
fi

echo "\nTest complete. No network settings were changed."
