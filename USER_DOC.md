# User Documentation

## Services provided by the stack

The infrastructure runs three services, each in its own container:

- **NGINX** is the web server and the only entry point to the infrastructure. It is the only service reachable from a browser, and it handles all incoming HTTPS traffic on port 443.

- **WordPress (with PHP-FPM)** is the website itself. It comes with two users: an administrator, who has full control over the site, and an author, who can write and edit content but cannot manage other users or change site settings.

- **MariaDB** is the database engine used by WordPress. It stores and organizes all the dynamic data of the site (posts, users, comments, settings) and answers WordPress's queries.

The data is kept safe through two named volumes. One stores the database files written by MariaDB, the other stores the WordPress files (themes, plugins, uploaded media). Thanks to these volumes, the data survives even if the containers are removed and recreated: after a restart, the site is exactly as it was before.

## Starting and stopping the project

All commands are run from the root of the project, where the `Makefile` is located.

- **Start the infrastructure:**

```bash
make
```

This builds the images if needed and starts all three containers in the background. Once it finishes, the site is up and running.

- **Stop the infrastructure:**

```bash
make down
```

This stops and removes the containers. The data is preserved, so the next `make` brings the site back exactly as it was.

- **Reset everything:**

```bash
make clean
```

This stops and removes the containers, along with the images and the volumes. The stored data is deleted, so the next `make` rebuilds the whole infrastructure from scratch.

## Accessing the website and the admin panel

- **Website:** open `https://lsadikaj.42.fr` in a browser.
- **Admin panel:** open `https://lsadikaj.42.fr/wp-admin` to reach the WordPress administration dashboard, where the site can be managed (posts, users, settings, themes).

Because the site uses a self-signed SSL certificate, the browser will display a security warning on the first visit. This is expected: the certificate was generated locally rather than issued by a recognized certificate authority. You can safely proceed past the warning to reach the site.

## Locating and managing credentials

Credentials are never stored in the repository or hardcoded in any file. They live in two places on the host machine, both excluded from version control:

- **Secret files**, in the `secrets/` directory at the project root:
  - `db_password.txt` — the password of the WordPress database user
  - `db_root_password.txt` — the MariaDB root password
  - `credentials.txt` — the WordPress administrator username and password
- **Environment file**, `srcs/.env`, which holds non-sensitive configuration such as the database name, the domain name, and the WordPress usernames and emails.

To change a credential, edit the corresponding file and rebuild the infrastructure with `make clean` followed by `make`, so the change is applied to a fresh database.

## Checking that the services are running

To verify that the infrastructure is working correctly, several Docker commands are available.

- **Check container status:**

```bash
docker ps
```

This lists the running containers. All three (`nginx`, `wordpress`, `mariadb`) should appear with an "Up" status. Adding `-a` also shows stopped containers, which is useful if one of them has crashed (it will appear with an "Exited" status).

- **Inspect a service's logs:**

```bash
docker logs <container_name>
```

For example, `docker logs mariadb` shows the database logs. This is the main tool for diagnosing a service that fails to start or behaves unexpectedly.

- **Access the website:**

Opening `https://lsadikaj.42.fr` in a browser and seeing the WordPress site load is the simplest end-to-end confirmation that all three services are working together.