FROM lnbook/lnd-base

ADD lnd /lnd
RUN ln -s /lnd /root/.lnd

WORKDIR /lnd
CMD /bin/bash lnd-start.sh \
	&& sleep 5 \
	&& /bin/bash fund-lnd.sh 
