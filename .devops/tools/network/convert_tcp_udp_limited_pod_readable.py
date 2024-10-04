# DevOps.click
## v0.1
# This script translate non-human-readable hex to readable format.
# Useful when troubleshooting a Pod with very limited resources.
# Usage:
# cat /proc/net/tcp
# cat /proc/net/udp
# paste it into tcp_data as exemplified and run.

tcp_data = [
  "0: B514800A:806E FB9714AC:18EB 01 00000000:00000000 02:000058EC 00000000 999 0 945376273 2 0000000000000000 20 4 18 10 -1",
  "1: B514800A:806C FB9714AC:18EB 01 00000000:00000000 02:000058EC 00000000 999 0 945374745 2 0000000000000000 20 4 18 10 -1",
  "2: B514800A:8058 FB9714AC:18EB 01 00000000:00000000 02:000058EC 00000000 999 0 945373847 2 0000000000000000 20 4 10 10 -1",
]

translated_list = []

for line in tcp_data:
  parts = line.split()
  local_ip_hex, local_port_hex = parts[1].split(':')
  remote_ip_hex, remote_port_hex = parts[2].split(':')

  # Convert hex IP to human-readable IP
  local_ip = '.'.join(map(str, reversed(bytearray.fromhex(local_ip_hex))))
  remote_ip = '.'.join(map(str, reversed(bytearray.fromhex(remote_ip_hex))))

  # Convert hex port to decimal
  local_port = int(local_port_hex, 16)
  remote_port = int(remote_port_hex, 16)

  translated_list.append(f"Local: {local_ip}:{local_port}, Remote: {remote_ip}:{remote_port}")

# translated_list

# Print the translated list
for item in translated_list:
  print(item)
