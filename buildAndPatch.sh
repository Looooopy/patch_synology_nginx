mkdir /tmp/spksrc

ln -s /usr/lib/libpcre.so /usr/lib/libpcre.so.3
#chown http:http /etc/nginx/scgi_temp

docker run -it --rm \
  --name build_nginx1 \
  -v /tmp/spksrc:/spksrc \
  build_nginx:v1.0

docker run -it --rm \
  --name patch_synology1 \
  -v /tmp/spksrc:/spksrc \
  -v /usr/syno/etc.defaults/rc.sysv:/rc.sysv \
  -v /usr/syno/share/nginx:/mustache \
  -v /usr/bin:/host/bin \
  -v /etc/nginx:/etc_nginx \
  patch_synology:v1.0
