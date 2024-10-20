#!/bin/bash

echo "Starting $1 tests..."
docker-compose run --name $1 -e COMMIT_INFO_BRANCH=$BRANCH $1
echo "$1 tests have been completed"

echo "Copying test artifacts"
docker cp $1:/home/node/.artifacts .
rm -rf ./.artifacts/*monorepo
touch -m ./.artifacts/*

echo "Tests artifacts"
ls $ARTIFACTS_DIRECTORY
