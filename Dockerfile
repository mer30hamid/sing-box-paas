FROM nginx:alpine-slim
LABEL slim nginx
EXPOSE 80
USER root
COPY entrypoint.sh /
COPY config.template.json /config.template.json
COPY nginx.template.conf /
RUN mkdir -p /usr/share/nginx/html && \
    apk update && \
    apk add curl wget bash --no-cache && \
    echo "include /tmp/nginx/conf.d/*.conf;" > /etc/nginx/conf.d/default.conf && \
    chmod a+x ./entrypoint.sh
COPY index.html /usr/share/nginx/html/

# ENTRYPOINT ["/bin/sh", "-c" , "mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp && nginx && ./$XPID run -c config.json && cat log"]
# ENTRYPOINT ["/bin/sh", "-c" , "mkdir -p /tmp/nginx/client_temp /tmp/cache/nginx /tmp/nginx/fastcgi_cache /tmp/nginx/fastcgi_temp /tmp/cache/nginx/uwsgi_temp /tmp/cache/nginx/scgi_temp /tmp/nginx/scgi_temp && ping 8.8.8.8"]
# ENTRYPOINT ["/bin/sh", "-c" , "ping 8.8.8.8"]
ENTRYPOINT [ "./entrypoint.sh" ]