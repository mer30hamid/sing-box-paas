FROM nginx:latest
LABEL just for liara
EXPOSE 80
USER root
COPY entrypoint.sh ./
ARG LIARA_ACCESS_KEY=$LIARA_ACCESS_KEY
ENV LIARA_ACCESS_KEY=$LIARA_ACCESS_KEY
ARG LIARA_SECRET_ACCESS_KEY=$LIARA_ACCESS_KEY
ENV LIARA_SECRET_ACCESS_KEY=$LIARA_SECRET_ACCESS_KEY
ARG S3_MOUNT_DIRECTORY=/mnt/s3_bucket
ENV S3_MOUNT_DIRECTORY=$S3_MOUNT_DIRECTORY
ARG S3_BUCKET_NAME=$S3_BUCKET_NAME 
ENV S3_BUCKET_NAME=$S3_BUCKET_NAME
RUN apt-get update -y && \
    apt install -y s3fs wget && \
    echo $LIARA_ACCESS_KEY:$LIARA_SECRET_ACCESS_KEY > /root/.passwd-s3fs && \
    chmod 600 /root/.passwd-s3fs && \
    mkdir $S3_MOUNT_DIRECTORY && \
    echo "$S3_BUCKET_NAME $S3_MOUNT_DIRECTORY fuse.s3fs _netdev,allow_other,use_path_request_style,url=https://storage.iran.liara.space 0 0" > etc/fstab && \
    mkdir -p /usr/share/nginx/html && \
    adduser -u 82 -D -S -G www-data www-data && \
    chown -R www-data.www-data /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    rm -rf /var/nginx/conf.d && \
    chmod a+x ./entrypoint.sh
WORKDIR $S3_MOUNT_DIRECTORY
ENV UUID ea4909ef-7ca6-4b46-bf2e-6c07896ef338
# ENV VER 1.3-beta11
COPY nginx.template.conf /etc/nginx/nginx.template.conf
COPY config.template.json ./
COPY index.html /usr/share/nginx/html/
ENTRYPOINT [ "./entrypoint.sh" ]
