#!make
#
# Makefile to help with building, pulling and pushing containers
#
# NOTE: You cannot push to the container registry unless you are authorized
# in the lnbook organization (i.e. one of the authors or maintainers)
#
# Targets:
#
# make build # Build all containers
# make pull # Pull all containers from the registry
# make build-bitcoind # Build a specific container
# make clean # remove all images and containers
# make push # push updated images to Docker Hub (authors/maintainers only)


# Latest tested versions of Bitcoin and Lightning clients

# OS base image
OS=ubuntu
OS_VER=focal

# bitcoind version
BITCOIND_VER=0.21.0

# LND version
GO_VER=1.13
LND_VER=v0.13.1-beta

# c-lightning version
CL_VER=0.10.1

# Eclair version
ECLAIR_VER=0.4.2
ECLAIR_COMMIT=52444b0




# Docker registry for lnbook
REGISTRY=docker.com
ORG=lnbook

# List of containers
CONTAINERS=bitcoind lnd eclair c-lightning

.DEFAULT: pull





build-bitcoind:
	docker build \
	--build-arg OS=${OS} \
	--build-arg OS_VER=${OS_VER} \
	--build-arg BITCOIND_VER=${BITCOIND_VER} \
	-t ${ORG}/bitcoind:${BITCOIND_VER} \
	bitcoind -f bitcoind/Dockerfile
	docker image tag ${ORG}/bitcoind:${BITCOIND_VER} ${ORG}/bitcoind:latest


build-cl: build-bitcoind
	docker build \
	--build-arg OS=${OS} \
	--build-arg OS_VER=${OS_VER} \
	--build-arg CL_VER=${CL_VER} \
	-t ${ORG}/c-lightning:${CL_VER} \
	c-lightning -f c-lightning/Dockerfile
	docker image tag ${ORG}/c-lightning:${CL_VER} ${ORG}/c-lightning:latest


build-lnd:
	docker build \
	--build-arg OS=${OS} \
	--build-arg OS_VER=${OS_VER} \
	--build-arg LND_VER=${LND_VER} \
	--build-arg GO_VER=${GO_VER} \
	-t ${ORG}/lnd:${LND_VER}_golang_${GO_VER} \
	lnd -f lnd/Dockerfile
	docker image tag ${ORG}/lnd:${LND_VER}_golang_${GO_VER} ${ORG}/lnd:latest


build-eclair:
	docker build \
	--build-arg OS=${OS} \
	--build-arg OS_VER=${OS_VER} \
	--build-arg ECLAIR_VER=${ECLAIR_VER} \
	--build-arg ECLAIR_COMMIT=${ECLAIR_COMMIT} \
	-t ${ORG}/eclair:${ECLAIR_VER}-${ECLAIR_COMMIT} \
	eclair -f eclair/Dockerfile
	docker image tag ${ORG}/eclair:${ECLAIR_VER}-${ECLAIR_COMMIT} ${ORG}/eclair:latest


push-bitcoind: build-bitcoind
	docker push ${ORG}/bitcoind:${BITCOIND_VER}
	docker push ${ORG}/bitcoind:latest

push-lnd: build-lnd
	docker push ${ORG}/lnd:${LND_VER}_golang_${GO_VER}
	docker push ${ORG}/lnd:latest

push-cl: build-cl
	docker push ${ORG}/c-lightning:${CL_VER}
	docker push ${ORG}/c-lightning:latest

push-eclair: build-eclair
	docker push ${ORG}/eclair:${ECLAIR_VER}-${ECLAIR_COMMIT}
	docker push ${ORG}/eclair:latest

build: build-bitcoind build-lnd build-cl build-eclair

push: push-bitcoind push-lnd push-cl push-eclair

pull:
	for container in ${CONTAINERS}; do \
		docker pull ${ORG}/$$container:latest ;\
	done

clean:
	# Try 'make clean-confirm' if you are sure you want to do this.
	# CAUTION: ALL docker containers and images on your computer will be removed.

clean-confirm:
	docker rm -f `docker ps -qa`
	docker rmi -f `docker image ls -qa`
