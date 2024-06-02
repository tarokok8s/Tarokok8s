ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.task:${FROM_VER}
RUN apk update && apk upgrade && \
    apk add kubectl --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted

CMD ["/bin/sleep","infinity"]
