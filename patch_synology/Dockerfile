FROM alpine:3.6
MAINTAINER SalmiRnD <https://salmi.com.se>

COPY \
  patch_reverse_proxy \
  patch_portal_mustache_1 \
  patch_portal_mustache_2 \
  patch_synology.sh /


# "/spksrc", Should point to same folder that you pointed to in nginx_build/Dockerfile
# "/rc.sysv", Should pont to /usr/syno/etc.defaults/rc.sysv/ on host
# "/mustache", Should point to /usr/syno/share/nginx/ on host
# "/host/bin", Should point to /usr/bin/ on host
# "/etc_nginx", Should point to /etc/nginx/ on host
VOLUME ["/spksrc", "/rc.sysv", "/mustache", "/host/bin", "/etc_nginx"]

ENTRYPOINT ["/patch_synology.sh"]

