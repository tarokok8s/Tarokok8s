ARG VER=0.0
FROM alpine:${VER}
COPY mc rclone kube-linter /usr/bin/

RUN apk update && apk upgrade && apk add --no-cache nano sudo wget curl python3 py3-pip mysql-client git \ 
    openssh-client-default nfs-utils go sshpass tree elinks bash shadow procps bind-tools util-linux coreutils \
    binutils findutils grep libcap jq zip unzip fuse shellcheck && \

    # install s3fs-fuse
    apk add s3fs-fuse --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted && \
    apk add mailcap --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/main/ --allow-untrusted && \
    echo 'user_allow_other' >> /etc/fuse.conf

RUN wget https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -O /usr/bin/hadolint && \
    chmod +x /usr/bin/hadolint

CMD ["/bin/sleep","infinity"]
