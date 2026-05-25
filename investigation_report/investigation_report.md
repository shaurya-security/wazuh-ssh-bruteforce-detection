# Investigation Report: SSH Brute Force (Lab)

**Date:** 2026-05-24
**Analyst:** Shaurya

---

## Alert Triage

| Field | Value |
|---|---|
| Source IP | 192.168.122.1 (Linux Mint host) |
| Target | shaurya-fedora @ 192.168.122.62 |
| Failures | 5 within ~17 seconds |
| Alert fired at | 2026-05-24 09:01:02 UTC |
| Severity | Level 12 |

---

## Timeline

Pulled from the alert JSON.

| Time (UTC) | Event |
|---|---|
| 09:00:44 | Failure #1 |
| 09:00:48 | Failure #2 |
| 09:00:54 | Failure #3 |
| 09:00:57 | Failure #4 |
| 09:01:01 | Failure #5 — rule triggered |
| 09:01:02 | Wazuh alert fired |

---

## What I Noticed

- All attempts came from the same IP, targeting the same user — no enumeration
- Two different source ports (45472 and 47456) — two separate SSH sessions opened
- Everything happened in under 20 seconds — pretty fast even for manual attempts

---

## Hypothesis

Source IP is internal, so either the host machine got compromised or something automated was misfiring with old credentials. In this case it was neither — just a deliberate simulation — but those are the two realistic possibilities.

---

## MITRE

**T1110.001 — Brute Force: Password Guessing**
Attacker had a valid username and was guessing the password. No lateral movement or persistence was observed.

---

## Next Steps (Real World)

- Block the source IP at the firewall
- Check the source machine — processes, history, cron jobs — for anything SSH-related
- Switch to key-based SSH auth and disable password login entirely

---

## What I'd Do Differently

- Set up active response so Wazuh auto-blocks the IP instead of just alerting
- The 5-failure threshold is okay but an attacker could space attempts out and stay under it — might tune it tighter
- Only have host logs here, no network-level visibility — would be better to have both
