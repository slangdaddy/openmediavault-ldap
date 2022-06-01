FROM debian:bullseye-slim

RUN apt-get update \
	&& apt-get install -y dpkg-dev debhelper gettext \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
