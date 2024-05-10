FROM 172.22.1.11:5000/alp.base:24.01 AS build
WORKDIR /workspace
COPY . /workspace/
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o goweb ./src

FROM 172.22.1.11:5000/alp.base:24.01
RUN mkdir -p /opt/www && mkdir /opt/web
COPY --from=build /workspace/goweb /workspace/src/web /opt/web/
COPY --from=build /workspace/src/web /opt/www
CMD ["/opt/web/goweb"]
