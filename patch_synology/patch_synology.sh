#!/bin/sh

if [ ! -f /host/bin/nginx.bak ]; then
  if [ -f /spksrc/nginx ]; then
    echo "Creating backup"
    mv /host/bin/nginx /host/bin/nginx.bak
    cp /mustache/nginx.mustache /mustache/nginx._ustache.bak
    cp /mustache/Portal.mustache /mustache/Portal._ustache.bak
    cp /rc.sysv/nginx-conf-generator.sh /rc.sysv/nginx-conf-generator.bak

    echo "Patch nginx.mustache"
    # Search for server_tag take the result line 's' and strip 4 chars at beginning insert '    #' at beginning and do not create a backup
    sed -i -re '/server_tag/s/^.{4}/    #/' /mustache/nginx.mustache

    echo "Patch nginx-conf-generator.sh"
    # Search for "server.ReverseProxy.conf" || true/r ./patch_reverse_proxy" and append file 'patch_reverse_proxy' to it.
    sed -i '/server.ReverseProxy.conf" || true/r ./patch_reverse_proxy' /rc.sysv/nginx-conf-generator.sh

    echo "Patch Portal.mustache"
    sed -i '/{{\/advanced}}/r ./patch_portal_mustache_1' /mustache/Portal.mustache
    sed -i '/{{\/letsencrypt}}/r ./patch_portal_mustache_2' ./mustache/Portal.mustache

    echo "Patch nginx"
    cp /spksrc/nginx /host/bin/nginx
  else
    echo "Missing a nginx to deploy, run nginx_build first, do not apply patch!"
  fi
else
  echo "Backup already exist, do not apply patch!"
fi
