# iptables Command Reference

This document summarizes common `iptables` / `ip6tables` commands, parameters, and practical scenarios for quick lookup.

## 1. Core Concepts

- **Table**: functional group of rules (`raw`, `mangle`, `nat`, `filter`).
- **Chain**: traversal path within a table (`INPUT`, `OUTPUT`, `FORWARD`, `PREROUTING`, `POSTROUTING`).
- **Rule**: match conditions + target action.
- **Target**: resulting action (`ACCEPT`, `DROP`, `REJECT`, `LOG`, `SNAT`, `DNAT`, etc.).

IPv6 uses `ip6tables` with nearly identical syntax.

## 2. Command Pattern

```bash
iptables [-t table] COMMAND [chain] [match options] [-j target]
```

| Option | Meaning |
| --- | --- |
| `-t` | Specify table (default: `filter`) |
| `-L` | List rules |
| `-n` | Numeric output |
| `-v` | Verbose output |
| `--line-numbers` | Show rule line numbers |
| `-A/-I/-D/-R` | Append / Insert / Delete / Replace |
| `-F/-Z/-X` | Flush rules / Zero counters / Delete custom chain |
| `-P` | Set default policy |
| `-m` | Use extension module |
| `-j` | Set target action |

## 3. Useful Commands

### 3.1 List Rules

```bash
iptables -L -n -v --line-numbers
iptables -t nat -L -n -v
ip6tables -t filter -L INPUT -n
```

### 3.2 Default Policies

```bash
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
```

### 3.3 Open Common Ports

```bash
iptables -A INPUT -p tcp --dport 22 -s 10.0.0.0/24 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m state --state NEW -j ACCEPT
```

### 3.4 NAT and Forwarding

```bash
# SNAT
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j SNAT --to-source 203.0.113.10

# MASQUERADE for dynamic outbound IP
iptables -t nat -A POSTROUTING -s 10.10.0.0/16 -o ppp0 -j MASQUERADE

# DNAT
iptables -t nat -A PREROUTING -d 203.0.113.10/32 -p tcp --dport 2222 -j DNAT --to-destination 192.168.0.10:22
```

### 3.5 Logging and Rate Limits

```bash
iptables -A INPUT -p tcp --dport 22 -m limit --limit 3/min -j LOG --log-prefix "SSH attempt: "
iptables -A INPUT -p icmp -m limit --limit 1/s --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp -j DROP
```

### 3.6 Save and Restore

```bash
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6
iptables-restore < /etc/iptables/rules.v4
ip6tables-restore < /etc/iptables/rules.v6
```

## 4. Troubleshooting Tips

1. Check whether the system uses `iptables-nft` or `iptables-legacy` (`iptables -V`).
2. Verify required kernel modules such as `nf_conntrack` are available.
3. Confirm rule order when behavior is unexpected.
4. Use `LOG` targets to inspect dropped traffic.
5. Persist and reload rules after reboot.