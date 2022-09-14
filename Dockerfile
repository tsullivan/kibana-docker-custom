FROM ubuntu:22.04

ARG ARTIFACT
ENV KBN_ELASTICSEARCH_HOST http://host.docker.internal:9200
ENV KBN_ELASTICSEARCH_USERNAME kibana_system
ENV KBN_ELASTICSEARCH_PASSWORD changeme
ENV KBN_ENCRYPTION_KEY totalencryptionkey3923J-FTEu-dfyWJ0

RUN for iter in {1..10}; do \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update  && \
    apt-get upgrade -y  && \
    apt-get install -y --no-install-recommends \
     fontconfig fonts-liberation libnss3 libfontconfig1 ca-certificates curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && exit_code=0 && break || exit_code=$? && echo "apt-get error: retry $iter in 10s" && \
    sleep 10; \
  done; \
  (exit $exit_code)

RUN mkdir /usr/share/fonts/local
RUN curl --retry 8 -S -L -o /usr/share/fonts/local/NotoSansCJK-Regular.ttc https://github.com/googlefonts/noto-cjk/raw/NotoSansV2.001/NotoSansCJK-Regular.ttc
RUN echo "5dcd1c336cc9344cb77c03a0cd8982ca8a7dc97d620fd6c9c434e02dcb1ceeb3  /usr/share/fonts/local/NotoSansCJK-Regular.ttc" | sha256sum -c -
RUN fc-cache -v

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
