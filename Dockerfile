FROM ubuntu:14.04
MAINTAINER Primiano Tucci <p.tucci@gmail.com>

RUN apt-get -y update && \
    apt-get -y install git python-pip python-libvirt python-libxml2 supervisor novnc

RUN git clone https://github.com/retspen/webvirtmgr /webvirtmgr
WORKDIR /webvirtmgr
RUN pip install -r requirements.txt
ADD local_settings.py /webvirtmgr/webvirtmgr/local/local_settings.py
RUN sed -i 's/0.0.0.0/172.17.42.1/g' vrtManager/create.py
RUN sed -i 's/WS_PORT = 6080/WS_PORT = 2086/g' webvirtmgr/settings.py
RUN /usr/bin/python /webvirtmgr/manage.py collectstatic --noinput

ADD supervisor.webvirtmgr.conf /etc/supervisor/conf.d/webvirtmgr.conf
ADD gunicorn.conf.py /webvirtmgr/conf/gunicorn.conf.py

ADD bootstrap.sh /webvirtmgr/bootstrap.sh

RUN useradd webvirtmgr -g libvirtd -u 1010 -d /data/vm/ -s /sbin/nologin
RUN chown webvirtmgr:libvirtd -R /webvirtmgr

RUN apt-get -ys clean

WORKDIR /
VOLUME /data/vm

EXPOSE 8080
EXPOSE 2086
CMD ["supervisord", "-n"]
