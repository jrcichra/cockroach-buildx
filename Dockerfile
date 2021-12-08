FROM golang:1.16.11-buster
RUN apt-get update && apt-get install -y autoconf cmake libncurses-dev bison ccache git && rm -rf /var/lib/apt/lists/*
RUN git clone -b v21.2.2 –depth 1 https://github.com/cockroachdb/cockroach.git
RUN bash -c 'cd cockroach* && make build && make install'

FROM debian:buster
# For deployment, we need the following additionally installed:
# tzdata - for time zone functions; reinstalled to replace the missing
#          files in /usr/share/zoneinfo/
# hostname - used in cockroach k8s manifests
# tar - used by kubectl cp
RUN apt-get update && apt-get install -y tzdata hostname tar && rm -rf /var/lib/apt/lists/*
RUN mkdir /usr/local/lib/cockroach /cockroach /licenses
COPY cockroach.sh /cockroach/
COPY --from=0  /usr/local/bin/cockroach /cockroach/
#COPY licenses/* /licenses/
# Install GEOS libraries.
#COPY libgeos.so libgeos_c.so /usr/local/lib/cockroach/
# Set working directory so that relative paths
# are resolved appropriately when passed as args.
WORKDIR /cockroach/
# Include the directory in the path to make it easier to invoke
# commands via Docker
ENV PATH=/cockroach:$PATH
ENV COCKROACH_CHANNEL=unofficial-docker
EXPOSE 26257 8080
ENTRYPOINT ["/cockroach/cockroach.sh"]
