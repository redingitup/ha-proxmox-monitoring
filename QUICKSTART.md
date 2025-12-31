QUICKSTART - 5 Minute Setup

Fast version - Just follow these steps.

PREREQUISITES
- Proxmox SSH access (you have root)
- Home Assistant access (you can edit YAML)
- Both on same VLAN
- IP addresses handy

PROXMOX SETUP (2 minutes)

Create SSH Wrapper

Run on Proxmox:
sudo nano /usr/local/bin/ssh-restrict-temps.sh

Paste this:
#!/bin/bash
/usr/local/bin/get-r730xd-temps.sh

Save: Ctrl+O, Enter, Ctrl+X

Then make it executable:
sudo chmod +x /usr/local/bin/ssh-restrict-temps.sh


Create Temperature Reader

Run on Proxmox:
sudo nano /usr/local/bin/get-r730xd-temps.sh

Paste this entire script:
#!/bin/bash
PKG_TEMP=$(sensors 2>/dev/null | grep "Package id 0:" | head -1 | grep -oP '\+\K[0-9]+\.[0-9]+')
CORE0_TEMP=$(sensors 2>/dev/null | grep "Core 0:" | head -1 | grep -oP '\+\K[0-9]+\.[0-9]+')
RAID_TEMP=$(sensors 2>/dev/null | grep -A 5 "i915-pci" | grep "temp1:" | grep -oP '\+\K[0-9]+\.[0-9]+')
CPU_TEMP="${PKG_TEMP}"
if [ -z "$CPU_TEMP" ]; then
    CPU_TEMP="${CORE0_TEMP}"
fi
cat <<EOF
{
  "cpu_temp": $([ -n "$CPU_TEMP" ] && echo "$CPU_TEMP" || echo "null"),
  "raid_temp": $([ -n "$RAID_TEMP" ] && echo "$RAID_TEMP" || echo "null")
}
EOF

Save: Ctrl+O, Enter, Ctrl+X

Then make it executable:
sudo chmod +x /usr/local/bin/get-r730xd-temps.sh


Test It

Run on Proxmox:
/usr/local/bin/get-r730xd-temps.sh

Should output: {"cpu_temp": 43.0, "raid_temp": 44.0}

Done with Proxmox!

HOME ASSISTANT SETUP (3 minutes)

Add to configuration.yaml

Edit your configuration.yaml in Home Assistant

Replace 192.168.1.10 with your Proxmox IP

Add this section:

sensor:
  - platform: command_line
    name: "R730XD CPU Temperature"
    unique_id: "r730xd_cpu_temp"
    command: 'ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh | grep -oP "\"cpu_temp\": \K[0-9.]+"'
    unit_of_measurement: "°C"
    scan_interval: 30
    value_template: "{{ value | float | round(1) }}"
    device_class: temperature
    icon: "mdi:thermometer"

  - platform: command_line
    name: "R730XD RAID Temperature"
    unique_id: "r730xd_raid_temp"
    command: 'ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh | grep -oP "\"raid_temp\": \K[0-9.]+"'
    unit_of_measurement: "°C"
    scan_interval: 30
    value_template: "{{ value | float | round(1) }}"
    device_class: temperature
    icon: "mdi:chip"


Restart Home Assistant

Settings > System > Restart Home Assistant


Verify

Settings > Devices & Services > Entities
Search: "R730XD"
Should see two entities with temperature values

Done!

NEXT STEPS (Optional)

1. Add Alerts: See automations section below
2. Discord Bot: Add Discord notifications
3. Dashboard Card: Add to your dashboard for visibility


TROUBLESHOOTING

Temps show null?

Check Proxmox script output:
/usr/local/bin/get-r730xd-temps.sh

If json output not valid, recheck the script:
sensors | grep "Package|temp1"


SSH connection refused?

Test SSH directly:
ssh -v root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh

May need to set up SSH keys (see DETAILED_SETUP.md)


Entities not appearing in HA?

Check configuration.yaml syntax
Restart HA
Check logs: Settings > System > Logs

See DETAILED_SETUP.md for complete guide with SSH key setup and automations.
