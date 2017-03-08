FROM python:2.7-alpine

MAINTAINER Ayham Alzoubi "ayham.alzoubi@namshi.com"

RUN pip install awscli && apk update && apk add rsync && rm -rf /var/cache/apk/*

COPY . /src
WORKDIR /src

USER root

CMD ["sh","/src/run.sh"]
