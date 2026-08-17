# Ansible Configuration for CampusNetwork-labo

This directory contains Ansible playbooks and inventories for configuring the VyOS routers deployed by the PowerShell scripts in `../src/`.

## Prerequisites

1. Install Ansible on WSL2 or a Linux control node:
   ```bash
   sudo apt update
   sudo apt install -y ansible
   ```

2. Install the VyOS collection:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

3. Ensure VyOS VMs are reachable via SSH on the management network (192.168.255.0/24).
   The management NIC (`MGMT-NIC01`) is connected to the Hyper-V Default Switch.

## Manual VyOS Setup (Required Before Ansible)

The VyOS ISO does not support unattended configuration injection in this environment.
Therefore, the following minimum setup must be performed manually via `vmconnect.exe` for each VyOS VM:

1. Boot the VM from the VyOS ISO and log in as `vyos` / `vyos`.
2. Install VyOS to the virtual hard disk:
   ```bash
   install image
   ```
   Follow the prompts (use default values, set password for `vyos`).
3. Reboot and remove the ISO (or change boot order to HDD).
4. Log in to the installed system.
5. Configure the management interface and SSH:
   ```bash
   configure
   set interfaces ethernet eth3 description 'MGMT-NIC01'
   set interfaces ethernet eth3 address '192.168.255.XX/24'
   set service ssh port '22'
   commit
   save
   exit
   ```
   Replace `192.168.255.XX` with the IP address defined in `inventory/hosts.ini`.
6. Verify SSH connectivity from the Hyper-V host or WSL2:
   ```bash
   ssh vyos@192.168.255.11
   ```

## Directory Structure

```
ansible/
├── inventory/
│   └── hosts.ini          # Ansible inventory with management IPs
├── group_vars/
│   └── vyos.yml           # Common variables for all VyOS hosts
├── host_vars/
│   ├── ExNetworkOS01-labo.yml
│   ├── ExNetworkOS02-labo.yml
│   ├── SiteANetworkOS01-labo.yml
│   ├── SiteANetworkOS02-labo.yml
│   └── SiteBNetworkOS01-labo.yml
├── playbooks/
│   └── configure_vyos.yml # Main playbook for interface and OSPF config
├── requirements.yml       # Ansible collection dependencies
└── README.md              # This file
```

## Usage

Run the playbook against all VyOS hosts:

```bash
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/configure_vyos.yml
```

Run against a specific host or group:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/configure_vyos.yml --limit ExNetworkOS01-labo
```

## Notes

- Default credentials are `vyos` / `vyos`. Change them after deployment.
- The playbook configures interfaces and OSPF based on `host_vars/`.
- Static routes can be added in `host_vars/` under `static_routes`.
