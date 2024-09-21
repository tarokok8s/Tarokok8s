FROM quay.io/flysangel/library/alpine:3.20.2
COPY busybox1.35.0 /bin/
COPY info.cgi /
RUN \
  apk update && \
  apk add --no-cache nano sudo bash wget curl git tree grep && \
  chmod +x /bin/busybox1.35.0 info.cgi && \
  mkdir -p /opt/www/cgi-bin && \
  cp info.cgi /opt/www/cgi-bin/info  && \
  echo "let me go" > /opt/www/index.html

ENTRYPOINT ["/bin/busybox1.35.0"]
CMD ["httpd", "-f", "-h", "/opt/www"]
