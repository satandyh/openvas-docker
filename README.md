# openvas-docker
This is an image for run openvas as slave in docker.

# steps inside

1. use CentOS as base image
2. install openvas and necessary dependensies
3. copy configs for openvas components
3.1 redis
3.2 openvas-scanner
3.3 openvas-manager
3.4 crontab
4. copy CA to volume

* * *
The parts I was inspired to create my configs:

- https://github.com/mikesplain/openvas-docker
- https://www.linuxincluded.com/installing-openvas-on-centos-7/
- http://lists.wald.intevation.org/pipermail/openvas-discuss/2016-June/009701.html
- https://sysadmin-ramblings.blogspot.com/2017/04/openvas-9-distributed-setup.html


