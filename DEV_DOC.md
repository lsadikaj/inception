# Developer Documentation

## Setting up the environment from scratch

On a fresh machine, the following steps are required before the project can run:

1. **Install Docker and Docker Compose.** The whole infrastructure relies on them; nothing runs without them.

2. **Clone the repository** and move to its root, where the `Makefile` is located.

3. **Configure the domain.** Add `127.0.0.1 lsadikaj.42.fr` to `/etc/hosts` so the domain resolves to the local machine.

4. **Create the environment file** `srcs/.env` with the required variables: domain name, database name, database user, WordPress title, and the WordPress users and emails. This file is not versioned and must be created manually.

5. **Create the secret files** in the `secrets/` directory at the project root: `db_password.txt`, `db_root_password.txt`, and `credentials.txt`. These are also excluded from version control.

6. **Create the volume directories** on the host, since the named volumes use custom paths that must already exist:

```bash
mkdir -p /home/lsadikaj/data/mariadb
mkdir -p /home/lsadikaj/data/wordpress
```

Once these steps are done, the project is ready to be built and launched.

## Building and launching the project

The project is driven entirely by the `Makefile` at the root, which wraps the underlying Docker Compose commands. The compose file itself lives in `srcs/docker-compose.yml`.

### Make targets

- `make` (default) builds the images and starts the containers:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

- `make down` stops and removes the containers, leaving images and volumes untouched:

```bash
docker compose -f srcs/docker-compose.yml down
```

- `make clean` stops everything and also removes images, volumes, and orphan containers:

```bash
docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans
```

- `make re` runs `clean` then `make`, rebuilding the whole infrastructure from scratch.

### What happens on `make`

When `make` runs, Docker Compose performs the following steps:

1. It creates the custom bridge network `inception_network`, along with its internal DNS, so containers can reach each other by service name.
2. It creates the named volumes, mapping them to the host directories under `/home/lsadikaj/data`.
3. It builds each image from its Dockerfile (`debian:bookworm` base, services installed and configured by hand).
4. It starts the containers in dependency order: MariaDB first, then WordPress (which waits for MariaDB to be ready), then NGINX.

Each container runs its entrypoint script, which performs first-time initialization if needed (creating the database, installing WordPress, generating the SSL certificate) before launching its main process as PID 1.

## Managing containers and volumes

Useful commands for inspecting and managing the running infrastructure:

- **List running containers:**

```bash
docker ps
```

- **View a container's logs** (main debugging tool):

```bash
docker logs <container_name>
```

- **Open a shell inside a running container**, to inspect it from the inside:

```bash
docker exec -it <container_name> bash
```

- **List the project's volumes:**

```bash
docker volume ls
```

- **Inspect a volume** to see its configuration and mount point:

```bash
docker volume inspect <volume_name>
```

## Data storage and persistence

The infrastructure uses two named volumes, both mapped to directories on the host under `/home/lsadikaj/data`:

- `db_volume` is mounted at `/var/lib/mysql` inside the MariaDB container and stores the database files. On the host, its data lives in `/home/lsadikaj/data/mariadb`.
- `wp_volume` is mounted at `/var/www/html` inside the WordPress and NGINX containers and stores the WordPress files (core, themes, plugins, uploaded media). On the host, its data lives in `/home/lsadikaj/data/wordpress`.

Because the data is stored on the host through these volumes, it persists independently of the containers' lifecycle. Running `make down` removes the containers but keeps the volumes, so the next `make` restores the site exactly as it was. Only `make clean` deletes the volumes, which resets the database and forces a fresh WordPress installation on the next build.