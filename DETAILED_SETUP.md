DETAILED SETUP GUIDE - Complete Reference

Full reference documentation with all details.

ARCHITECTURE

Your Network (VLAN)
- Proxmox R730XD (192.168.1.10)
  - Scripts at /usr/local/bin/
  - get-r730xd-temps.sh (reads sensors)
  - ssh-restrict-temps.sh (ssh wrapper)
- Home Assistant NUC (192.168.1.50)
  - configuration.yaml
  - CPU Temp Sensor
  - RAID Temp Sensor
  - Automations (alerts at 48/55 degrees C)

PHASE 1: SSH KEY SETUP (Recommended)

On Home Assistant (HA NUC)

Generate ED25519 SSH key:
ssh-keygen -t ed25519 -f ~/.ssh/proxmox_r730xd -N ""

Display public key:
cat ~/.ssh/proxmox_r730xd.pub

Copy the output (you will need this)

On Proxmox

Add HA's public key to root authorized_keys:

sudo su -
mkdir -p ~/.ssh
chmod 700 ~/.ssh

Paste your HA public key here:
echo "ssh-ed25519 AAAA..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
exit

Test connection from HA:
ssh -i ~/.ssh/proxmox_r730xd root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh

Should output JSON with temps.

PHASE 2: PROXMOX SCRIPTS

Create get-r730xd-temps.sh

sudo nano /usr/local/bin/get-r730xd-temps.sh

Copy content from get-r730xd-temps.sh file in scripts folder

sudo chmod +x /usr/local/bin/get-r730xd-temps.sh

Create ssh-restrict-temps.sh

sudo nano /usr/local/bin/ssh-restrict-temps.sh

Copy content from ssh-restrict-temps.sh file in scripts folder

sudo chmod +x /usr/local/bin/ssh-restrict-temps.sh

Test

/usr/local/bin/get-r730xd-temps.sh
Output should be: {"cpu_temp": 43.0, "raid_temp": 44.0}

ssh -o ConnectTimeout=5 root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh
Same output via SSH expected

PHASE 3: HOME ASSISTANT CONFIGURATION

Add Sensors to configuration.yaml

In Home Assistant, edit configuration.yaml

Add this section (can use the sensors.yaml file as reference):

sensor:
  - platform: command_line
    name: "R730XD CPU Temperature"
    unique_id: "r730xd_cpu_temp"
    command: 'ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh | grep -oP "\"cpu_temp\": \K[0-9.]+"'
    unit_of_measurement: "°C"
    scan_interval: 30
    value_template: "{{ value | float | round(1) }}"
    device_class: temperature

  - platform: command_line
    name: "R730XD RAID Temperature"
    unique_id: "r730xd_raid_temp"
    command: 'ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh | grep -oP "\"raid_temp\": \K[0-9.]+"'
    unit_of_measurement: "°C"
    scan_interval: 30
    value_template: "{{ value | float | round(1) }}"
    device_class: temperature

Add Automations

Create automations.yaml (or add to existing)

Copy content from automations.yaml file in ha-config folder

Restart Home Assistant

Settings > System > Restart

PHASE 4: VERIFICATION

On Proxmox:

ls -la /usr/local/bin/*temps*.sh

Should show both scripts exist and are executable

/usr/local/bin/get-r730xd-temps.sh

Should show: {"cpu_temp": 43.0, "raid_temp": 44.0}

sensors | grep "Package id 0:|i915-pci" -A 3

On Home Assistant:

Settings > Devices & Services > Entities
Search: "R730XD"
Should see:
- sensor.r730xd_cpu_temperature (43.0 degrees C)
- sensor.r730xd_raid_temperature (44.0 degrees C)

TROUBLESHOOTING

Temps show null in HA

Check 1: Proxmox script output
/usr/local/bin/get-r730xd-temps.sh
Should show: {"cpu_temp": 43.0, "raid_temp": 44.0}

Check 2: SSH connectivity
ssh root@192.168.1.10 /usr/local/bin/get-r730xd-temps.sh
Same JSON output expected

Check 3: Grep parsing
/usr/local/bin/get-r730xd-temps.sh | grep -oP '"cpu_temp": \K[0-9.]+'
Should output: 43.0

SSH Key Issues

Permission denied (publickey)?

On Proxmox:
cat ~/.ssh/authorized_keys
Should show your HA key
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

From HA:
ssh -i ~/.ssh/proxmox_r730xd root@192.168.1.10 whoami
Should return: root

HA Configuration Syntax Error

Settings > Developer Tools > YAML
Click "Check Configuration"
Fix any errors shown

OPTIONAL: Discord Integration

Setup Discord Bot

1. Create Discord bot (Discord Developer Portal)
2. Get bot token
3. In HA, add notify integration
4. Update automations to use notify.discord_YOUR_CHANNEL

METRICS

After setup, you will be monitoring:
- CPU Temperature: CPU package temp (most reliable)
- RAID Controller Temp: i915-pci adapter temp1
- Update Frequency: Every 30 seconds
- Latency: 1-2 seconds per update
- Security: ED25519 SSH keys, no passwords

FILES IN THIS REPO

ha-proxmox-monitoring/
├── README.md (Overview)
├── QUICKSTART.md (5-min setup)
├── DETAILED_SETUP.md (This file)
├── .gitignore (Secrets protection)
├── scripts/
│   ├── get-r730xd-temps.sh (Temp reader)
│   └── ssh-restrict-temps.sh (SSH wrapper)
└── ha-config/
    ├── sensors.yaml (Temperature sensors)
    └── automations.yaml (Alerts at 48/55 degrees C)

Done! You now have complete R730XD monitoring.
