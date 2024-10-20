#!/bin/bash
set -e

if [ -n "$USE_CACHE" ]; then
  echo "Pulling $1 cached docker image if it exists..."
  docker pull $1 || true
  echo "$1 docker image pulled"

  export CACHE_ARGS="
    --cache-from=$1
    --build-arg BUILDKIT_INLINE_CACHE=1"
fi

echo "Building $1 docker image..."
DOCKER_BUILDKIT=1 docker build \
  -t $1 \
  -f $2 \
  $CACHE_ARGS \
  --compress \
  --build-arg ENV=$ENV \
  --build-arg SITECORE_NPM_REGISTRY=$SITECORE_NPM_REGISTRY \
  --build-arg SITECORE_NPM_TOKEN=$SITECORE_NPM_TOKEN \
  --build-arg MONOREPO_IMAGE=$MONOREPO_IMAGE_TAG \
  "${@:3}" \
  .
echo "$1 image built"

if [ -n "$PUBLISH_IMAGE" ] || [ -n "$USE_CACHE" ]; then
  echo "Publishing $1 docker image..."
  docker tag $1 $1
  docker push $1
  echo "$1 image published"
fi