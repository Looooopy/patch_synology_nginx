# Build and deploy nginx on Synology NAS
- We made two docker containers that will patch our Synology NAS with a nginx version we desire.
- ~~We have also created a container for handling backups of old versions of the nginx.~~ NOT IMPLEMENTED.
- Ability to extend root path add locations paths for our reverse proxy and still be able to use the standard GUI.

This solution:
- Will in extent make it possible to use [OAuth2 Proxy](https://github.com/bitly/oauth2_proxy) with our NAS.
- Will support [Real-Time Messaging Protocol](https://github.com/arut/nginx-rtmp-module) (RTMP, Media Streaming Server)
- Patching was tested on a DS1813+ with nginx 1.21.1 and 1.33, 1.15.7 using same ssl that where used in my Synology version 1.0.2l, 1.0.2n, 1.0.2r.

## Run on synology nas
- sign in through ssh
- sudo su
- [optionally] create root-[reverse-proxy-address].conf and locations-[reverse-proxy-address].conf files in folder /etc/nginx/reverseproxy/
- run ./buildAndPatch.sh
- wait for build and patch to complete
    - Fetch the images will take sometime 2 GB to get build chain and 40MB for patch image.
    - The build process of nginx can take up to 10-15 minutes.
    - The patch process goes fast.
- Test change the reverse proxy name or by create a new one in GUI.
- Test by running "nginx -t" to see if the configuration is correct.

## Docker container: build_nginx
Main purpose is to build a new [nginx](https://www.nginx.com/) (default version: 1.15.7) where you define which version you will build and use.

**We include following modules:**
- http_gzip_static_module
- http_realip_module
- http_v2_module
- http_sub_module
- http_ssl_module (can define which version, default 1.0.2r)
- http_auth_request_module
- nginx-rtmp-module (can define which version, default 1.2.0)

### Enviroment variables:
    NGINX_VERSION             1.15.7
    OPEN_SSL_VERSION          1_0_2r
    NGINX_RTMP_MODULE_VERSION 1.2.1


I specified the same [OpenSSL](https://github.com/openssl/openssl) version as the one matching my setup on my NAS before patching.
Have not tired newer version, so keep me posted if someone else tries.


### Volumes
    /spksrc   ==>     Map to an empty host directory, the new nginx will be placed inside.

### How to run
    cd ./build_nginx
    docker build -t salmirnd/build_nginx:v1.0 .
    docker run -it --rm --name build_nginx1 -v /tmp/spksrc:/spksrc build_nginx:v1.0

## Docker container: patch_synology
Main purpose is to patch the host Synology Nas with a new nginx that also have the ability to add custom http_proxy_auth and customize root path of a reverse proxy and also an eco system to add more location under the root path, this is done through the GUI.

### Configuration files
To extend nginx config for our reverse proxy settings you have to place config file named: **root-[reverse proxy source host name]** or **locations-[reverse proxy source host name]** inside of folder /etc/nginx/reverseproxy/ on your NAS.

To trigger the apply action of this configuration you need either change a reverse proxy setting or create a new one in the GUI.

e.g file "root-example.com")

    auth_request /oauth2/auth;
    error_page 401 = /oauth2/start;

    # pass information via X-User and X-Email headers to backend,
    # requires running with --set-xauthrequest flag
    auth_request_set $user   $upstream_http_x_auth_request_user;
    auth_request_set $email  $upstream_http_x_auth_request_email;
    proxy_set_header X-User  $user;
    proxy_set_header X-Email $email;

    auth_request_set $auth_cookie $upstream_http_set_cookie;
    add_header Set-Cookie $auth_cookie;
    
    # 20 minutes of timeout (Useful on SSE events so it do not timeout after 60 seconds)
    proxy_connect_timeout 1200;
    proxy_send_timeout 1200;
    proxy_read_timeout 1200;


e.g file "locations-example.com")

    location /oauth2/ {
        proxy_pass       http://127.0.0.1:4180;
        proxy_set_header Host                    $host;
        proxy_set_header X-Real-IP               $remote_addr;
        proxy_set_header X-Scheme                $scheme;
        proxy_set_header X-Auth-Request-Redirect $request_uri;
    }

    location /oauth2/callback {
        auth_request off;
        proxy_pass http://127.0.0.1:4180;
        proxy_set_header Host $host;
    }

    location /oauth2/start {
        proxy_pass http://127.0.0.1:4180;
        proxy_set_header Host $host;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
    }

    location /robots.txt {
        return 200;
    }

### Volumes

    /spksrc    ==>    Destination directory from byuild_nginx container, Action copy src of nginx.
    /rc.sysv   ==>    Host dir /usr/syno/etc.defaults/rc.sysv Action: backup and alter
    /mustache  ==>    Host dir /usr/syno/share/nginx, Action: backup and alter Portal.mustache and nginx.mustache
    /host/bin  ==>    Host dir /usr/bin, Action: backup and replace nginx.
    /etc_nginx ==>    Host dir /etc/nginx, Action: create dir: reverseproxy

### How to run
**Must run container build_nginx before using this container**

First run will produce backups on the same location there the real file exist.
If there already exist backups the execution will stop and not patch anything.

Backup names:
- nginx.bak
- nginx._ustache.bak
- Portal._ustache.bak
- nginx-conf-generator.bak


    cd ./patch_synology
    docker build -t salmirnd/patch_synology:v1.0 .

    docker run -it --rm \
      --name patch_synology1 \
      -v /tmp/spksrc:/spksrc \
      -v /usr/syno/etc.defaults/rc.sysv:/rc.sysv \
      -v /usr/syno/share/nginx:/mustache \
      -v /usr/bin:/host/bin \
      -v /etc/nginx:/etc_nginx \
      patch_synology:v1.0

#### How to do a test-run
**Must run container build_nginx before using this container**

    cd ./patch_synology
    docker build -t salmirnd/patch_synology:v1.0 -t salmirnd/patch_synology:latest .

    mkdir test-run
    cd test_run
    mkdir mustache
    mkdir rc.sysv
    mkdir bin
    mkdir etc_nginx
    cd ..
    cp /tmp/spksrc/nginx ./test-run/
    cp /usr/syno/share/nginx/Portal.mustache ./test-run/mustache/
    cp /usr/syno/share/nginx/nginx.mustache ./test-run/mustache/
    cp /usr/syno/etc.defaults/rc.sysv/nginx-conf-generator.sh ./test-run/rc.sysv/
    cp /usr/bin/nginx ./test-run/bin/

    docker run -it --rm \
      --name patch_synology1 \
      -v /volume1/docker/test-run:/spksrc \
      -v /volume1/docker/test-run/rc.sysv:/rc.sysv \
      -v /volume1/docker/test-run/mustache:/mustache \
      -v /volume1/docker/test-run/bin:/host/bin \
      -v /volume1/docker/test-run/etc_nginx:/etc_nginx \
      salmirnd/patch_synology:v1.0


## Docker container: manage_backups
!!!NOT IMPLEMENTED!!!

With this container you could either:
- revert backup
- purge backup
- backup your backups to a destination folder.
- revert from a source folder.

**purge should only be done if you really need to or you have made a backup to a destination folder.**

### Command
    purge               ==> purge the backup if it finds any backup
    revert              ==> revert the backup if it finds any backup
    backup_to_folder    ==> uses Environment variable DEST_FOLDER
    revert_from_folder  ==> uses Environment variable SRC_FOLDER

### Volumes
    /src       ==>    Host backup source folder
    /dest      ==>    Host backup destination folder
    /rc.sysv   ==>    Host dir /usr/syno/etc.defaults/rc.sysv/, Action: backup or revert nginx-conf-generator.sh
    /mustache  ==>    Host dir /usr/syno/share/nginx/, Action: backup or revert Portal.mustache and nginx.mustache
    /host/bin  ==>    Host dir /usr/bin, Action: backup or revert nginx.
    /etc_nginx ==>    Host dir /etc/nginx, Action: backup or revert dir: reverseproxy

### How to run

    docker build -t salmirnd/manage_backups:v1.0 .

#### How to do a test-run
