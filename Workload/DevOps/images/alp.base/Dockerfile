FROM quay.io/flysangel/library/alpine:3.20.2
RUN apk update && apk upgrade && \
    apk add --no-cache sudo curl bash git grep tzdata && \
    cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime

CMD ["/bin/sleep","infinity"]
