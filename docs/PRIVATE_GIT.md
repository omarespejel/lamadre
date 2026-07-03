# Private Git for Lamadre (OPSEC & Pseudonym Development)

For pseudonym development ("Ömer" Turkish persona or consistent handle) we avoid public GitHub history leaks.

## Recommended Options

### 1. Self-hosted Forgejo (GitHub-like)
- Docker compose on a VPS (Hetzner/Contabo in EU or Switzerland for company synergy).
- Tailscale or Wireguard + Caddy + Tor hidden service for access.
- Users: only invited keys.
- Backups to encrypted S3 or local.
- Cost: ~$5-12/mo VPS.

Example docker-compose (simplified):
```yaml
services:
  server:
    image: codeberg.org/forgejo/forgejo:9
    ...
```

### 2. Radicle (P2P, fully decentralized)
- `rad` CLI.
- Identities are keys only (no usernames needed initially).
- `rad patch`, `rad issue`.
- Seed nodes for availability.
- Perfect for strong pseudonymity. Team shares peer IDs.
- Can seed to public seed but keep sensitive repo private.

## Workflow
- Day-to-day: private Forgejo or Radicle.
- Public release commits (after audits/grants): squash + force-push signed to GitHub under pseudonym.
- Never push direct to main. Use PRs even internally.
- Sign commits (SSH or PGP under persona).

## Migration from this repo
See the exact git commands used to init: documented in prior session + this repo's history.
Once private remote is ready, `git remote set-url origin <private>` and push.

## Notes
- GitHub will be used only as public mirror for grants / visibility.
- All detailed design history stays in private.
