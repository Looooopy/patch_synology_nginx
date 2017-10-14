#!/bin/bash

#NGINX_VERSION=$1
#NGINX_RTMP_MODULE_VERSION=$2
#OPEN_SSL_VERSION=$3
echo "nginx ${NGINX_VERSION} - Downloading and extracting"
wget -q "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
  tar -zxf "nginx-${NGINX_VERSION}.tar.gz" && \
  rm "nginx-${NGINX_VERSION}.tar.gz"

echo "nginx-rtmp-module ${NGINX_RTMP_MODULE_VERSION} - Downloading and extracting"
wget -q "https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.zip" && \
  unzip -q "v${NGINX_RTMP_MODULE_VERSION}.zip" && \
  rm "v${NGINX_RTMP_MODULE_VERSION}.zip" 

echo "OpenSSL ${OPEN_SSL_VERSION} - downloading and extracting"
wget -q "https://github.com/openssl/openssl/archive/OpenSSL_${OPEN_SSL_VERSION}.zip" && \
  unzip -q "OpenSSL_${OPEN_SSL_VERSION}.zip" && \
  rm "OpenSSL_${OPEN_SSL_VERSION}.zip"

echo "nginx - Configuring"
cd "/spksrc/nginx-${NGINX_VERSION}" && \
  ./configure \
    "--add-module=/spksrc/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}"  \
    --prefix=/etc/nginx \
    --user=http \
    --group=http \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-uwsgi-temp-path=/volume1/@tmp/nginx/uwsgi \
    --http-log-path=/var/log/nginx/access.log \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --lock-path=/var/lock/nginx_gen.lock \
    --pid-path=/var/run/nginx.pid \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_v2_module \
    --with-http_sub_module \
    "--with-openssl=/spksrc/openssl-OpenSSL_${OPEN_SSL_VERSION}" \
    --with-http_auth_request_module > /dev/null

echo "nginx - Building with modules"
make -s

echo "nginx - Move to /spksrc/nginx"
mv "/spksrc/nginx-${NGINX_VERSION}/objs/nginx" /spksrc/nginx > /dev/null

/spksrc/nginx -V 
