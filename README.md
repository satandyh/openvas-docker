> Beware - I still not test this repo. It may even not start!

# openvas-docker
This is dockerfile and several configs for build and run openvas as slave in docker container.

Slave openvas installation is a part of distributed architecture that used for scan only. One or more openvas master servers may connects to it and give commands for scan (need to create omp scanner).

|Openvas Version|Tag|Web UI Port|
|:--|:--|:--|
|9|latest|443|

Based on CentOS:latest image.

### build
Firstly build image. For do this clone repository by `git clone` and go inside repository directory. Run next command to build image. This will create local image tagged **satandyh/openvas** (or you can choose your name).

```shell
docker build -t satandyh/openvas .
```

### run
First, look which ip address (by command `ip --brief address`) You will use to connect to your container. It will be used as for master server connection and for web access to itself.

Use next command to run container.

```shell
docker run -d -p 443:<WEB_PORT> -p 9390:<OMP_PORT> -e PUBLIC_HOSTNAME=<YOUR_SERVER_IP> -e OV_PASSWORD=<YOUR_PASSWORD> --name openvas satandyh/openvas
```

After some time container will up and You can connect to it thru the browser using URL **https://YOUR_SERVER_IP:WEB_PORT/**. Login will be **admin**. Password You choose by yourself otherwise it will be **admin**.

### to make connection to the master server

1. Go inside container by command
```shell
docker exec -it openvas bash
```

2. Look certificate of openvas (it was generated at installation step).
```shell
cat /var/lib/openvas/private/CA/cacert.pem
```

3. Copy certificate to file with name **cacert.pem** on your local computer.

4. Go to Web-UI of master openvas server and add new "Credentials". For username and password use admin and <YOUR_PASSWORD>
- **Name** - whatever you want
- **Type** - username + password
- **Allow insecure use** - no
- **Auto-generate** - no

5. Go to Web-UI of master openvas server and add new "Scanner". 
- **Name** - whatever you want
- **Host** - <YOUR_SERVER_IP>
- **Port** - <OMP_PORT>
- **Type** - OMP Slave
- **CA Certificate** - download cacert.pem file
- **Credential** - choose your just created credentials

# The parts I was inspired to create this repo:

- https://github.com/mikesplain/openvas-docker
- https://www.linuxincluded.com/installing-openvas-on-centos-7/
- http://lists.wald.intevation.org/pipermail/openvas-discuss/2016-June/009701.html
- https://sysadmin-ramblings.blogspot.com/2017/04/openvas-9-distributed-setup.html
- https://github.com/atomicorp/openvas
- https://github.com/dgiorgio/openvas-source

