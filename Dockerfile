FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    OV_PASSWORD=eonadmin

RUN apt-get update && \
    apt-get install software-properties-common --no-install-recommends -yq && \
    add-apt-repository ppa:mrazavi/openvas -y && \
    apt-get clean && \
    apt-get update && \
    apt-get install alien \
                    bzip2 \
                    curl \
                    dnsutils \
                    net-tools \
                    nmap \
                    openssh-client \
                    rpm \
                    rsync \
                    sendmail \
                    smbclient \
                    sqlite3 \
                    wget \
                    -yq && \
    apt-get install \
                    libopenvas9-dev \
                    nsis \
                    openvas9 \
                    texlive-latex-base \
                    texlive-latex-extra \
                    texlive-latex-recommended \
                    w3af \
                    wapiti \
                    -yq && \
    apt-get purge \
        texlive-pstricks-doc \
        texlive-pictures-doc \
        texlive-latex-extra-doc \
        texlive-latex-base-doc \
        texlive-latex-recommended-doc \
        software-properties-common \
        -yq && \
    apt-get autoremove -yq && \
    rm -rf /var/lib/apt/lists/*


RUN mkdir -p /var/run/redis

RUN wget -q https://github.com/Arachni/arachni/releases/download/v1.5/arachni-1.5-0.5.11-linux-x86_64.tar.gz && \
    tar -zxf arachni-1.5-0.5.11-linux-x86_64.tar.gz && \
    mv arachni-1.5-0.5.11 /opt/arachni && \
    ln -s /opt/arachni/bin/* /usr/local/bin/ && \
    rm -rf arachni*

RUN \
    sed -i 's/DAEMON_ARGS=""/DAEMON_ARGS="-a 0.0.0.0"/' /etc/init.d/openvas-manager && \
    sed -i 's/DAEMON_ARGS=""/DAEMON_ARGS="--mlisten 127.0.0.1 -m 9390"/' /etc/init.d/openvas-gsa && \
    sed -i 's/PORT_NUMBER=4000/PORT_NUMBER=443/' /etc/default/openvas-gsa && \
    greenbone-nvt-sync && \
    greenbone-scapdata-sync && \
    greenbone-certdata-sync

ADD config/redis.config /etc/redis/redis.config
ADD openvas-check-setup.sh /openvas-check-setup.sh
ADD start.sh /start.sh

RUN chmod +x /start.sh && \
    chmod +x /openvas-check-setup.sh

CMD /start.sh
EXPOSE 443 9390