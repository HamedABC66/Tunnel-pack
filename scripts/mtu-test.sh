#!/usr/bin/env bash
set -u

if [ "$#" -ne 1 ]; then
  echo "Usage: bash scripts/mtu-test.sh <server-ip-or-hostname>"
  exit 2
fi

host="$1"
if ! [[ "$host" =~ ^[a-zA-Z0-9.:-]+$ ]]; then
  echo "Error: enter an IP address or hostname only."
  exit 2
fi

if ! command -v ping >/dev/null 2>&1; then
  echo "Error: ping is not installed. No changes made."
  exit 1
fi

if ! ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
  echo "Warning: ordinary ping failed. ICMP may be blocked; MTU results may be unavailable."
fi

if [[ "$host" == *:* ]]; then
  family=(-6)
else
  family=(-4)
fi

printf "=== Tunnel Pack MTU probe ===\nTarget: %s\n" "$host"
printf "Testing IPv4/IPv6 packet payload sizes with DF where supported.\n"
printf "This is a diagnostic only; no interface MTU is changed.\n\n"

for size in 1200 1250 1300 1350 1400 1450 1472; do
  printf "Payload %s bytes: " "$size"
  if ping "${family[@]}" -c 1 -W 2 -M do -s "$size" "$host" >/dev/null 2>&1; then
    echo "reply received"
  else
    echo "no reply / possibly filtered / too large"
  fi
done

echo "\nImportant: failed probes do not prove the packet is too large; ICMP filtering and host settings can affect results."
echo "Finished. No network settings were changed."
