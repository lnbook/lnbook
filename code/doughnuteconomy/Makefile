
REGISTRY=docker.com
NAME=lnbook
CONTAINERS=bitcoind c-lightning

all: build-all push-all

build-all:
	for container in ${CONTAINERS}; do \
		docker build -t ${NAME}/$$container $$container -f $$container/Dockerfile; \
	done

push-all:
	for container in ${CONTAINERS}; do \
		docker push ${NAME}/$$container; \
	done
