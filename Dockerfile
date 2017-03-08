FROM python:2.7-alpine

MAINTAINER Ayham Alzoubi "ayham.alzoubi@namshi.com"

RUN pip install awscli

RUN apk update
RUN apk add rsync

COPY . /src
WORKDIR /src

USER root

CMD ["sh","/src/run.sh"]
