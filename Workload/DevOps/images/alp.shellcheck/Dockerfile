ARG FROM_VER=1.0.0-cicd
FROM dkreg.kube-system:5000/alp.task:${FROM_VER}
RUN apk update && apk upgrade && \
    apk add --no-cache shellcheck

CMD ["/bin/sleep","infinity"]
