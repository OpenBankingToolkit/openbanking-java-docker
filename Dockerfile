# Pin to hub.docker.com/layers/openjdk/library/openjdk/11-jre-slim
FROM openjdk@sha256:1623b24fe088e0aefcfe499da1b8d72f108e16dd906ffdfff570736bfbbb1473

RUN apt update && apt install -y curl && \
 mkdir -p /opt/ob && addgroup --system --gid 1000 ob  && \
 mkdir -p /opt/ob/configvol && touch /opt/ob/configvol/bootstrap.properties && \
 ln -s /opt/ob/configvol/bootstrap.properties /opt/ob/bootstrap.properties && \
 adduser --system --uid 1000 --group ob --home /opt/ob --shell /sbin/nologin && \
 mkdir -p /opt/ob/config && \
 mkdir -p /etc/ssl/certs/java/ && \
 mv /usr/local/openjdk-11/lib/security/cacerts /etc/ssl/certs/java/cacerts && \
 ln -s /etc/ssl/certs/java/cacerts /usr/local/openjdk-11/lib/security/cacerts


ADD sbootwait.sh /opt/ob
