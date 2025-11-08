
# Cloud-1 — Automated Inception-like deployment

This repository contains an automated deployment for a small multi-container web stack (WordPress + DB + phpMyAdmin and related helpers) designed to satisfy the "Inception" style assignment requirements: 1 process per container, persistent data, automated deployment via Ansible and docker-compose, and secure exposure of services.

This README describes the project purpose, repository layout, deployment contract, quick usage, common edge cases, and cleanup tips.

## Project contract (short)
- Inputs: an Ubuntu 20.04-like target server reachable via SSH with Python installed and an Ansible control machine (your laptop).
- Outputs: a running WordPress site backed by a persistent SQL database and phpMyAdmin, with Docker containers managed by docker-compose and services started automatically on server reboot.
- Error modes: failure to connect via SSH, missing privileges (become/sudo), missing disk space, or conflicting ports on the host.

## Quick repository overview

Top-level files you'll use:
- `playbook.yml` — main Ansible playbook that orchestrates the deployment.
- `inventory.yml` — inventory describing target hosts / groups.
- `ansible.cfg` — Ansible configuration used by the playbook.
- `roles/` — Ansible roles used by the playbook (install Docker, deploy containers, build images, etc.).

Important roles (brief):
- `roles/config/` — places configuration files (includes `config/files/docker-compose.yml`).
- `roles/mariadb/` — mariadb Dockerfile and build/run tasks; persistent volumes are configured here.
- `roles/nginx/`, `roles/wordpress/` — build and/or run tasks for those services.
- `roles/docker/`, `roles/docker-down/`, `roles/docker-restart/` — helper roles to control the docker stack.
- `roles/clean-all/` — helper role to remove containers/data for cleanup during tests.

The repo includes Dockerfiles and helper scripts under the roles' `files/tools/` directories to build and run custom images.

## Prerequisites (control and target)

- On your control machine (where you run Ansible):
	- Ansible 2.9+ (or compatible), SSH key configured for target host.
	- Python 3 (for Ansible itself).
- On each target host (assumed Ubuntu 20.04 LTS):
	- SSH server reachable from control machine.
	- Python installed (Ansible requires it for remote execution).

The playbook is written to install Docker and Docker Compose on the target, but the host must be reachable and allow your Ansible user to become root (or provide proper sudo access).

## How to deploy (quick)

1. Edit `inventory.yml` and ensure your target host(s) and user are configured. Keys and connection options can also be set in `ansible.cfg` or your environment.

2. Replace .env.example with your own `.env` file in `roles/wordpress/files/` and set appropriate environment variables (database credentials, WordPress settings, etc.).

3. Run the playbook from the repo root:

```bash
ansible-playbook -i inventory.yml playbook.yml
```

Notes and options:
- If you need to specify the SSH user or key explicitly, you can use flags or modify `inventory.yml`. Example:

```bash
ansible-playbook -i inventory.yml playbook.yml -u ubuntu --private-key ~/.ssh/id_rsa
```

- The playbook should:
	- install Docker & docker-compose on the target(s) if not present,
	- build or pull custom images from the `roles/*/files` as required,
	- deploy the docker-compose stack found in `roles/config/files/docker-compose.yml`,
	- create and mount persistent volumes for WordPress uploads and database data so data survives server reboots.

4. After the playbook completes, visit the server's HTTP(S) endpoint to see WordPress.

## Testing & verifying

- Check containers on the host (SSH to host):

```bash
docker ps
docker-compose -f /path/to/deployed/docker-compose.yml ps
docker-compose -f /path/to/deployed/docker-compose.yml logs -f
```

- Confirm persistence by creating content or uploading media to WordPress, then restart docker or reboot the host and verify content persists.

## TLS and domains

This repo does not ship a preconfigured Let's Encrypt automation, but it's tested to be compatible with common patterns:
- Use a reverse proxy (nginx or Traefik) in front and configure certbot or ACME client (DuckDNS + certbot is a common free approach).
- If you have a domain, add DNS for the host and point the reverse-proxy to terminate TLS and route requests to the WordPress service.

## Security recommendations

- Do not expose your database port to the internet. The stack should keep DB on the private Docker network and only expose HTTP(S) via the reverse proxy.
- Use strong credentials (use Ansible Vault for secrets if you store them in the repo or playbook).
- Lock SSH access to your control IP and use key-based authentication.
- If you enable phpMyAdmin, restrict access to it with firewall rules or HTTP auth.

## Persistence and backups

- The stack uses Docker volumes or host-mounted directories for persistent storage (see `roles/mariadb/` and `roles/wordpress/`).
- Back up the database volume and uploads directory regularly. A simple dump approach:

```bash
docker exec <mariadb_container> /usr/bin/mysqldump -u root -p<password> <dbname> > backup.sql
```

Or use Ansible tasks to run scheduled backups.

## Common edge cases and notes

- SSH/connectivity failures: ensure the host is reachable and the correct user/key are set in `inventory.yml`.
- Port conflicts: ensure ports 80/443 are free or adjust the reverse proxy configuration.
- Disk space: images, containers, and DB data require disk space; choose an instance size accordingly.
- Reboots: Docker Compose should be started with a system service (or Docker restart policy) so containers start automatically. The playbook aims to configure that; verify `docker-compose` start behavior on your distro.

## Cleanup

If you want to remove the deployed stack and free resources, you can use the `clean-all` role or manually remove containers, images and volumes (be careful — this is destructive):

```bash
# Example destructive cleanup (run on target host only):
docker-compose -f /path/to/docker-compose.yml down --volumes --remove-orphans
docker system prune -af
```

Prefer using the Ansible role `roles/clean-all/` if it is implemented by the playbook:

```bash
ansible-playbook -i inventory.yml playbook.yml --tags clean
```

## Credits

Project and assignment inspired by the "Cloud-1 / 42 School" subject.
