# openvas-docker

This is dockerfile and several configs for build and run openvas as slave in docker container.

Slave openvas installation is a part of distributed architecture that used for scan only. One or more openvas master servers may connects to it and give commands for scan (need to create omp scanner).

| Openvas Version | Tag    | Web UI Port |
| :-------------- | :----- | :---------- |
| 9               | latest | 443         |

Based on CentOS:latest image.

## build

Firstly create volume for store signature data.

```shell
docker volume create -d local \
  satandyh_openvas-data
```

Second build image. For do this clone repository by `git clone` and go inside repository directory. Run next command to build image. This will create local image tagged **satandyh/openvas** (or you can choose your name).

```shell
docker build -t satandyh/openvas .
```

## run

First, look which ip address (by command `ip --brief address`) You will use to connect to your container. It will be used as for master server connection and for web access to itself.

Use next command to run container.

```shell
docker run -d \
  -p <OMP_PORT>:9390 \
  -e OV_PASSWORD=<YOUR_PASSWORD> \
  -v satandyh_openvas-data:/var/lib/openvas \
  --name openvas satandyh/openvas
```

After some time container will up and You can connect to it thru the browser using URL **https://YOUR_SERVER_IP:WEB_PORT/**. Login will be **admin**. Password You choose by yourself otherwise it will be **admin**.

- **WEB_PORT** by default is 443
- **OMP_PORT** by default is 9390

## for security reasons better to use local ports

```shell
  ... \
  -p 127.0.0.1:<OMP_PORT>:9390 \
  -p 127.0.0.1:<WEB_PORT>:443 \
  ...
```

## to make connection to the master server

1. Go inside container by command

```shell
docker exec -it openvas bash
```

### 2. Look certificate of openvas (it was generated at installation step)

```shell
cat /var/lib/openvas/CA/cacert.pem
```

### 3. Copy certificate to file with name **cacert.pem** on your local computer

### 4. Go to Web-UI of master openvas server and add new "Credentials". For username and password use admin and <YOUR_PASSWORD>

- **Name** - whatever you want
- **Type** - username + password
- **Allow insecure use** - no
- **Auto-generate** - no

### 5. Go to Web-UI of master openvas server and add new "Scanner"

- **Name** - whatever you want
- **Host** - <YOUR_SERVER_IP>
- **Port** - <OMP_PORT>
- **Type** - OMP Slave
- **CA Certificate** - download cacert.pem file
- **Credential** - choose your just created credentials

## to sync signatures first time

### 1. Go inside container by command

```shell
docker exec -it openvas bash
```

### 2. run command

```shell
/usr/sbin/greenbone-nvt-sync && \
  /usr/sbin/greenbone-certdata-sync && \
  /usr/sbin/greenbone-scapdata-sync
  /usr/sbin/openvasmd --rebuild --progress
```

> it takes long time

# The parts I was inspired to create this repo

- [https://github.com/mikesplain/openvas-docker](https://github.com/mikesplain/openvas-docker)
- [https://www.linuxincluded.com/installing-openvas-on-centos-7/](https://www.linuxincluded.com/installing-openvas-on-centos-7/)
- [http://lists.wald.intevation.org/pipermail/openvas-discuss/2016-June/009701.html](http://lists.wald.intevation.org/pipermail/openvas-discuss/2016-June/009701.html)
- [https://sysadmin-ramblings.blogspot.com/2017/04/openvas-9-distributed-setup.html](https://sysadmin-ramblings.blogspot.com/2017/04/openvas-9-distributed-setup.html)
- [https://github.com/atomicorp/openvas](https://github.com/atomicorp/openvas)
- [https://github.com/dgiorgio/openvas-source](https://github.com/dgiorgio/openvas-source)
- [https://habr.com/ru/company/redmadrobot/blog/305364/](https://habr.com/ru/company/redmadrobot/blog/305364/)

# some thoughs to improve

- [https://github.com/falkowich/gvm10-docker/blob/master/psql/Dockerfile](https://github.com/falkowich/gvm10-docker/blob/master/psql/Dockerfile)
- [http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/](http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/)
- [https://wiki.alpinelinux.org/wiki/Setting_up_OpenVAS9](https://wiki.alpinelinux.org/wiki/Setting_up_OpenVAS9)
- [components](https://github.com/greenbone/gvm-libs/issues/197)

## немного того как это должно выглядеть

- используем разделение, т.е. выносим каждый компонент в отдельный контейнер, для этого будет использоваться docker-compose
- используем образ alpine linux как базовый
- в будущем используем образ postgres вместо стандрартной sqlite
