# DevOps.click
- This script translate non-human-readable hex to readable format.
- Useful when troubleshooting a Pod with very limited resources.

## Usage:

1. Get the needed TCP/UDP information:
- `cat /proc/net/tcp`
- `cat /proc/net/udp`

2. Paste it into `tcp_data` field:

```bash
tcp_data = [
  "0: B514800A:806E FB9714AC:18EB 01 00000000:00000000 02:000058EC 00000000 999 0 945376273 2 0000000000000000 20 4 18 10 -1",
  "1: B514800A:806C FB9714AC:18EB 01 00000000:00000000 02:000058EC 00000000 999 0 945374745 2 0000000000000000 20 4 18 10 -1",
  "2: B514800A:8058 FB9714AC:18EB 01 00000000:00000000 02:000058EC 00000000 999 0 945373847 2 0000000000000000 20 4 10 10 -1",
]
```

3. Run:
```bash
python convert_tcp_udp_limited_pod_readable.py
```

- Output Example:
```txt
Local: 10.128.20.181:32878, Remote: 172.20.151.251:6379
Local: 10.128.20.181:32876, Remote: 172.20.151.251:6379
Local: 10.128.20.181:32856, Remote: 172.20.151.251:6379
```