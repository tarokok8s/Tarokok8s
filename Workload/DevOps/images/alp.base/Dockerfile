FROM quay.io/flysangel/alpine:3.19.1
RUN apk update && apk upgrade && \
    apk add --no-cache sudo curl bash git grep tzdata && \
    cp /usr/share/zoneinfo/Asia/Taipei /etc/localtime

CMD ["/bin/sleep","infinity"]
