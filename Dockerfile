FROM centos:centos7.6.1810
LABEL maintainer="github.com\satandyh" \
  name="openvas-docker" \
  version="0.1" \
  release="1.0" \
  architecture="x86-64" \
  vendor="CentOS"

## install necessary packages
RUN yum -y update && yum -y install \
  wget \
  net-tools \
  alien \
  bzip2 \
  useradd \
  openssh \
  cronie \
  crontabs \
  cronie-anacron && \
  yum -y clean all

# textlive not necessary part because docker container will be used as only scanner
# and here no need to store any reports
RUN yum -y update && yum -y install \
  texlive-collection-fontsrecommended \
  texlive-collection-latexrecommended \
  texlive-changepage \
  texlive-titlesec && \
  yum -y clean all && \
  mkdir -p /usr/share/texlive/texmf-local/tex/latex/comment && \
  wget -q --no-check-certificate \
    http://mirrors.ctan.org/macros/latex/contrib/comment/comment.sty \
    -P /usr/share/texlive/texmf-local/tex/latex/comment && \
  chmod 644 /usr/share/texlive/texmf-local/tex/latex/comment/comment.sty && \
  texhash

## first add atomicorp repo
## then install openvas
## and update it's bases
WORKDIR /root
ENV NON_INT=1
RUN wget -q -O - https://updates.atomicorp.com/installers/atomic | sh && \
  yum -y update && yum -y install \
  openvas \
  OSPd-nmap \
  OSPd && \
  yum -y clean all
#RUN /usr/sbin/greenbone-nvt-sync && \
#  /usr/sbin/greenbone-certdata-sync && \
#  /usr/sbin/greenbone-scapdata-sync
#  /usr/sbin/openvasmd --rebuild --progress

## copy config files to their places
COPY config/redis.conf /etc/redis.conf
COPY config/gsad /etc/sysconfig/gsad
COPY config/openvas-manager /etc/sysconfig/openvas-manager
## copy crontab tasks for nightly update nvt update
COPY config/openvas-cron /etc/cron.d/openvas.cron
## Apply cron job and change some rights
RUN /usr/bin/crontab /etc/cron.d/openvas.cron
RUN sed -i -e 's/^\(session.*pam_loginuid.so\)$/#\1/' /etc/pam.d/crond

## rebuild CA config
RUN /usr/bin/openvas-manage-certs -a

## add entrypoint for crond
## this script only add vars to cron env
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

## start point
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
CMD ["/usr/local/bin/run.sh"]

EXPOSE 443 9390
