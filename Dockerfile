FROM centos:latest
LABEL maintainer="satandyh@github.com"

ENV OV_PASSWORD=admin \
  PUBLIC_HOSTNAME=openvas

## install necessary packages
RUN yum -y update && yum -y install \
    wget \
    net-tools \
    alien \
    bzip2 \
    useradd \
    openssh \
  && rm -rf /var/cache/yum/*

## textlive not necessary part because docker container will be used as only scanner and here no need to store any reports
#RUN yum -y install texlive-collection-fontsrecommended \
#    texlive-collection-latexrecommended \
#    texlive-changepage \
#    texlive-titlesec \
#  && mkdir -p /usr/share/texlive/texmf-local/tex/latex/comment \
#  && wget -q --no-check-certificate http://mirrors.ctan.org/macros/latex/contrib/comment/comment.sty -P /usr/share/texlive/texmf-local/tex/latex/comment \
#  && chmod 644 /usr/share/texlive/texmf-local/tex/latex/comment/comment.sty \
#  texhash

## first add atomicorp repo
## then install openvas
## and update it's bases
WORKDIR /root
RUN NON_INT=1 wget -q -O - https://updates.atomicorp.com/installers/atomic |sh \
  && yum -y update && yum -y install openvas OSPd-nmap OSPd \
  && rm -rf /var/cache/yum/*
  && /usr/sbin/greenbone-nvt-sync \
  && /usr/sbin/greenbone-certdata-sync \
  && /usr/sbin/greenbone-scapdata-sync \
  && /usr/sbin/openvasmd --rebuild --progress

## copy config files to their places
COPY config/redis.conf /etc/redis.conf
COPY config/gsad /etc/sysconfig/gsad
COPY config/opevas-manager /etc/sysconfig/openvas-manager
## crontab tasks for every night update
COPY config/openvas-cron /etc/cron.d/openvas.cron
## Apply cron job
RUN crontab /etc/cron.d/openvas.cron

## need to add hostname for start 
## and CA config 

CMD /run.sh

EXPOSE 443 9390
