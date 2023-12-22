FROM nginx:latest
LABEL ifeng carmen mack-a ygkkk
EXPOSE 80
USER root
ENV UUID ea4909ef-7ca6-4b46-bf2e-6c07896ef338
# ENV VER 1.3-beta11
COPY nginx.template.conf /etc/nginx/nginx.template.conf
COPY config.template.json ./
RUN mkdir -p /usr/share/nginx/html; \
 adduser -u 82 -D -S -G www-data www-data; \
 chown -R www-data.www-data /usr/share/nginx/html; \
 chmod -R 755 /usr/share/nginx/html
COPY index.html /usr/share/nginx/html/
COPY entrypoint.sh ./
RUN chmod a+x ./entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
