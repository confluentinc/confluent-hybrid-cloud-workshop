FROM python:3-alpine
RUN apk add --no-cache mariadb-connector-c-dev ;\
    apk add --no-cache --virtual .build-deps \
    build-base \
    mariadb-dev ;\
    pip install --upgrade pip --user;\
    pip install mysqlclient;\
    apk del .build-deps 
COPY . /


