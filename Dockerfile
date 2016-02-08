# vim:set ft=dockerfile:
FROM buildpack-deps:jessie-curl

EXPOSE 5432

RUN groupadd -r pgbouncer && useradd -r -g pgbouncer pgbouncer

ENV PGBOUNCER_VERSION 1.5.4
ENV PGBOUNCER_TAR_URL https://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz
ENV PGBOUNCER_SHA_URL ${PGBOUNCER_TAR_URL}.sha256

# Install build dependencies
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential libevent-dev ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# Get PgBouncer source code
RUN curl -SLO ${PGBOUNCER_TAR_URL} \
  && curl -SLO ${PGBOUNCER_SHA_URL} \
  && cat pgbouncer-${PGBOUNCER_VERSION}.tar.gz.sha256 | sha256sum -c - \
  && tar -xzf pgbouncer-${PGBOUNCER_VERSION}.tar.gz \
  && chown root:root pgbouncer-${PGBOUNCER_VERSION}

# Configure, make, and install
RUN cd pgbouncer-${PGBOUNCER_VERSION} \
  && ./configure --prefix=/usr/local --with-libevent=libevent-prefix \
  && make \
  && make install

ADD pgbouncer.ini pgbouncer.ini

CMD pgbouncer pgbouncer.ini

