FROM golang:1.16.9-buster
RUN apt-get update && apt-get install -y autoconf cmake libncurses-dev bison && rm -rf /var/lib/apt/lists/*
RUN curl https://binaries.cockroachdb.com/cockroach-v21.1.11.src.tgz | tar -xz 
RUN bash -c 'cd cockroach* && make build && make install'

FROM ubuntu:21.04
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
