FROM nginx:alpine-slim
LABEL slim nginx
EXPOSE 8080
USER root
COPY entrypoint.sh /
COPY config.template.json /config.template.json
COPY nginx.template.conf /
RUN mkdir -p /usr/share/nginx/html && \
    apk update && \
    apk add curl wget bash --no-cache && \
    chmod a+x ./entrypoint.sh
COPY index.html /usr/share/nginx/html/

# ENTRYPOINT ["/bin/sh", "-c" , "nginx && ./$XPID run -c config.json && cat log"]
# ENTRYPOINT ["/bin/sh", "-c" , "ping 8.8.8.8"]
ENTRYPOINT [ "./entrypoint.sh" ]