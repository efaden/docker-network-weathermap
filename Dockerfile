# == Network Weathmap
#

# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.22

MAINTAINER Eric Faden <efaden@gmail.com>

EXPOSE 8338

ENV DEBIAN_FRONTEND="noninteractive" 

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install CollectD
RUN apt-get -y update && apt-get -y install \
      git \
      wget \
      nginx \
      php-cli \
      php-gd \
      php-json \
      php-snmp \
      php-pear \
      php-fpm \
      unzip \
      rrdtool \
	&& rm -rf /var/lib/apt/lists/*

# Add CollectD Service
RUN mkdir /etc/service/nginx
COPY nginx.sh /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

COPY network-weathermap /etc/nginx/sites-available/
COPY map-poller.php /var/www/

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME /config
