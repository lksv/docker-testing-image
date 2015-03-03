# cip
#
#VERSION 0.0.1

FROM ubuntu:14.04
MAINTAINER Lukas Svoboda "lukas.svoboda@gmail.com"

RUN export DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND noninteractive
RUN dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get update -qq && apt-get upgrade -y

RUN apt-get install -y --force-yes \
    autoconf \
    bind9-host \
    bison \
    build-essential \
    coreutils \
    ca-certificates \
    curl \
    daemontools \
    dnsutils \
    ed \
    git \
    imagemagick \
    iputils-tracepath \
    language-pack-en \
    libbz2-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libmagickwand-dev \
    libmysqlclient-dev \
    libncurses5-dev \
    libpq-dev \
    libpq5 \
    libreadline6-dev \
    libssl-dev \
    libxml2-dev \
    libxslt-dev \
    netcat-openbsd \
    openjdk-7-jdk \
    openjdk-7-jre-headless \
    openssh-client \
    openssh-server \
    postgresql-server-dev-9.3 \
    python \
    python-dev \
    ruby \
    ruby-dev \
    socat \
    syslinux \
    tar \
    telnet \
    zip \
    zlib1g-dev \
    -

RUN mkdir /var/run/sshd
RUN sudo chmod -rx /var/run/sshd

RUN sudo chown root:root /etc/ssh/sshd_config

EXPOSE 22

RUN sudo sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


RUN useradd --shell /bin/sh --create-home vagrant -s /bin/bash
RUN echo 'vagrant:vagrant' | chpasswd
RUN sudo usermod -a -G sudo vagrant

ADD id_rsa.pub /home/vagrant/.ssh/authorized_keys
RUN chmod 700 /home/vagrant/.ssh && \
    chown vagrant.vagrant /home/vagrant/.ssh && \
    chmod 600 /home/vagrant/.ssh/authorized_keys && \
    chown vagrant.vagrant /home/vagrant/.ssh/authorized_keys

RUN echo 'vagrant  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

CMD ["/usr/sbin/sshd", "-D"]

#ADD start.sh /start.sh
#RUN chmod 0755 /start.sh
#CMD /start.sh
