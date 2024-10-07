FROM node:20-bookworm-slim

ENV COUCHDB_PROTOCOL=http \
    COUCHDB_HOST=couchdb \
    COUCHDB_PORT=5984 \
    COUCHDB_USER=cozy \
    COUCHDB_PASSWORD=cozy

ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      gosu \
      git \
      imagemagick \
      ghostscript \
      librsvg2-bin \
      fonts-lato \
      postfix \
      jq \
    && postconf inet_interfaces=loopback-only \
    && postconf mydestination='$myhostname, localhost.localdomain, localhost' \
    && sed -ie 's,^  \(<policy domain="coder" rights="none" pattern="PDF" />\)$,  <!-- \1 -->,g' /etc/ImageMagick-6/policy.xml \
    && gosu nobody true \
    && apt-get autoremove -y && apt-get clean \
    && rm -rf /tmp/* /var/tmp /var/lib/apt/lists/* /var/cache/apt

RUN curl -L -o /usr/local/bin/cozy-stack https://github.com/cozy/cozy-stack/releases/download/1.6.29/cozy-stack-linux-arm64-1.6.29
RUN curl -L -o /usr/local/bin/docker-entrypoint.sh https://raw.githubusercontent.com/cozy/cozy-stack/refs/tags/1.6.29/scripts/docker/production/docker-entrypoint.sh
RUN curl -L -o /usr/local/bin/konnector-node-run.sh https://raw.githubusercontent.com/cozy/cozy-stack/refs/tags/1.6.29/scripts/docker/production/konnector-node-run.sh
RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/cozy/cozy-stack/refs/tags/1.6.29/scripts/docker/production/wait-for-it.sh

RUN chmod +x /usr/local/bin/*.sh
RUN chmod +x /usr/local/bin/cozy-stack

WORKDIR /var/lib/cozy

VOLUME /var/lib/cozy/data
VOLUME /etc/cozy

EXPOSE 6060 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["cozy-stack","serve"]
