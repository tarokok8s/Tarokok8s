ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.task:${FROM_VER}

# containers.conf  - The container engine (podman, buildah) configuration file specifies
# default configuration options and command-line flags for container engines.
COPY "containers.conf" "/etc/containers/"

RUN apk update && apk upgrade && \
    apk add --no-cache fuse-overlayfs podman

CMD ["/bin/sleep","infinity"]
