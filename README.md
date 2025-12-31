Home Assistant Proxmox R730XD Temperature Monitoring

Secure SSH-based real-time temperature monitoring from Dell R730XD running Proxmox to Home Assistant.

FEATURES
- Read CPU temperature from coretemp
- Read RAID controller temperature from i915-pci sensor
- Display in Home Assistant dashboard with 30-second refresh
- Alert via Discord/mobile at 48 and 55 degrees C
- Uses SSH key authentication (secure, no passwords)
- Same VLAN only (internal network, no exposed ports)

SETUP TIME: 5-10 minutes total

REQUIREMENTS
- Proxmox host on same VLAN as Home Assistant
- SSH access to Proxmox (default enabled)
- Home Assistant running (any setup)
- 15 minutes of setup time

DOCUMENTATION
- QUICKSTART.md - Fast 5-minute setup
- DETAILED_SETUP.md - Full reference guide with troubleshooting

QUICK STATS
- Proxmox Side: 2 simple bash scripts (120 lines total)
- HA Side: YAML config + automations
- Security: ED25519 SSH keys, no root password exposure
- Polling: Every 30 seconds (configurable)

LICENSE
MIT - Use freely!

SUPPORT
Check DETAILED_SETUP.md for troubleshooting section.
