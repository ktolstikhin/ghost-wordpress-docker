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
$ cd server/proxy
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
The database management for both ghost and wordpress blogs is done using [Adminer](https://www.adminer.org/) which is running in a separate container. In order to start it, you have to create another one network first:
```bash
$ cd ../adminer
$ ./bin/adminernet.sh
```
which is just the same as executing the following:
```bash
$ docker network create adminer
```
Then, start the adminer service:
```bash
$ docker-compose up -d
```
The adminer is listening 8080 port which is not exposed to the public address, use ssh tunneling to reach it. Once the reverse proxy is up and running, you can finally start blog containers:
```bash
$ cd ../../ghost
$ docker-compose up -d
$ cd ../wordpress
$ docker-compose up -d
```
In the `ghost` and `wordpress` folders, there is `.env` file with environment variables such as `DOMAIN_NAME`, `ADMIN_EMAIL`, etc. Update it with your values before starting a blog service.

## Backup

The `cron` container, which image is defined in `cron/Dockerfile`, is responsible for periodical database backup using `mysqldump` utility. The backup is scheduled by cron to run every `@midnight` and `@weekly`.

