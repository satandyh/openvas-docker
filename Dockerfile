FROM centos:latest
MAINTAINER Support <satandyh@github.com>

ENV DEBIAN_FRONTEND=noninteractive \
  OV_PASSWORD=admin \
  PUBLIC_HOSTNAME=openvas

RUN yum clean all && \
  yum -y update && \
  yum -y install wget \
    net-tools && \
    alien \
    bzip2 \
    useradd \
    openssh && \
## textlive not necessary part because docker container will be used as only scanner and here no need to store any reports
#  yum -y install texlive-collection-fontsrecommended \
#    texlive-collection-latexrecommended \
#    texlive-changepage \
#    texlive-titlesec && \
#  mkdir -p /usr/share/texlive/texmf-local/tex/latex/comment && \
#  wget -q --no-check-certificate http://mirrors.ctan.org/macros/latex/contrib/comment/comment.sty -P /usr/share/texlive/texmf-local/tex/latex/comment && \
#  chmod 644 /usr/share/texlive/texmf-local/tex/latex/comment/comment.sty && \
#  texhash && \
  cd /root; NON_INT=1 wget -q -O - https://updates.atomicorp.com/installers/atomic |sh && \ 
  yum -y install openvas OSPd-nmap OSPd
  /usr/sbin/greenbone-nvt-sync && \
  /usr/sbin/greenbone-certdata-sync && \
  /usr/sbin/greenbone-scapdata-sync && \
  /usr/sbin/openvasmd --rebuild --progress


COPY config/redis.conf /etc/redis.conf
COPY config/gsad /etc/sysconfig/gsad
COPY config/opevas-manager /etc/sysconfig/openvas-manager



EXPOSE 443 9390
