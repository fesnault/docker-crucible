FROM fesnault/atlassian-base:latest
MAINTAINER Frederic Esnault <esnault.frederic@gmail.com>

# Setup environment variables
ENV APPLICATION crucible
ENV VERSION 3.7.0

ADD scripts /scripts

# Install PostgreSQL client
RUN apt-get -y -qq install postgresql-client

# Download and unpack Application
RUN mkdir -p /opt/atlassian/crucible
ADD http://www.atlassian.com/software/crucible/downloads/binary/$APPLICATION-$VERSION.zip /opt/atlassian/crucible/archive.zip
RUN unzip -qq /opt/atlassian/crucible/archive.zip -d /opt/atlassian/crucible/
RUN ln -s /opt/atlassian/crucible/fecru-$VERSION /opt/atlassian/crucible/current
RUN rm -f /opt/atlassian/crucible/archive.zip

# Create crucible user
RUN /usr/sbin/useradd --create-home --home-dir /home/crucible --shell /bin/bash crucible

# Create crucible data directory
RUN mkdir -p /opt/atlassian/crucible/data

# Give Crucible directories ownership to user crucible
RUN chown -R crucible: /opt/atlassian/crucible

# Setup Crucible data directory in environment
RUN echo 'FISHEYE_INST="/opt/atlassian/crucible/data"' >> /etc/environment

# Create a configuration link to crucible config from a configuration container
RUN rm -f /opt/atlassian/crucible/current/config.xml
RUN mkdir -p /config
RUN touch /config/config.xml
RUN ln -s /config/config.xml /opt/atlassian/crucible/current/config.xml


# Add daemon to be run by runit.
RUN mkdir /etc/service/crucible
RUN cp /scripts/run /etc/service/crucible/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
