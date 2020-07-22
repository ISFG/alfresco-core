#!/bin/sh

sudo docker network create spisum_network
sudo docker volume create alf-repo-data
sudo docker volume create postgres-data
sudo docker volume create solr-data
sudo docker volume create shared-file-store-volume
sudo docker-compose up -d