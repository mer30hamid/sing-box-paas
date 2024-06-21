FROM nginx:alpine-slim
LABEL just for liara
EXPOSE 80
USER root
COPY entrypoint.sh /
COPY config.template.json /config.template.json
COPY nginx.template.conf /

ENV VER 1.9.3
# XPID=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 8)
ENV XPID ksfhwke
RUN mkdir -p /usr/share/nginx/html && \
    # sed -i 's/dl-cdn.alpinelinux.org/mirrors.pardisco.co/g' /etc/apk/repositories && \
    apk update && \
    apk add curl wget bash --no-cache && \
    
    nx=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 4) && \
    wget -O $nx.tar.gz https://github.com/SagerNet/sing-box/releases/download/v${VER}/sing-box-${VER}-linux-amd64.tar.gz && \
    tar -xvf $nx.tar.gz && rm -f $nx.tar.gz && \
    chmod a+x sing-box-${VER}-linux-amd64/sing-box && mv sing-box-${VER}-linux-amd64/sing-box $XPID && \
    rm -rf sing-box-${VER}-linux-amd64 && \
    wget -N https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db && \
    wget -N https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db && \
    echo "include /tmp/nginx/conf.d/*.conf;" > /etc/nginx/conf.d/default.conf && \
    chmod a+x ./entrypoint.sh

COPY index.html /usr/share/nginx/html/

# ENTRYPOINT ["/bin/sh", "-c" , "mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp && nginx && ./$XPID run -c config.json && cat log"]
# ENTRYPOINT ["/bin/sh", "-c" , "mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp && ping 8.8.8.8"]
# ENTRYPOINT ["/bin/sh", "-c" , "ping 8.8.8.8"]
ENTRYPOINT [ "/entrypoint.sh" ]
