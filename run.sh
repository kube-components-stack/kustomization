#!/bin/bash

docker run -it --rm --env-file .env --entrypoint "bash" bitnami/kubectl:1.21