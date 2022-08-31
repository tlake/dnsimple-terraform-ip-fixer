FROM arm32v7/alpine:latest

RUN apk add --no-cache bash curl jq

COPY entrypoint.bash /bin/
COPY sync-ip.bash /bin/

ENTRYPOINT ["/bin/entrypoint.bash"]
