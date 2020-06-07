#!/bin/bash
# 
# Build docker image and push to repository
#

set -e

source_path="$1"
image_name="$2"
repository_url="$3"
tag="${4:-latest}"


(cd "$source_path" && docker build -t "$image_name" .)

#$(aws ecr get-login --no-include-email --region "$region")
#$(aws ecr get-login-password --region $region --no-verify-ssl | docker login --username AWS --password-stdin $repository_url)
docker tag "$image_name" "$repository_url":"$tag"
docker push "$repository_url":"$tag"

echo "...build complete."