#!/bin/bash
set -x

# env vars
export SHA="sha-${SHA::7}"
# pull the containers
docker pull ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}-amd64
docker pull ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}-arm64

#https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/

# update the current sha on the base image
docker manifest create ghcr.io/jrcichra/cockroachdb-multiarch:${SHA} \
    --amend ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}-amd64 \
    --amend ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}-arm64
docker manifest push ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}

# if main branch, update the latest tag on the base image
if [ "$BRANCH_NAME" == "main" ] || [ "$BRANCH_NAME" == "master" ]; then
    docker manifest create ghcr.io/jrcichra/cockroachdb-multiarch:latest \
        --amend ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}-amd64 \
        --amend ghcr.io/jrcichra/cockroachdb-multiarch:${SHA}-arm64
    docker manifest push ghcr.io/jrcichra/cockroachdb-multiarch:latest
fi
