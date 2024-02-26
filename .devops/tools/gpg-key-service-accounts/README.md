This tool updates GPG Keys from environments.
WARNING: You should only do that in case of LEAK!!!
As soon as you change this, all terraform objects that depend on this key will be RECREATED!!!

Usage:

```bash
./run <3_digit_environment>
ex:
./run fin
```