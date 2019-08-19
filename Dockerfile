FROM alpine:latest
RUN apk update
RUN apk --no-cache add ca-certificates wget
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk
RUN apk add --no-cache glibc-2.30-r0.apk libaio glibc
COPY instantclient/*.zip .
RUN unzip instantclient-basiclite-linux.x64-*.zip
RUN mv instantclient_*_*/* /usr/lib/
ENV LD_LIBRARY_PATH /usr/lib
