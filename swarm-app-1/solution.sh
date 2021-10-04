#!/bin/zsh

FE_NET=frontend
BE_NET=backend
# KV_DATA=/data

docker network create --driver overlay ${FE_NET}
docker network create --driver overlay ${BE_NET}

# vote service
docker service create --name vote --replicas 2 --network ${FE_NET} -p 80:80 bretfisher/examplevotingapp_vote

# redis service
docker service create --name redis --network ${FE_NET} redis:3.2

# worker 
docker service create --name worker --network ${BE_NET} --network ${BE_NET} bretfisher/examplevotingapp_worker:java

# db
docker service create --name db --network backend --mount type=volume,source=db-data,target=/var/lib/postgresql/data -e POSTGRES_HOST_AUTH_METHOD=trust postgres:9.4

# result
docker service create --name result --network ${BE_NET} -p 5001:80 bretfisher/examplevotingapp_result

# Need a proxy in front of any services that REQUIRE a persistant connection to particular
# container/IP. ie. websockets to specific container persistently. 