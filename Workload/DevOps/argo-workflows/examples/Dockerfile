FROM dkreg.kube-system:5000/alp.base:1.0.0-cicd
RUN mkdir -p /opt/www && mkdir /opt/web
COPY goweb src/web /opt/web/
COPY src/web /opt/www
CMD ["/opt/web/goweb"]
