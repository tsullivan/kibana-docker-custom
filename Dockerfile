FROM ubuntu:22.04

ARG ARTIFACT
ENV ELASTICSEARCH_HOSTS http://host.docker.internal:9200
ENV ELASTICSEARCH_USERNAME kibana_system
ENV ELASTICSEARCH_PASSWORD changeme
ENV XPACK_SECURITY_ENCRYPTIONkEY totalencryptionkey3923J-FTEu-dfyWJ0
ENV XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY totalencryptionkey3923J-_TEu-dfyWJ0
ENV XPACK_REPORTING_ENCRYPTIONKEY totalencryptionkey3923J-_TEu-dfyWJ0


RUN for iter in {1..10}; do \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update  && \
    apt-get upgrade -y  && \
    apt-get install -y --no-install-recommends \
     libnss3 ca-certificates curl vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && exit_code=0 && break || exit_code=$? && echo "apt-get error: retry $iter in 10s" && \
    sleep 10; \
  done; \
  (exit $exit_code)

RUN mkdir /usr/share/kibana
WORKDIR /usr/share/kibana

# Provide a non-root user to run the process.
RUN groupadd --gid 1011 kibana && \
    useradd --uid 1011 --gid 1011 -G 0 \
      --home-dir /usr/share/kibana --no-create-home \
      kibana

# Install the build
COPY ${ARTIFACT} /tmp/
RUN tar --strip-components=1 -zxf /tmp/$(basename ${ARTIFACT})
RUN chmod -R g=u /usr/share/kibana

# Set some Kibana configuration defaults.
COPY --chown=1011:0 config/kibana.yml /usr/share/kibana/config/kibana.yml

EXPOSE 5601
USER kibana
CMD "/bin/bash"
