ARG FROM_VER=1.0.0-cicd
FROM 172.22.1.11:5000/alp.task:${FROM_VER}
RUN wget https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 -O /usr/bin/hadolint && \
    chmod +x /usr/bin/hadolint

CMD ["/bin/sleep","infinity"]
