FROM  fluentd-hec:1.0

RUN   apt-get update -y && \ 
      apt-get install -y gnupg && \
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 901F9177AB97ACBE  && \
      apt-get update -y && \ 
      apt-get install -y python python-pip curl sudo software-properties-common  && \
      curl -L https://toolbelt.treasuredata.com/sh/install-debian-stretch-td-agent2.sh | sh
