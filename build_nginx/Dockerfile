FROM synocommunity/spksrc:latest
MAINTAINER SalmiRnD <https://salmi.com.se>

ENV NGINX_VERSION 1.18.0
ENV OPEN_SSL_VERSION 1_1_1h 
ENV NGINX_RTMP_MODULE_VERSION 1.2.1

COPY build_nginx.sh /

# Volume pointing to spksrc sources
VOLUME /spksrc

WORKDIR /spksrc

ENTRYPOINT ["/build_nginx.sh"]
