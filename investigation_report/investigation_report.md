# Investigation Report: SSH Brute Force (Lab)

## Alert triage
- **Source IP**: 192.168.122.1 (Linux Mint host)
- **Target**: shaurya-fedora@192.168.122.62
- **Time window**: 6 minutes
- **Total failures**: 6

## Hypothesis
Internal machine compromised or misconfigured automation.

## Next steps (real world)
- Isolate source IP via firewall
- Check source machine for malware
- Enforce key-based authentication
