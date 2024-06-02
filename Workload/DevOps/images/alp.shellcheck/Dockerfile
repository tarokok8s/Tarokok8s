ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.task:${FROM_VER}
RUN apk update && apk upgrade && \
    apk add --no-cache shellcheck

CMD ["/bin/sleep","infinity"]
