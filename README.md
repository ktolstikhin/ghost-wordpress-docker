# Host Ghost and WordPress on the same VPS with Docker

![](../assets/ghost_wordpress_docker.png?raw=true)

This projects shows how to host Ghost and WordPress blogs side by side on the same server using Nginx reverse proxy, SSL encryption, and automated deployment with Docker Compose. The reverse proxy is responsible for routing incoming requests between blog containers and ensures automatic update of free SSL/TLS certificates provided by [Let's Encrypt](https://letsencrypt.org/) certificate authority. Actually, this setup is not limited to hosting just ghost and wordpress websites, but allows you to run any number of web applications alongside with no worries about routing, SSL, and everything.

## Requirements

* A registered domain name and a DNS A-record pointing to your server's public IP address.

* A GNU/Linux distribution, something like Ubuntu 18.04 LTS.

* [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/), [Docker Compose](https://docs.docker.com/compose/install/), and [Docker Machine](https://docs.docker.com/machine/install-machine/).

## Deployment

Spin up a target VPS and apply firewall settings using `bin/firewall.sh` script, if needed. Then, create a target machine using Docker Machine on the development host and connect the running shell to the new machine just created. You can now run Docker commands on the target host. First, you need to create a proxy network:
```bash
$ cd proxy
$ ./bin/proxynet.sh
```
which is equivalent to running this command:
```bash
$ docker network create proxy
```
Then, start the reverse proxy containers defined in `docker-compose.yml` file:
```bash
$ docker-compose up -d
```
Once the reverse proxy is up and running, you can finally start blog containers:
```bash
$ cd ../ghost
$ docker-compose up -d
$ cd ../wordpress
$ docker-compose up -d
```
In the `ghost` and `wordpress` folders, there is `.env` file with environment variables such as `DOMAIN_NAME`, `ADMIN_EMAIL`, etc. Update it with your values before starting a blog service.

## Backup

The `cron` container, which image is defined in `cron/Dockerfile`, is responsible for periodical backup of data stored in shared volumes. Note the mount points of all the shared data volumes must have suffix `_data` in their paths such as `${DATA_PATH}/ghost_data` in `ghost/docker-compose.yml` or `${DATA_PATH}/wordpress_data` in `wordpress/docker-compose.yml` files. This convention is used by the backup script `cron/bin/backup.sh` to filter out the data folders for a subsequent backup.

