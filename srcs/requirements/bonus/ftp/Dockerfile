FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        passwd \
        vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/ftp-entrypoint.sh

RUN chmod 755 /usr/local/bin/ftp-entrypoint.sh

EXPOSE 21 21000-21010

ENTRYPOINT ["/usr/local/bin/ftp-entrypoint.sh"]
CMD ["/usr/sbin/vsftpd", "/etc/vsftpd.conf"]
