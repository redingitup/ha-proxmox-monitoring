#!/bin/bash
# get-r730xd-temps.sh - Read R730XD CPU + RAID Controller temps
# Location: /usr/local/bin/get-r730xd-temps.sh
# Created: 2025-12-31
# Purpose: Output temperature data as JSON for HA command_line sensor

# Get Package temp (CPU package temperature)
PKG_TEMP=$(sensors 2>/dev/null | grep "Package id 0:" | head -1 | grep -oP '\+\K[0-9]+\.[0-9]+')

# Get Core 0 temp (first CPU core - fallback)
CORE0_TEMP=$(sensors 2>/dev/null | grep "Core 0:" | head -1 | grep -oP '\+\K[0-9]+\.[0-9]+')

# Get RAID Controller temp (i915-pci adapter, temp1 line)
RAID_TEMP=$(sensors 2>/dev/null | grep -A 5 "i915-pci" | grep "temp1:" | grep -oP '\+\K[0-9]+\.[0-9]+')

# Use Package temp as CPU temp (most reliable)
CPU_TEMP="${PKG_TEMP}"

# Fallback to Core 0 if Package not available
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="${CORE0_TEMP}"
fi

# Output as JSON
cat <<EOF
{
  "cpu_temp": $([ -n "$CPU_TEMP" ] && echo "$CPU_TEMP" || echo "null"),
  "raid_temp": $([ -n "$RAID_TEMP" ] && echo "$RAID_TEMP" || echo "null")
}
EOF
