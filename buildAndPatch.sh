# Temp dir for the nginx build
mkdir /tmp/spksrc
# Create dir for user settings: reverse proxy,
# theese copied to app.d when creating a reverse proxy.
mkdir /etc/nginx/reverseproxy/
# link our libpcreso ssl works.
ln -s /usr/lib/libpcre.so /usr/lib/libpcre.so.3
# take owenrship of dir as http.
chown http:http /etc/nginx/scgi_temp

# Build nginx
docker run -it --rm \
  --name build_nginx1 \
  -v /tmp/spksrc:/spksrc \
  build_nginx:v1.0

# Patch our nginx
docker run -it --rm \
  --name patch_synology1 \
  -v /tmp/spksrc:/spksrc \
  -v /usr/syno/etc.defaults/rc.sysv:/rc.sysv \
  -v /usr/syno/share/nginx:/mustache \
  -v /usr/bin:/host/bin \
  -v /etc/nginx:/etc_nginx \
  patch_synology:v1.0
