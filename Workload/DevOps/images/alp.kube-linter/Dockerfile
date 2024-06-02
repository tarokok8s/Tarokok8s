ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.task:${FROM_VER}
RUN curl -sSL -o kube-linter "https://github.com/stackrox/kube-linter/releases/download/v0.6.8/kube-linter-linux" && \
    sudo install -m 555 kube-linter "/usr/local/bin/kube-linter"

CMD ["/bin/sleep","infinity"]
