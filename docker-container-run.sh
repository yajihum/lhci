docker container run --publish 9001:9001 \
--mount='source=lhci-data,target=/data' \
--env-file .env \
--detach \
lhci