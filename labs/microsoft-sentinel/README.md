# Microsoft Sentinel Detection Lab

> Build a free, end-to-end Microsoft Sentinel detection environment in your homelab. Ingest real telemetry from Defender for Endpoint and Entra ID, write KQL detections mapped to MITRE ATT&CK, and walk away with something you can actually demo in an interview.

**Part of [Homelabs for Hackers](https://github.com/thelocalfrogman/Homelabs-For-Hackers)**.Tthe practical, get-your-hands-dirty series for people who want to learn cyber by doing it, not by watching it.

---

## Why this lab exists

Most "learn SIEM" content falls into two camps. Camp one is vendor marketing dressed up as a tutorial; you click through a wizard, see a green tick, and learn nothing. Camp two is academic, pages of theory about correlation rules with no actual rules to write. This lab is neither.

By the end of it you will have:

- A live Microsoft Sentinel workspace ingesting telemetry from a real Windows endpoint and a real identity provider
- Three working detections you authored yourself, each mapped to a MITRE ATT&CK technique
- A Sentinel workbook visualising those detections by tactic
- A repeatable test harness so you can prove the detections actually fire when you simulate the attacker behaviour
- Screenshots, KQL, and a short writeup you can drop straight onto your GitHub

The whole thing should take a focused afternoon. The cost is zero if you stay inside the free tiers, which this guide is built around.

---

## Who this is for

You are comfortable with a terminal, you know what a Windows event log is, and you have heard of MITRE ATT&CK but maybe never actually written a detection from one. You might be a student getting ready for a SOC role, a sysadmin pivoting into security, or an analyst who has only ever used Splunk or Elastic and wants to add Sentinel to your toolbox without paying for a course.

You do **not** need an existing Azure tenant, an enterprise M365 subscription, or any prior KQL experience. Everything below assumes you are starting from scratch.

---

## What you will build

```
                        ┌──────────────────────────────┐
                        │   Microsoft Sentinel         │
                        │   (Log Analytics workspace)  │
                        └──────────────┬───────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                      │                      │
        ┌───────┴───────┐     ┌────────┴────────┐    ┌────────┴────────┐
        │ Defender for  │     │   Entra ID      │    │  Azure Activity │
        │   Endpoint    │     │  Sign-in Logs   │    │      Logs       │
        └───────┬───────┘     └─────────────────┘    └─────────────────┘
                │
        ┌───────┴───────┐
        │  Windows 11   │
        │  test VM      │
        │  (onboarded)  │
        └───────────────┘
```

Three data sources, one workspace, one analyst (you). Once you have telemetry flowing you write detections against it. The detections in this lab are deliberately chosen to span the full ATT&CK kill chain: one for execution, one for initial access via valid accounts, one for command and control.

---

## Prerequisites

Hardware and accounts you need before you start:

- A machine that can run a Windows 11 VM (16GB RAM, ~80GB free disk is comfortable)
- A virtualisation host of your choice (Proxmox, VMware, Hyper-V, or VirtualBox all work)
- A throwaway email address for the Microsoft 365 Developer tenant (do not use your personal Microsoft account)
- A working credit card for the Azure free trial (you will not be charged if you stay inside the free tier limits described in this guide, but Microsoft requires one on file)

You do **not** need:

- An existing Azure subscription
- A paid M365 licence
- A domain name
- Windows Server

---

## The cost question, answered honestly

Sentinel pricing is scary if you do not know where the cliffs are. Here is what you need to know:

- **Microsoft 365 Developer Program** gives you a free E5 tenant with 25 user licences, including Defender for Endpoint Plan 2 and Entra ID P2. The tenant lasts 90 days but renews automatically as long as you log in and use it.
- **Azure free trial** gives you A$300 of credit for 30 days, plus a permanent free tier on selected services.
- **Sentinel** itself bills on data ingestion. The free tier is **10 GB/day for the first 31 days** in any new workspace. After 31 days, you pay per GB ingested. For a single Windows VM and a couple of test users, you will be looking at well under 100 MB/day, which is functionally free even after the trial ends — but **delete the workspace when you are done with the lab** if you want absolute certainty.

> ⚠️ **The two ways to get burned:** (1) leaving Defender for Endpoint enabled across multiple noisy machines, and (2) ingesting Azure Activity logs from a busy subscription. Neither applies to a clean lab tenant. Keep the lab small and you stay free.

---

## Phase 1 - Tenant and workspace setup (~45 min)

### 1.1 Create the M365 dev tenant

Sign up at [developer.microsoft.com/microsoft-365/dev-program](https://developer.microsoft.com/microsoft-365/dev-program). Choose the **Instant sandbox** option — you get a tenant in about two minutes with 25 prepopulated test users and an `*.onmicrosoft.com` domain.

Save the admin credentials somewhere sensible. You will use them constantly.

### 1.2 Activate the Azure trial against the same tenant

Go to [azure.microsoft.com/free](https://azure.microsoft.com/free) and sign in with your new dev tenant admin account. Activate the free trial. This gives you a subscription you can deploy resources into.

> 💡 **Why same tenant:** Sentinel needs to live in an Azure subscription, but it also needs to be able to read Defender and Entra signals from the M365 side. Putting both under one tenant avoids a world of cross-tenant pain.

### 1.3 Create the Log Analytics workspace

In the Azure portal, search for **Log Analytics workspaces** and create a new one. Pick the Australia East region (lower latency from Geelong, and pricing is identical). Name it something like `sentinel-lab-workspace`.

### 1.4 Enable Sentinel on the workspace

Search for **Microsoft Sentinel** in the portal, click **Create**, and select the workspace you just made. This costs nothing to enable (you only pay for ingested data).

---

## Phase 2 - Connect data sources (~60 min)

### 2.1 Onboard the Windows 11 VM to Defender for Endpoint

Spin up a Windows 11 VM on your hypervisor of choice. After install:

1. In the Azure portal, go to **Microsoft Defender XDR** → **Settings** → **Endpoints** → **Onboarding**
2. Select **Windows 10 and 11** and **Local Script** as the deployment method
3. Download the onboarding package, copy it to your VM, and run it as administrator
4. Verify enrolment with the test detection script Microsoft provides on the same page

Within 10 minutes the VM should appear in the Defender device inventory.

### 2.2 Connect Defender to Sentinel

In Sentinel, go to **Content hub**, search for **Microsoft Defender XDR**, and install the solution. Then go to **Data connectors**, find **Microsoft Defender XDR**, click **Open connector page**, and connect it. Enable the `DeviceProcessEvents`, `DeviceNetworkEvents`, `DeviceFileEvents`, and `DeviceLogonEvents` tables — these are the four you will write detections against.

### 2.3 Connect Entra ID sign-in logs

Same process — Content hub, install **Microsoft Entra ID** solution, then in Data connectors enable both **Sign-in logs** and **Audit logs**.

### 2.4 Verify telemetry is flowing

Go to **Logs** in Sentinel and run:

```kql
DeviceProcessEvents
| where TimeGenerated > ago(1h)
| take 10
```

If you see rows, you are in business. If you do not, wait another 15 minutes — Defender takes a while to start streaming on a freshly onboarded device. Trigger some activity on the VM (open a few apps, run `whoami`, browse a website) to give it something to send.

---

## Phase 3 - Author the detections (~90 min)

Three detections, each mapped to a MITRE ATT&CK technique. The point is not to write the world's best detection — the point is to understand the *shape* of detection authoring well enough to talk about it intelligently and improve it later.

### Detection 1 - T1059.001: Suspicious PowerShell with encoded command

PowerShell launched with `-EncodedCommand` is a classic obfuscation technique used by everything from commodity malware to red teams. Legitimate use exists but is rare on a workstation.

```kql
DeviceProcessEvents
| where FileName =~ "powershell.exe" or FileName =~ "pwsh.exe"
| where ProcessCommandLine has_any ("-enc", "-EncodedCommand", "-e ")
| where ProcessCommandLine !has "Get-WinEvent"  // tune out a noisy admin script
| project TimeGenerated, DeviceName, AccountName, ProcessCommandLine, InitiatingProcessFileName
```

Save this as an **Analytics rule** (Sentinel → Analytics → Create → Scheduled query rule). Set it to run every 5 minutes, look back 5 minutes, and trigger an incident on any result. Tag it with tactic `Execution` and technique `T1059.001`.

**To test:** on the VM, run

```powershell
$cmd = "Write-Host 'detection test'"
$enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
powershell.exe -EncodedCommand $enc
```

Within 10 minutes you should see an incident in Sentinel.

### Detection 2 - T1078: Impossible travel sign-in

A user signing in from two countries within a short window is a strong indicator of credential compromise. Entra ID Identity Protection does this natively but writing your own version is a great KQL exercise.

```kql
let lookback = 1h;
SigninLogs
| where TimeGenerated > ago(lookback)
| where ResultType == 0  // successful sign-in
| extend Country = tostring(LocationDetails.countryOrRegion)
| where isnotempty(Country)
| summarize Countries = make_set(Country), SignInCount = count() by UserPrincipalName, bin(TimeGenerated, lookback)
| where array_length(Countries) > 1
```

**To test:** sign in to the M365 portal as one of the dev tenant test users from your normal browser, then immediately sign in again from a VPN exit node in a different country (any free VPN with country selection works for this). Wait 15 minutes for the SigninLogs table to populate, then run the query manually first to confirm before promoting to an analytics rule.

### Detection 3 - T1071.001: Beaconing to a rare external domain

Command and control traffic often shows up as repeated, regular connections to a domain almost no other endpoint in the environment talks to. Real beacon detection is genuinely hard, but a simplified "rare destination + repeat connections" rule is a great teaching example.

```kql
let timeframe = 1h;
DeviceNetworkEvents
| where TimeGenerated > ago(timeframe)
| where ActionType == "ConnectionSuccess"
| where isnotempty(RemoteUrl)
| where RemoteUrl !endswith "microsoft.com"
    and RemoteUrl !endswith "windows.com"
    and RemoteUrl !endswith "office.com"
| summarize ConnectionCount = count(), DistinctDevices = dcount(DeviceId) by RemoteUrl
| where ConnectionCount > 10 and DistinctDevices == 1
| order by ConnectionCount desc
```

**To test:** on the VM, set up a curl loop hitting a domain you control or a free webhook service like `webhook.site`:

```powershell
1..30 | ForEach-Object { Invoke-WebRequest "https://webhook.site/your-uuid-here"; Start-Sleep 5 }
```

Run the KQL query manually after 5 minutes. You should see your webhook URL at the top of the results.

---

## Phase 4 - Build a workbook (~30 min)

Workbooks are Sentinel's dashboarding layer. The point of this step is not to win a Tableau award — it is to prove you can put detections in front of someone non-technical.

In Sentinel → **Workbooks** → **Add workbook**, then add three query tiles:

1. **Incidents by MITRE tactic** — bar chart from `SecurityIncident | summarize count() by tostring(AdditionalData.tactics)`
2. **Top 10 noisy detections** — table from `SecurityAlert | summarize count() by AlertName | top 10 by count_`
3. **Sign-in failures over time** — time chart from `SigninLogs | where ResultType != 0 | summarize count() by bin(TimeGenerated, 1h)`

Save it as `Detection Lab Overview`.

---

## Phase 5 - Document and ship it (~30 min)

The lab is worthless if you cannot show it to someone. Create a folder in your fork of `Homelabs-For-Hackers` called `sentinel-detection-lab/` with:

```
sentinel-detection-lab/
├── README.md           # short summary, architecture diagram, link back to this guide
├── detections/
│   ├── T1059-001-encoded-powershell.kql
│   ├── T1078-impossible-travel.kql
│   └── T1071-001-rare-beacon.kql
├── workbook/
│   └── detection-lab-overview.json   # exported from Sentinel
└── screenshots/
    ├── architecture.png
    ├── incident-detail.png
    └── workbook.png
```

Commit, push, and you have an artefact you can link to from a CV, a job application, or a conversation with a hiring manager.

---

## What to talk about in an interview

Anyone can build a lab. The valuable signal is whether you can talk about *why* you made the choices you did. Be ready for these:

- **"Why these three techniques?"** — You picked one execution, one initial access, one command and control. Together they cover the early-to-middle stages of the kill chain. Encoded PowerShell is high-fidelity and easy to demonstrate; impossible travel hits identity, which is the dominant attack surface in cloud-first orgs; rare-beacon is intentionally noisy so you can talk about *tuning*.
- **"How would you tune detection 3 down?"** — Add allowlists for known SaaS endpoints, baseline against a 7-day rolling window of normal destinations, raise the threshold from 10 to 50 connections, require the destination to be unresolved or recently registered. The honest answer is "this rule would fire constantly in production and would need an hour of tuning per week for the first month."
- **"What would break first if you scaled this to 5,000 endpoints?"** — Ingestion cost. Detection 3 in particular pulls every successful connection, which at 5,000 endpoints is millions of events per hour. You would either move it to a summary table with a daily update query, or push the filtering to the connector layer.
- **"How does this map to Essential Eight?"** — Detection coverage feeds into ML2's monitoring requirements (logging, event correlation), and the overall workspace supports the Essential Eight maturity reporting story. It is not itself an Essential Eight control but it is the evidence layer.

---

## Stretch goals

- Add a **Logic App playbook** that posts every new incident into a Teams channel
- Write a fourth detection mapped to **T1486 (Data Encrypted for Impact)** using `DeviceFileEvents` to flag mass file renames
- Connect a second VM and rewrite Detection 3 to require the rare destination to be hit by a single device but multiple processes
- Export your detections as **Sigma rules** and check them into a separate `sigma/` directory — Sigma is portable across SIEM platforms and is a great signal of detection engineering maturity

---

## Tear down

When you are done:

1. Delete the Log Analytics workspace (this kills Sentinel and stops all ingestion)
2. Delete the Azure resource group containing the workspace
3. Offboard the VM from Defender (Settings → Endpoints → Offboarding → Local Script)
4. The M365 dev tenant can stay — it costs nothing and you will probably use it for the next lab

---

*Built and maintained as part of [Homelabs for Hackers](https://github.com/thelocalfrogman/Homelabs-For-Hackers) by [George Ferres](https://georgeferres.com). MIT licensed. PRs welcome — especially if you find a bug in the KQL or a cheaper way to keep the lab running.*