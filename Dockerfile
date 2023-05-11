# FROM alpine:3.16.0

# WORKDIR /app

# RUN set -xe;

# COPY . .

# RUN apk add --no-cache python3 py3-pip tini; \
#     pip install --upgrade pip setuptools-scm; \
#     python3 setup.py install; \
#     python3 martor_demo/manage.py makemigrations; \
#     python3 martor_demo/manage.py migrate; \
#     addgroup -g 1000 appuser; \
#     adduser -u 1000 -G appuser -D -h /app appuser; \
#     chown -R appuser:appuser /app

# USER appuser
# EXPOSE 8000/tcp
# ENTRYPOINT [ "tini", "--" ]
# CMD [ "python3", "/app/martor_demo/manage.py", "runserver", "0.0.0.0:8000" ]


FROM python:3.9-buster

# install nginx
RUN apt-get update && apt-get install nginx vim -y --no-install-recommends
COPY nginx.default /etc/nginx/sites-available/default
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# copy source and install dependencies
RUN mkdir -p /opt/app
RUN mkdir -p /opt/app/pip_cache
RUN mkdir -p /opt/app/martor_demo
COPY requirements.txt start-server.sh /opt/app/
COPY .pip_cache /opt/app/pip_cache/
COPY martor_demo /opt/app/martor_demo/
WORKDIR /opt/app
RUN pip install -r requirements.txt --cache-dir /opt/app/pip_cache
RUN chown -R www-data:www-data /opt/app

# start server
EXPOSE 8020
STOPSIGNAL SIGTERM
CMD ["/opt/app/start-server.sh"]