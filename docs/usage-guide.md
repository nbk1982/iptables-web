# iptables-web Usage Guide

This guide explains how to deploy and operate iptables-web, including prerequisites, configuration, UI workflow, and REST API behavior.

## 1. Overview

- Manages both `iptables` (IPv4) and `ip6tables` (IPv6).
- Provides an embedded web interface in a single binary.
- Exposes REST endpoints for all major UI actions.
- Supports import/export and direct command execution.

## 2. Requirements

| Item | Requirement |
| --- | --- |
| OS | Linux with netfilter/iptables enabled |
| Privileges | `root` or equivalent (`CAP_NET_ADMIN`) |
| Commands | `iptables`, `iptables-save`, `iptables-restore` (and IPv6 variants) |
| Build toolchain | Go version declared in `go.mod` |

## 3. Deployment

### Docker

```bash
docker run -d \
  --name iptables-web \
  --privileged=true \
  --net=host \
  -e IPT_WEB_USERNAME=admin \
  -e IPT_WEB_PASSWORD=admin \
  -e IPT_WEB_ADDRESS=:10001 \
  -p 10001:10001 \
  pretty66/iptables-web:latest
```

### Binary

```bash
git clone https://github.com/pretty66/iptables-web.git
cd iptables-web
make release
./iptables-server -a :10001 -u admin -p admin
```

## 4. Configuration

| Purpose | Flag | Env var | Default |
| --- | --- | --- | --- |
| Listen address | `-a` | `IPT_WEB_ADDRESS` | `:10001` |
| Username | `-u` | `IPT_WEB_USERNAME` | `admin` |
| Password | `-p` | `IPT_WEB_PASSWORD` | `admin` |

Priority is `CLI > environment > defaults`.

## 5. UI Workflow

1. Select protocol (`IPv4`/`IPv6`) at the top.
2. Choose table (`raw`, `mangle`, `nat`, `filter`).
3. Use chain-level actions to insert, append, flush, zero counters, and inspect command output.
4. Use global actions to flush table-wide rules, clear counters, remove empty custom chains, and import/export rule sets.

## 6. REST Endpoints

All endpoints require Basic Auth. Optional `protocol` supports `ipv4` and `ipv6`.

| Endpoint | Method | Notes |
| --- | --- | --- |
| `/version` | GET | Returns command version output |
| `/listRule` | POST | Lists rules by table/chain |
| `/listExec` | POST | Returns `iptables-save` output |
| `/flushRule` | POST | Flushes rules |
| `/flushMetrics` | POST | Resets counters |
| `/deleteRule` | POST | Deletes rule by line number |
| `/getRuleInfo` | POST | Returns one rule definition |
| `/flushEmptyCustomChain` | POST | Removes empty custom chains |
| `/export` | POST | Exports rule text |
| `/import` | POST | Imports rule text via restore |
| `/exec` | POST | Runs arbitrary command args |

## 7. Troubleshooting

- If IPv6 fails with `ipv6 iptables not available`, install `ip6tables` or run IPv4 only.
- If auth prompts keep reappearing, verify credentials and endpoint URL.
- If rules are not applied, check host-level iptables availability and nftables compatibility.
- For import errors, inspect `iptables-restore` output in logs.