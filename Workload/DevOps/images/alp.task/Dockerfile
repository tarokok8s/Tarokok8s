ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.base:${FROM_VER}
RUN sh -c "$(curl -s --location https://taskfile.dev/install.sh)" -- -d -b /tmp &>/dev/null && \
    install -m 555 "/tmp/task" "/usr/local/bin/task" && rm /tmp/task

CMD ["/bin/sleep","infinity"]
