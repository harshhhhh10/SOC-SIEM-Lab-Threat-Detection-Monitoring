# 🛡️ Project 1: SIEM Log Monitoring & Threat Detection Lab

## 📝 Overview
This project demonstrates a complete, real-world SOC workflow. I built a Splunk SIEM home lab from scratch to ingest Windows Event and Sysmon logs, simulated real-world attacks (RDP Brute Force & Malicious PowerShell), and developed detection logic (alerts & dashboards) to investigate them.

This lab simulates the day-to-day monitoring, triage, and detection engineering tasks required in a Security Operations Center, built entirely from scratch using VirtualBox.

---

## 🧠 Skills Gained
* **SIEM Administration:** Installing, configuring, and managing Splunk Enterprise and Universal Forwarder.
* **Log Parsing & Ingestion:** Configuring Windows Event Logs and manual Sysmon log ingestion via `inputs.conf`.
* **Detection Engineering:** Writing SPL (Search Processing Language) queries to identify malicious behavior.
* **Alert Creation:** Configuring threshold-based alerts to automate threat notification.
* **Incident Triage:** Analyzing logs to identify attacker IPs, targeted accounts, and malicious command lines.
* **MITRE ATT&CK Mapping:** T1110 (Brute Force) & T1059.001 (Command and Scripting Interpreter: PowerShell).

---

## 🛠️ Lab Architecture
```text
┌────────────────┐               ┌───────────────────────────┐
│ Attacker       │               │ Victim Machine            │
│ Kali Linux     │ ────────────> │ Windows 10 Enterprise     │
│ (10.0.2.X)     │  RDP Brute    │ Sysmon + Win Event Logs   │
└────────────────┘  PowerShell   └───────────────────────────┘
                                               │
                                               │ Log Forwarding
                                               │ (Port 9997)
                                               ▼
                                 ┌───────────────────────────┐
                                 │ SIEM Server               │
                                 │ Splunk Enterprise (Ubuntu)│
                                 │ (10.0.2.X)                │
                                 └───────────────────────────┘
```
* **SIEM Server:** Splunk Enterprise (Ubuntu Server)
* **Log Forwarder:** Splunk Universal Forwarder (Windows 10)
* **Deep Endpoint Logging:** Sysmon (SwiftOnSecurity Configuration)
* **Attacker Machine:** Kali Linux
* **Virtualization:** Oracle VirtualBox (NAT Network: 10.0.2.0/24)

---

## 🚀 Setup & Configuration Steps

### 1. Network Configuration
Configured a VirtualBox NAT Network (10.0.2.0/24) allowing all VMs to communicate with each other and the internet. Disabled the Windows Firewall on the victim machine to ensure lab attacks and log forwarding were not blocked.

### 2. SIEM Deployment (Ubuntu)
* Downloaded and installed Splunk Enterprise via `.deb` package.
* Enabled Splunk to start on boot.
* Configured Splunk to receive data by enabling receiving port `9997`.

### 3. Endpoint Configuration (Windows 10)
* Installed Sysmon with the SwiftOnSecurity `sysmonconfig.xml` for high-fidelity process and network logging.
* Enabled Remote Desktop (RDP) to create an attack surface for brute-forcing.
* Installed the Splunk Universal Forwarder, pointing to the Ubuntu Server IP on port `9997`.

> ⚠️ **Crucial Troubleshooting Step:** The Universal Forwarder UI did not automatically capture Sysmon logs. I manually created an `inputs.conf` file at `C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf` with the following stanza to force ingestion:
> ```ini
> [WinEventLog://Microsoft-Windows-Sysmon/Operational]
> disabled = 0
> index = main
> ```

---

## 🎯 Attack Simulations & Detection Logic

### Attack 1: RDP Brute Force (T1110)
* **Simulation:** Used Hydra on the Kali machine to perform a dictionary attack against the RDP service on the Windows 10 VM.
* **Detection Logic:** Searched for Windows Event ID `4625` (Failed Logon).
* **SPL Query:**
```splunk
index=main EventCode=4625


| eval Attacker_IP = coalesce(SourceNetworkAddress, IpAddress, Source_Network_Address)
| stats count as "Failed Logins" by Attacker_IP
| sort -"Failed Logins"
```
*(Note: Used the `coalesce` function because Windows logs are inconsistent with IP field names across different versions).*

* **Action Taken:** Created a Scheduled Alert to trigger if >5 failed logins occur from a single IP within 5 minutes.

### Attack 2: Malicious PowerShell Execution (T1059.001)
* **Simulation:** Executed a hidden PowerShell command simulating a fileless malware downloader (`-Exec Bypass -WindowStyle Hidden`).
* **Detection Logic:** Searched for Sysmon Event ID `1` (Process Create) with suspicious command-line arguments.
* **SPL Query:**
```splunk
index=main EventCode=1 (_raw="*Bypass*" OR _raw="*Hidden*" OR _raw="*Invoke-WebRequest*")


| stats count as "Suspicious Events" by ComputerName, _raw
| rename ComputerName as "Victim PC", _raw as "Command/Details"
```
*(Note: Searched the `_raw` field directly because Splunk sometimes fails to automatically parse the `CommandLine` field from Sysmon logs depending on the TA).*

---

## 📸 Project Evidence

### SOC Dashboard Overview
Real-time monitoring dashboard showing brute-force trends, top attacker IPs, and suspicious PowerShell execution.
<img width="1920" height="1032" alt="SOC_Dashboard_Attack_Monitoring" src="https://github.com/user-attachments/assets/3d8fd0a6-4948-4082-bac7-978b06252f89" />

### Alert Configuration
Automated Brute Force detection alert configured to trigger on >5 failed logins from a single IP.
<img width="1920" height="1032" alt="Brute_Force_Alert_Configuration" src="https://github.com/user-attachments/assets/bd1fa45e-0b20-4298-b954-825ce778d920" />

### Raw Log Evidence: Brute Force
Windows Security Event ID 4625 (Failed Logon) showing the attacker's IP and bad password attempt.
<img width="1920" height="1032" alt="Failed_Logon_Event_4625" src="https://github.com/user-attachments/assets/4595afe6-1611-4a22-8689-a2d72e9f7f37" />

### Raw Log Evidence: Malicious PowerShell
Sysmon Event ID 1 capturing the hidden PowerShell execution with the -Exec Bypass flag.
<img width="1920" height="1032" alt="PowerShell_Raw_Log_Evidence" src="https://github.com/user-attachments/assets/a9c0c5bc-2483-4fc6-a5da-68ec61e780c3" />

---

## 💡 Key Learnings & Real-World Troubleshooting
* **Field Name Inconsistencies:** Windows security logs frequently change field names (e.g., `IpAddress` vs `SourceNetworkAddress`). Using Splunk's `eval` and `coalesce` functions is essential for building reliable, bulletproof searches that won't break in production.
* **Sysmon Forwarding Gaps:** The Splunk Universal Forwarder does not always automatically check the Sysmon log channel upon installation. Manually adding the `Microsoft-Windows-Sysmon/Operational` stanza to `inputs.conf` is a common and necessary fix.
* **Parsing Limitations:** Out-of-the-box Splunk parsing sometimes misses specific fields like `CommandLine` in Sysmon logs. Searching the `_raw` data using wildcards is a highly effective fallback method for catching malicious indicators.

---

## 🔭 Future Improvements
* Integrate an Active Directory lab to detect credential dumping (Mimikatz) and Kerberoasting.
* Implement Sigma rules to standardize detection logic and convert them to SPL.
* Build a Python enrichment script (SOAR Lite) to automatically query VirusTotal/AbuseIPDB for attacker IP reputations when an alert fires.
