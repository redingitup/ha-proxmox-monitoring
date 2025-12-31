# Home Assistant Proxmox Monitoring

![Version](https://img.shields.io/badge/version-1.0.0-brightgreen)
![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2023.12%2B-blue)
![Proxmox](https://img.shields.io/badge/Proxmox-7.0%2B-purple)

Monitor and control your **Proxmox VE** environment directly from **Home Assistant** with ready-to-use automations, alerts, and health checks.

---

## ✨ Features

- 🚀 **VM State Monitoring** - Get notifications when VMs start/stop
- 📊 **Resource Alerts** - CPU, Memory, and Disk usage monitoring
- 🏥 **Health Checks** - Daily Proxmox system health reports
- 🔔 **Smart Notifications** - Customizable thresholds and alerts
- 📈 **Dashboard Integration** - Easy visualization in Home Assistant
- ⚡ **Quick Setup** - Working automations included

---

## 🚀 Quick Start (5 minutes)

### Prerequisites

- ✅ Home Assistant 2023.12 or newer
- ✅ Proxmox VE 7.0+
- ✅ HACS installed in Home Assistant
- ✅ Admin access to both systems

### Step 1: Install ProxmoxVE Integration

1. Go to **HACS** > **Integrations** > **⋮** > **Custom repositories**
2. Add repository: `https://github.com/dougiteixeira/proxmoxve`
3. Search for "Proxmox VE" and download
4. **Restart Home Assistant**

### Step 2: Create Proxmox User

In **Proxmox Web UI**:

1. **Datacenter** > **Permissions** > **Users** > **Add**
   - **Username**: `homeassistant`
   - **Realm**: `Proxmox VE Authentication`
   - **Password**: Generate strong password

2. **Datacenter** > **Permissions** > **Add** (new row)
   - **User**: `homeassistant@pve`
   - **Role**: `PVEAuditor` (monitoring only)
   - **Path**: `/`
   - ☑️ **Propagate**

### Step 3: Configure Home Assistant

1. **Settings** > **Devices & Services** > **+ Create Automation**
2. Search for **"Proxmox VE"** > Select integration
3. Enter:
   - **Host**: Your Proxmox IP (e.g., `192.168.1.100`)
   - **Port**: `8006` (default)
   - **Username**: `homeassistant@pve`
   - **Password**: Your password
4. Click **Submit**

### Step 4: Enable YAML Automations

Edit `/config/configuration.yaml`:

```yaml
automation: !include automations.yaml
script: !include scripts.yaml
group: !include groups.yaml
```

**Restart Home Assistant** (Settings > System > Restart Home Assistant)

### Step 5: Copy Files to Home Assistant

Copy these files from this repository to `/config/`:

```
/config/
├── automations.yaml
├── scripts.yaml
├── groups.yaml
└── customize.yaml
```

✅ **Done!** Your automations will appear in Home Assistant.

---

## 📋 Available Automations

| Name | Trigger | Action | Notes |
|------|---------|--------|-------|
| **VM Started** | VM binary sensor → on | Send notification | Every VM start |
| **VM Stopped** | VM binary sensor → off | Send notification | Every VM stop |
| **High CPU Alert** | CPU > 80% for 5 min | Send notification | Configurable threshold |
| **High Memory Alert** | Memory > 85% for 5 min | Send notification | Configurable threshold |
| **High Disk Alert** | Disk > 90% for 10 min | Send notification | Configurable threshold |
| **Node Offline Alert** | Node status → off | Send critical alert | Immediate |
| **Node Online Alert** | Node status → on | Send notification | When back online |
| **Daily Health Check** | Time: 09:00 (weekdays) | Send report | CPU/Memory/Disk summary |

---

## 🔧 Configuration

### Entity IDs

Entity IDs vary based on your Proxmox setup. To find yours:

1. **Settings** > **Developer Tools** > **States**
2. Search for "proxmox"
3. Copy entity IDs into automations.yaml

**Common patterns:**
```
sensor.proxmox_cpu              # CPU usage
sensor.proxmox_memory           # Memory usage
sensor.proxmox_disk             # Disk usage
binary_sensor.proxmox_node_status  # Node online/offline
binary_sensor.proxmox_{node}_{vm}_running  # VM state
```

### Customize Thresholds

Edit `automations.yaml` to change alert levels:

```yaml
- id: proxmox_high_cpu_alert
  trigger:
    above: 80  # ← Change this threshold
    for:
      minutes: 5  # ← Change duration before alert
```

### Add Notifications

Default automations use generic `notify.notify`. Add your specific service:

```yaml
action:
  service: notify.mobile_app_iphone  # Or your service
  data:
    title: "Alert"
    message: "..."
```

---

## 🐛 Troubleshooting

### Integration won't connect
```
❌ Error: "Connection refused"

✅ Solutions:
1. Check Proxmox IP and port (default: 8006)
2. Verify user `homeassistant@pve` exists
3. Check PVEAuditor role is assigned
4. Ensure firewall allows port 8006
```

### Automations don't appear
```
❌ Error: Automations not visible in Home Assistant

✅ Solutions:
1. Verify configuration.yaml has: automation: !include automations.yaml
2. Restart Home Assistant (Settings > System > Restart)
3. Check automations.yaml syntax:
   python3 -c "import yaml; yaml.safe_load(open('/config/automations.yaml'))"
```

### Sensors not updating
```
❌ Problem: Sensors show old values

✅ Solutions:
1. Check Proxmox user has read permissions
2. Look at Home Assistant logs (Settings > System > Logs)
3. Verify integration is properly configured
4. Wait 1-2 minutes for first update
```

### False/too many alerts
```
❌ Problem: Too many alert notifications

✅ Solutions:
1. Increase threshold in automations.yaml
2. Increase "for" duration (e.g., from 5 to 10 minutes)
3. Add condition to skip alerts outside business hours
```

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more help.

---

## 📚 Documentation

- **[SETUP.md](docs/SETUP.md)** - Detailed installation guide
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and fixes
- **[AUTOMATIONS.md](docs/AUTOMATIONS.md)** - Detailed automation reference

---

## 🔐 Security Notes

- ✅ Use **PVEAuditor** role (read-only) for monitoring only
- ✅ Generate a **strong password** for the `homeassistant@pve` user
- ✅ Use **HTTPS** for Proxmox connection
- ✅ Never share Proxmox credentials
- ✅ Keep Home Assistant and Proxmox updated

---

## 📦 File Structure

```
ha-proxmox-monitoring/
├── README.md                    # This file
├── automations.yaml             # All automations
├── scripts.yaml                 # Helper scripts
├── groups.yaml                  # Entity groups
├── customize.yaml               # Entity customization
├── configuration.yaml           # Config template
└── docs/
    ├── SETUP.md                 # Installation guide
    ├── TROUBLESHOOTING.md       # Troubleshooting
    └── AUTOMATIONS.md           # Automation docs
```

---

## 🤝 Contributing

Found a bug? Want to add an automation? 

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-automation`)
3. Commit changes (`git commit -m 'Add my automation'`)
4. Push to branch (`git push origin feature/my-automation`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- [ProxmoxVE Integration](https://github.com/dougiteixeira/proxmoxve) - Core integration
- [Home Assistant Community](https://community.home-assistant.io/)
- [Proxmox Community](https://proxmox.com/)

---

## 📞 Support

- 💬 **Questions?** Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- 🐛 **Bug?** Open an [Issue](../../issues)
- 💡 **Feature request?** Start a [Discussion](../../discussions)

---

## ⭐ Show Your Support

If this helped you, please give it a ⭐ on GitHub!

---

**Last Updated**: December 31, 2025  
**Version**: 1.0.0
