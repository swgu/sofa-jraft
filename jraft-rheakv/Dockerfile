FROM centos:centos7
LABEL maintainer="Ant Financial Open Source"

ENV JAVA_HOME /usr/lib/jvm/java-11
RUN \
    set -xeu && \
    yum -y update && \
    yum -y install java-11-openjdk-devel less && \
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /tmp/* /var/tmp/*

ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG RHEAKV_VERSION

WORKDIR /usr/local/rheakv

COPY rheakv-server/target/jraft-rheakv-server-${RHEAKV_VERSION}/ .

ENV SERVER_PORT=18181
EVN PD_PORT=18182

EXPOSE ${SERVER_PORT}
EXPOSE ${PD_PORT}

ENV RHEAKV_USER rheakv
ENV USER rheakv:rheakv

RUN \
    useradd $RHEAKV_USER && \
    [ `id -u $RHEAKV_USER` -eq 1000 ] && \
    [ `id -g $RHEAKV_USER` -eq 1000 ] && \
    chown -R "$RHEAKV_USER:$RHEAKV_USER" /usr/local/rheakv

CMD ["/usr/local/rheakv/bin/rheakv.sh", "start-foreground"]
