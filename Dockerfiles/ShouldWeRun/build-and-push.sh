#!/bin/bash
set -ev
docker build . --progress plain
docker tag "$(docker image ls -a | head -2 | tail -1 | awk '{ print $3 }')" convenient/magento2-upgrade-patch-helper-github-action:shouldWeRunV1
docker push convenient/magento2-upgrade-patch-helper-github-action:shouldWeRunV1