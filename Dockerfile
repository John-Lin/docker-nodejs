FROM ubuntu:15.10
# FROM ubuntu:14.04.3

MAINTAINER John Lin <linton.tw@gmail.com>

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Dev Tool
RUN apt-get update && \
    apt-get install -qy --no-install-recommends git vim unzip wget curl tcpdump build-essential gcc g++ python-setuptools openssh-server ca-certificates

# Nodejs 5.1 with NVM
# ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 5.1

RUN git clone https://github.com/creationix/nvm.git ~/.nvm && cd ~/.nvm && git checkout `git describe --abbrev=0 --tags` && \
    . ~/.nvm/nvm.sh && \
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> /root/.bashrc && \
    echo "[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"" >> /root/.bashrc && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default

# SSH configure
RUN mkdir /var/run/sshd

RUN echo 'root:ec2@hsnl' |chpasswd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD    ["/usr/sbin/sshd", "-D"]
