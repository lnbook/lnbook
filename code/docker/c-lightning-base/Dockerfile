FROM ubuntu:18.04

# Install development tools prerequisites
RUN apt-get update && apt-get install -y \
    build-essential \
	libtool \
	autotools-dev \
	automake \
	pkg-config \
	python3 \
	wget \
	git \
	curl \
	unzip


# Install software-properties-common to add apt repositories
RUN apt-get install -y \
	software-properties-common


# c-lightning
RUN add-apt-repository -u ppa:lightningnetwork/ppa
RUN apt-get install -y \
 	lightningd
