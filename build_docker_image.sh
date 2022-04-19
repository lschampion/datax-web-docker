#!/bin/bash
version=${1:-1.0.0}
echo "use version :$version"
docker build --file ./Dockerfile --tag lisacumt/datax-web-docker:$version .
