FROM lnbook/lnd-base

ADD lnd /lnd
RUN ln -s /lnd /root/.lnd
ADD fund-lnd.sh /usr/local/bin
RUN chmod +x /usr/local/bin/fund-lnd.sh
ADD bashrc /root/.bashrc
ADD lnd-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/lnd-entrypoint.sh

WORKDIR /lnd
ENTRYPOINT ["/usr/local/bin/lnd-entrypoint.sh"]

# Show lnd logs from beginning and keep following
CMD ["tail", "-n", "+1", "-f", "/lnd/logs/bitcoin/regtest/lnd.log"]
