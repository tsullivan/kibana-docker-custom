## Build
```
 docker build --build-arg ARTIFACT=build/kibana-8.5.0-SNAPSHOT-linux-aarch64.tar.gz -t kibana-aarch:8.5.0 .
```

## Run
```
 docker run -it -p 127.0.0.1:5777:5601 --rm --env KBN_ELASTICSEARCH_HOST=http://host.docker.internal:9200 kibana-aarch:8.5.0
```
