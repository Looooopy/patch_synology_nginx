# remove old nginx build dir
[[ -d /tmp/spksrc ]] && rm -r /tmp/spksrc
# Temp dir for the nginx build
mkdir /tmp/spksrc
# Create dir for user settings: reverse proxy,
# theese copied to app.d when creating a reverse proxy
[[ ! -d /etc/nginx/reverseproxy/ ]] && mkdir /etc/nginx/reverseproxy/

# link our libpcreso ssl works.
[[ ! -e /usr/lib/libpcre.so.3 ]] && ln -s /usr/lib/libpcre.so /usr/lib/libpcre.so.3

# create scgi_temp
[[ ! -d directory ]] && mkdir /etc/nginx/scgi_temp

# take owenrship of dir as http.
[[ -d /etc/nginx/scgi_temp/ ]] && chown http:http /etc/nginx/scgi_temp

# Build nginx
docker run -it --rm \
  --name build_nginx1 \
  -v /tmp/spksrc:/spksrc \
  -e NGINX_VERSION='1.18.0' \
  -e OPEN_SSL_VERSION='1_1_1h' \
  -e NGINX_RTMP_MODULE_VERSION='1.2.1' \
  salmirnd/build_nginx:v1.0

# Patch our nginx
 docker run -it --rm \
   --name patch_synology1 \
   -v /tmp/spksrc:/spksrc \
   -v /usr/syno/etc.defaults/rc.sysv:/rc.sysv \
   -v /usr/syno/share/nginx:/mustache \
   -v /usr/bin:/host/bin \
   -v /etc/nginx:/etc_nginx \
   salmirnd/patch_synology:v1.0
  
 echo "restart nginx"
 synoservicecfg --restart nginx
