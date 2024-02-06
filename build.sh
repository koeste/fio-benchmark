#!/bin/bash
clear
echo "" && echo ""
figlet Image Build
echo ""
docker image prune --all --force
docker build -t kaioeste/fiotest .