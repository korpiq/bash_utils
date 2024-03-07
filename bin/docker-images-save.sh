PROJECT=$(pwd | sed 's!.*/!!'); sudo tar czf "$PROJECT-docker-volumes-$(date -Im | sed 's/:/_/g').tar.gz" $(docker volume ls -q | grep "$PROJECT" | xargs docker inspect | jq -r '.[].Mountpoint')
