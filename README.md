*This project has been created as part of the 42 curriculum by lsadikaj.*

# Inception

## Description

Inception is a system administration project designed to teach the fundamentals of containerization using Docker. The goal is to set up a small but complete web infrastructure running inside a virtual machine, where each service runs in its own dedicated container.

The infrastructure is composed of three services: NGINX, WordPress with PHP-FPM, and MariaDB. They communicate through a private Docker network, persist their data through named volumes, and expose a single secure entry point to the outside world via NGINX over HTTPS.

## Instructions

### Prerequisites

- A Linux virtual machine
- Docker and Docker Compose installed
- `make`

### Setup

1. Clone the repository and enter the project directory:

```bash
   git clone <repository-url> inception
   cd inception
```

2. Create the environment file `srcs/.env` with the required variables (domain name, database name and user, WordPress title and users). A `.env` is not included in the repository for security reasons.

3. Create the secret files inside a `secrets/` directory at the project root:
   - `db_password.txt`
   - `db_root_password.txt`
   - `credentials.txt`

4. Create the directories used by the named volumes on the host machine:

```bash
   mkdir -p /home/lsadikaj/data/mariadb
   mkdir -p /home/lsadikaj/data/wordpress
```

5. Add the domain to your `/etc/hosts` file so it points to the local machine:

```bash
   echo "127.0.0.1 lsadikaj.42.fr" | sudo tee -a /etc/hosts
```

6. Build and start the infrastructure:

```bash
   make
```

Once the containers are running, the site is available at `https://lsadikaj.42.fr`.

## Project description

This project uses Docker to run each service in its own isolated container, orchestrated together with Docker Compose. None of the images are pulled ready-made from DockerHub: each one is built from a custom Dockerfile based on `debian:bookworm` (the penultimate stable Debian release), and every service is installed and configured by hand. This is a deliberate design choice required by the project, meant to ensure full control over, and understanding of, each part of the infrastructure.

The main design decisions are detailed in the comparisons below.

### Virtual Machines vs Docker

A virtual machine runs its own complete operating system, including its own kernel, on top of a hypervisor. This makes VMs heavy and slow to start, since every instance duplicates a full OS.

A Docker container shares the kernel of the host machine and only packages the application and its dependencies. Containers are therefore much lighter and start almost instantly.

The trade-off is isolation. A VM is isolated at the hardware level and is fully sealed off, while a container is isolated at the process level. Because all containers share the host kernel, a kernel-level exploit could potentially affect every container on the machine, which is not the case with VMs.

### Secrets vs Environment Variables

Environment variables are used for non-sensitive configuration values, such as the database name or the domain name. They are convenient, but they are not secure: anyone with access to the image or the running container can read them through `docker inspect`, and they may also leak into logs.

Secrets are designed for sensitive data such as passwords. Instead of being passed as plain environment variables, they are mounted as files under `/run/secrets/` inside the container, kept in memory, and never exposed through `docker inspect`. In this project, the database passwords and the WordPress admin credentials are handled as secrets for this reason.

### Docker Network vs Host Network

With host networking, a container shares the network stack of the host machine directly. There is no isolation between the container and the host at the network level, which is both a security concern and a source of port conflicts.

This project uses a custom bridge network instead. Each container gets its own isolated network interface, and Docker provides an internal DNS that lets containers reach each other by their service name (for example, WordPress connects to MariaDB simply through the name `mariadb`) without needing to know any IP address. Using `network: host` and `--link` is explicitly forbidden by the project.

### Docker Volumes vs Bind Mounts

A bind mount maps an existing directory from the host directly into a container. The host path must already exist and is managed entirely by the user. This creates a tight coupling between the container and the host's directory structure.

A named volume is managed by Docker itself. The project requires named volumes for the database and the WordPress files, and forbids plain bind mounts for them. To also satisfy the requirement that the data live under `/home/lsadikaj/data`, the volumes are declared as named volumes with custom `driver_opts` pointing to that path. This keeps them managed by Docker (they appear in `docker volume ls`) while storing their data at a chosen host location, which is why those directories must be created before the first launch.

## Resources

### References

- [Docker official documentation](https://docs.docker.com); the primary reference for Docker, Docker Compose, networks, volumes, and secrets.
- Various YouTube tutorials, used to get a more practical, project-oriented overview when the official documentation went into more detail than this project required.

### Use of AI

AI was used as a learning aid rather than a code generator. The official documentation is exhaustive and covers many features that are not relevant to this project, so AI was used to narrow things down and clarify specific points through iteration.

Concretely, it was used like a tutor that could be questioned precisely on whatever was still unclear: the difference between an image and a container, why an entrypoint must end with `exec`, how the internal Docker DNS lets containers reach each other by name, or why MariaDB needs `bind-address = 0.0.0.0` to accept connections from another container. The goal throughout was to understand every part of the project well enough to explain and defend it, not to produce code that would be copied without understanding.