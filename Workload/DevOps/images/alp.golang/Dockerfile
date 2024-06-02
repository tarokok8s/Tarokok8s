ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.task:${FROM_VER}
COPY --from=quay.io/flysangel/library/golang:1.22.1-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

CMD ["/bin/sleep","infinity"]
