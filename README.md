# openvas-docker
This is dockerfile and several configs for run openvas as slave in docker container.

Slave openvas installation is a part of distributed architecture that used for scan only. One or more master openvas servers may connects to it and give commands for scan (as omp scanner).

# steps inside

1. use CentOS as base image
2. install openvas and necessary dependensies
3. copy configs for openvas components  
  3.1 redis  
  3.2 openvas-manager  
  3.3 gsad  
  3.4 crontab
4. copy CA to volume on host machine

# some description for install and connect master part



# The parts I was inspired to create my configs:

- https://github.com/mikesplain/openvas-docker
- https://www.linuxincluded.com/installing-openvas-on-centos-7/
- http://lists.wald.intevation.org/pipermail/openvas-discuss/2016-June/009701.html
- https://sysadmin-ramblings.blogspot.com/2017/04/openvas-9-distributed-setup.html
- https://github.com/atomicorp/openvas
