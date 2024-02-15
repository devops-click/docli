This script is intended to be used only by DevOps.click Team

### Requirements
- authenticator (private-repository)
- ~/.ssh/config
```bash
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```
- alias:
```bash
alias sshmfa='expect $DOCLI/tools/mfa-expect/run username' ## #mfa #login
```

### Usage
```bash
sshmfa ip
```
