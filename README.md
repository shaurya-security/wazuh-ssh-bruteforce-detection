# SSH Brute Force Detection with Wazuh

Simulated an SSH brute force attack on a local virtual lab and detected it using a custom Wazuh rule.

---

## What I Did

Set up a small home lab with three machines — a Linux Mint host acting as the attacker, a Fedora workstation as the victim (running as a KVM VM), and an Ubuntu Server running the Wazuh stack (also a KVM VM).

Wrote a custom local rule in Wazuh to detect repeated SSH login failures from the same IP within a short window. Then manually triggered the attack from the host machine by failing SSH logins into the Fedora VM multiple times. The rule fired, and the alert showed up on the Wazuh dashboard.

---

## Lab Setup

| Role | OS |
|------|-----|
| Host / Attacker | Linux Mint |
| Victim (Agent) | Fedora Workstation (KVM) |
| Wazuh (SIEM) | Ubuntu Server (KVM) |

![Lab Diagram](architecture/lab-diagram.png)

---

## The Rule

```xml
<group name="local,ssh_bruteforce,">
  <rule id="100001" level="12" frequency="5" timeframe="360">
    <if_matched_sid>5760</if_matched_sid>
    <same_srcip />
    <description>SSH brute force attack detected: 4+ failures from $(srcip) in 6 minutes</description>
    <mitre>
        <id>T1110</id>
    </mitre>
    <group>brute_force,authentication_failures,</group>
  </rule>
</group>
```

Triggers when 5+ failed SSH attempts come from the same source IP within 6 minutes. Mapped to MITRE ATT&CK **T1110 — Brute Force**.

---

## Screenshots

**Before the attack**
![Dashboard Before](images/dashboard-before.png)

**Running the attack**
![SSH Attack](images/ssh-attack.png)

**Rule configuration**
![Local Rule](images/local-rule.png)

**Alert triggered**
![Dashboard After](images/dashboard-after.png)

---

## Alert (JSON)

The full alert output is in [`alerts/ssh-bruteforce-alert.json`](alerts/ssh-bruteforce-alert.json).

Quick summary of what fired:

| Field | Value |
|-------|-------|
| Rule ID | 100001 |
| Level | 12 (high severity) |
| Source IP | 192.168.122.1 (Linux Mint host) |
| Target user | shaurya-fedora |
| Agent | Fedora-desktop |
| MITRE | T1110 — Credential Access |
| Timestamp | 2026-05-24 09:01:02 UTC |

The `previous_output` field in the alert JSON contains the 4 preceding failed login lines — the full attack chain, not just the final triggering event.

---

## Rule — Technical Breakdown

```xml
<rule id="100001" level="12" frequency="5" timeframe="360">
```

- `id="100001"` — custom rules start at 100000 to avoid colliding with Wazuh's built-in IDs
- `level="12"` — high severity on Wazuh's 0–15 scale
- `frequency="5"` — fires after 5 matching events
- `timeframe="360"` — within a 360-second (6-minute) window

```xml
<if_matched_sid>5760</if_matched_sid>
```

SID 5760 is Wazuh's base rule for SSH failed password attempts. This custom rule stacks on top of it — no need to re-parse the raw log, just watch for that rule firing repeatedly.

```xml
<same_srcip />
```

The 5 failures must come from the same source IP. Without this, failures from different IPs could accumulate across the timeframe and incorrectly trigger the rule.

---

## Investigation Report

Full triage write-up: [`investigation_report/investigation_report.md`](investigation_report/investigation_report.md)

| Field | Value |
|-------|-------|
| Source IP | 192.168.122.1 (Linux Mint host) |
| Target | shaurya-fedora @ 192.168.122.62 |
| Time window | 6 minutes |
| Total failures | 6 |
| Verdict | True positive (controlled lab) |

**Hypothesis:** Internal machine compromised or misconfigured automation.

**Real-world next steps:**
- Isolate source IP via firewall rule
- Examine source machine for malware or unauthorized scripts
- Enforce key-based authentication, disable password auth on SSH

---

## Files

```
wazuh-ssh-bruteforce-detection/
├── alerts/
│   └── ssh-bruteforce-alert.json          # Raw alert from Wazuh index
├── architecture/
│   └── lab-diagram.png                    # Lab topology
├── images/
│   ├── dashboard-before.png
│   ├── dashboard-after.png
│   ├── local-rule.png
│   └── ssh-attack.png
├── investigation_report/
│   └── investigation_report.md            # Triage summary and response steps
├── rules/
│   └── local_rules.xml                    # Custom Wazuh rule
└── README.md
```

---

## Tools Used

- [Wazuh](https://wazuh.com) — open source SIEM / XDR
- KVM — virtualization
- Linux Mint, Fedora, Ubuntu Server
